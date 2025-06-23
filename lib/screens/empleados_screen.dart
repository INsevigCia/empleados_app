import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/empleados_service.dart';
import '../models/empleado_model.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final EmpleadosService _empleadosService = EmpleadosService();
  final TextEditingController _busquedaController = TextEditingController();

  List<Empleado> _empleados = [];
  List<Empleado> _empleadosFiltrados = [];
  bool _isLoading = false;
  bool _soloActivos = false;
  String _terminoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _busquedaController.addListener(_onBusquedaChanged);
  }

  @override
  void dispose() {
    _busquedaController.removeListener(_onBusquedaChanged);
    _busquedaController.dispose();
    super.dispose();
  }

  // 🔍 Cuando cambia el texto de búsqueda
  void _onBusquedaChanged() {
    final termino = _busquedaController.text.trim();
    if (termino != _terminoBusqueda) {
      setState(() {
        _terminoBusqueda = termino;
      });
      _buscarEmpleados();
    }
  }

  // 🔍 Buscar empleados
  Future<void> _buscarEmpleados() async {
    if (_terminoBusqueda.length < 2) {
      setState(() {
        _empleados = [];
        _empleadosFiltrados = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final empleados =
          await _empleadosService.buscarEmpleados(_terminoBusqueda);
      setState(() {
        _empleados = empleados;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _empleados = [];
        _empleadosFiltrados = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al buscar empleados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🎯 Aplicar filtros
  void _aplicarFiltros() {
    if (_soloActivos) {
      _empleadosFiltrados =
          _empleados.where((empleado) => empleado.estado == 'ACT').toList();
    } else {
      _empleadosFiltrados = List.from(_empleados);
    }
  }

  // 🎯 Toggle filtro solo activos
  void _toggleSoloActivos(bool? value) {
    setState(() {
      _soloActivos = value ?? false;
      _aplicarFiltros();
    });
  }

  // 🔄 Limpiar búsqueda
  void _limpiarBusqueda() {
    _busquedaController.clear();
    setState(() {
      _terminoBusqueda = '';
      _empleados = [];
      _empleadosFiltrados = [];
      _isLoading = false;
    });
  }

  // 📋 Mostrar detalles del empleado con opciones de copiado
  void _mostrarDetallesEmpleado(Empleado empleado) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 Encabezado
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${empleado.apellidos} ${empleado.nombres}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📋 Lista de campos con botones de copiar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _construirCampoCopiable('📋 Código', empleado.codigo),
                    _construirCampoCopiable(
                        '🆔 Cédula', empleado.cedulaFormateada),
                    _construirCampoCopiable('💼 Cargo', empleado.nomcargo),
                    _construirCampoCopiable('🏢 Departamento', empleado.nomdep),
                    _construirCampoCopiable('📍 Sección', empleado.seccion),
                    _construirCampoCopiable(
                        '💰 Sueldo', empleado.sueldoFormateado),
                    _construirCampoCopiable(
                        '📅 Fecha Ingreso', empleado.fechaIngresoFormateada),

                    // 🚨 MOSTRAR FECHA DE SALIDA SOLO SI ES NECESARIO
                    if (empleado.estado == 'LIQ' ||
                        empleado.fecha_salida.isNotEmpty)
                      _construirCampoCopiable(
                        '📅 Fecha Salida',
                        empleado.fechaSalidaFormateada,
                        esImportante:
                            true, // Resaltar en rojo para empleados liquidados
                      ),

                    _construirCampoCopiable('📱 Teléfono', empleado.telefono),
                    _construirCampoCopiable('🏠 Dirección', empleado.direccion),
                    _construirCampoCopiable(
                        '💳 Cuenta Bancaria', empleado.cuentaBancaria),
                    _construirCampoCopiable(
                        '✅ Estado', empleado.estadoDescripcion),
                  ],
                ),
              ),
            ),

            // 🔘 Botón para copiar todo
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copiarTodosDatos(empleado),
                icon: const Icon(Icons.copy_all),
                label: const Text('📋 Copiar todos los datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📋 Widget para campo con botón de copiar
  Widget _construirCampoCopiable(String etiqueta, String valor,
      {bool esImportante = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esImportante ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esImportante ? Colors.red[300]! : Colors.grey[300]!,
          width: esImportante ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: esImportante ? Colors.red[700] : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? 'No disponible' : valor,
              style: TextStyle(
                fontSize: 14,
                color: esImportante ? Colors.red[700] : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copiarTexto(etiqueta, valor),
            icon: const Icon(Icons.copy, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: esImportante ? Colors.red[50] : Colors.blue[50],
              foregroundColor:
                  esImportante ? Colors.red[600] : Colors.blue[600],
            ),
            tooltip: 'Copiar $etiqueta',
          ),
        ],
      ),
    );
  }

  // 📋 Copiar texto individual
  void _copiarTexto(String tipo, String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 $tipo copiado: $texto'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 📋 Copiar todos los datos
  void _copiarTodosDatos(Empleado empleado) {
    final fechaSalidaTexto =
        empleado.estado == 'LIQ' || empleado.fecha_salida.isNotEmpty
            ? 'Fecha Salida: ${empleado.fechaSalidaFormateada}\n'
            : '';

    final todosDatos = '''
👤 DATOS PERSONALES
Nombre: ${empleado.apellidos} ${empleado.nombres}
Cédula: ${empleado.cedulaFormateada}
Teléfono: ${empleado.telefono}
Dirección: ${empleado.direccion}

🏢 DATOS LABORALES
Código: ${empleado.codigo}
Cargo: ${empleado.nomcargo}
Departamento: ${empleado.nomdep}
Sección: ${empleado.seccion}
Sueldo: ${empleado.sueldoFormateado}
Fecha Ingreso: ${empleado.fechaIngresoFormateada}
${fechaSalidaTexto}Estado: ${empleado.estadoDescripcion}

🏦 DATOS BANCARIOS
Cuenta: ${empleado.cuentaBancaria}
''';

    Clipboard.setData(ClipboardData(text: todosDatos));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Todos los datos copiados al portapapeles'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        backgroundColor: Colors.blue[700], // ← AZUL FIJO
      ),
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar empleado...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _terminoBusqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _limpiarBusqueda,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // 🎯 Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text('Filtros:'),
                const SizedBox(width: 16),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Solo empleados activos'),
                    value: _soloActivos,
                    onChanged: _toggleSoloActivos,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // 📊 Contador de resultados
          if (_terminoBusqueda.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📊 ${_empleadosFiltrados.length} empleados encontrados para "$_terminoBusqueda"',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // 📋 Lista de empleados
          Expanded(
            child: _construirCuerpo(),
          ),
        ],
      ),
    );
  }

  // 📋 Construir cuerpo principal
  Widget _construirCuerpo() {
    if (_terminoBusqueda.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Ingresa al menos 2 caracteres para buscar empleados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('🔍 Buscando empleados...'),
          ],
        ),
      );
    }

    if (_empleadosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _soloActivos
                  ? 'No se encontraron empleados activos para "$_terminoBusqueda"'
                  : 'No se encontraron empleados para "$_terminoBusqueda"',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _limpiarBusqueda,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar otra búsqueda'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _empleadosFiltrados.length,
      itemBuilder: (context, index) {
        final empleado = _empleadosFiltrados[index];
        return _construirTarjetaEmpleado(empleado);
      },
    );
  }

  // 📋 Construir tarjeta de empleado
  Widget _construirTarjetaEmpleado(Empleado empleado) {
    // 🎨 Color según estado
    Color colorEstado;
    switch (empleado.estado) {
      case 'ACT':
        colorEstado = Colors.green;
        break;
      case 'LIQ':
        colorEstado = Colors.red;
        break;
      case 'SUS':
        colorEstado = Colors.orange;
        break;
      default:
        colorEstado = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withOpacity(0.1),
          child: Text(
            empleado.nombres.isNotEmpty
                ? empleado.nombres[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: colorEstado,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${empleado.apellidos} ${empleado.nombres}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🆔 ${empleado.cedulaFormateada}'),
            Text('💼 ${empleado.nomcargo}'),
            Text('🏢 ${empleado.nomdep}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorEstado.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorEstado),
          ),
          child: Text(
            empleado.estadoDescripcion,
            style: TextStyle(
              color: colorEstado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => _mostrarDetallesEmpleado(empleado),
        isThreeLine: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/empleado.dart';

// 📋 Diálogo para mostrar detalles completos del empleado
class EmpleadoDetalleDialog extends StatelessWidget {
  final Empleado empleado;

  const EmpleadoDetalleDialog({
    Key? key,
    required this.empleado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📋 Header del diálogo
            _buildHeader(context),
            
            // 📄 Contenido scrolleable
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👤 Información personal
                    _buildSeccion(
                      titulo: '👤 Información Personal',
                      icono: Icons.person,
                      children: [
                        _buildCampo('Nombres', empleado.nombres),
                        _buildCampo('Apellidos', empleado.apellidos),
                        _buildCampo('Cédula', empleado.cedula, copiable: true),
                        _buildCampo('Teléfono', empleado.telefono, copiable: true),
                        _buildCampo('Dirección', empleado.direccion),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // 🏢 Información laboral
                    _buildSeccion(
                      titulo: '🏢 Información Laboral',
                      icono: Icons.work,
                      children: [
                        _buildCampo('Código', empleado.cod.toString()),
                        _buildCampo('Cargo', empleado.nomcargo),
                        _buildCampo('Departamento', empleado.nomdep),
                        _buildCampo('Estado', empleado.estadoDescripcion),
                        _buildCampo('Sueldo', empleado.sueldoFormateado),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // 💳 Información bancaria
                    if (empleado.cuentaBancaria.isNotEmpty)
                      _buildSeccion(
                        titulo: '💳 Información Bancaria',
                        icono: Icons.account_balance,
                        children: [
                          _buildCampo('Cuenta Bancaria', empleado.cuentaBancaria, copiable: true),
                        ],
                      ),
                    
                    SizedBox(height: 20),
                    
                    // 📊 Metadatos
                    _buildSeccion(
                      titulo: '📊 Información del Sistema',
                      icono: Icons.info,
                      children: [
                        _buildCampo('Última Actualización', _formatearFecha(empleado.fechaActualizacion)),
                        _buildCampo('ID en Base de Datos', empleado.id.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 🔘 Botones de acción
            _buildBotones(context),
          ],
        ),
      ),
    );
  }

  // 📋 Header del diálogo
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // 🎯 Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _obtenerIniciales(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          
          SizedBox(width: 16),
          
          // 📝 Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empleado.nombresCompletos,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  empleado.nomcargo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // ❌ Botón cerrar
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // 📂 Sección de información
  Widget _buildSeccion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📋 Título de la sección
        Row(
          children: [
            Icon(icono, color: Colors.blue[700], size: 20),
            SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // 📄 Contenido de la sección
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  // 📝 Campo de información
  Widget _buildCampo(String etiqueta, String valor, {bool copiable = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📋 Etiqueta
          SizedBox(
            width: 120,
            child: Text(
              '$etiqueta:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          
          // 📄 Valor
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valor.isEmpty ? 'No especificado' : valor,
                    style: TextStyle(
                      color: valor.isEmpty ? Colors.grey[500] : Colors.grey[800],
                      fontStyle: valor.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                
                // 📋 Botón copiar
                if (copiable && valor.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: Colors.blue[600]),
                    onPressed: () => _copiarTexto(valor),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    tooltip: 'Copiar',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 Botones de acción
  Widget _buildBotones(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 📞 Llamar (si tiene teléfono)
          if (empleado.telefono.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _llamarEmpleado(),
              icon: Icon(Icons.phone),
              label: Text('Llamar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
            ),
          
          // 📧 Email (placeholder)
          ElevatedButton.icon(
            onPressed: () => _enviarEmail(),
            icon: Icon(Icons.email),
            label: Text('Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
            ),
          ),
          
          // ✅ Cerrar
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.check),
            label: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // 🎯 Obtener iniciales del empleado
  String _obtenerIniciales() {
    String iniciales = '';
    if (empleado.nombres.isNotEmpty) {
      iniciales += empleado.nombres[0].toUpperCase();
    }
    if (empleado.apellidos.isNotEmpty) {
      iniciales += empleado.apellidos[0].toUpperCase();
    }
    return iniciales.isEmpty ? '?' : iniciales;
  }

  // 📅 Formatear fecha
  String _formatearFecha(String fechaISO) {
    try {
      DateTime fecha = DateTime.parse(fechaISO);
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  // 📋 Copiar texto al portapapeles
  void _copiarTexto(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    // Aquí podrías mostrar un SnackBar de confirmación
  }

  // 📞 Función placeholder para llamar
  void _llamarEmpleado() {
    // Aquí implementarías la funcionalidad de llamada
    print('📞 Llamando a: ${empleado.telefono}');
  }

  // 📧 Función placeholder para email
  void _enviarEmail() {
    // Aquí implementarías la funcionalidad de email
    print('📧 Enviando email a: ${empleado.nombresCompletos}');
  }
}
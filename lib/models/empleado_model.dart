import 'package:intl/intl.dart';
class Empleado {
  final String codigo;
  final String nombres;
  final String apellidos;
  final String nombres_completos;
  final String cedula;
  final String estado;
  final String telefono;
  final String nomcargo;
  final String cod_cargo;
  final double sueldo;
  final String nomdep;
  final String cod_departamento;
  final String seccion;
  final String fecha_ingreso;
  final String fecha_salida;  // ← AGREGAR ESTA LÍNEA
  final String direccion;
  final String cuenta_ahorros;
  final String cuenta_corriente;

  // 🔄 Getters para compatibilidad
  String get cargo => nomcargo;
  String get departamento => nomdep;
  String get email => ''; 
  String get banco => ''; 
  String get cuentaBancaria => cuenta_ahorros.isNotEmpty ? cuenta_ahorros : cuenta_corriente;

  // 📋 Formatear cédula a 10 dígitos
  String get cedulaFormateada {
    String cedulaLimpia = cedula.replaceAll('.0', '');
    if (cedulaLimpia.length == 9) {
      return '0$cedulaLimpia';
    }
    return cedulaLimpia;
  }

  // 📅 Formatear fecha de ingreso
  String get fechaIngresoFormateada {
    if (fecha_ingreso.isEmpty) return 'No disponible';
    try {
      DateTime fecha = DateTime.parse(fecha_ingreso);
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    } catch (e) {
      return fecha_ingreso;
    }
  }

  // 📅 Formatear fecha de salida ← AGREGAR ESTE GETTER
  String get fechaSalidaFormateada {
    if (fecha_salida.isEmpty) return 'Empleado activo';
    try {
      DateTime fecha = DateTime.parse(fecha_salida);
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    } catch (e) {
      return fecha_salida;
    }
  }

  // 🟢 Obtener color según estado
  String get estadoDescripcion {
    switch (estado) {
      case 'ACT':
        return 'Activo';
      case 'LIQ':
        return 'Liquidado';
      case 'SUS':
        return 'Suspendido';
      default:
        return estado;
    }
  }

  // 💰 Sueldo formateado con separadores de miles
  String get sueldoFormateado {
    try {
      final formatter = NumberFormat('#,###.00', 'es_ES');
      return '\$${formatter.format(sueldo)}';
    } catch (e) {
      return '\$${sueldo.toStringAsFixed(2)}';
    }
  }

  Empleado({
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.nombres_completos,
    required this.cedula,
    required this.estado,
    required this.telefono,
    required this.nomcargo,
    required this.cod_cargo,
    required this.sueldo,
    required this.nomdep,
    required this.cod_departamento,
    required this.seccion,
    required this.fecha_ingreso,
    required this.fecha_salida,  // ← AGREGAR ESTA LÍNEA
    required this.direccion,
    required this.cuenta_ahorros,
    required this.cuenta_corriente,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      codigo: json['codigo']?.toString() ?? '',
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      nombres_completos: json['nombres_completos']?.toString() ?? '',
      cedula: json['cedula']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      nomcargo: json['nomcargo']?.toString() ?? '',
      cod_cargo: json['cod_cargo']?.toString() ?? '',
      sueldo: (json['sueldo'] ?? 0).toDouble(),
      nomdep: json['nomdep']?.toString() ?? '',
      cod_departamento: json['cod_departamento']?.toString() ?? '',
      seccion: json['seccion']?.toString() ?? '',
      fecha_ingreso: json['fecha_ingreso']?.toString() ?? '',
      fecha_salida: json['fecha_salida']?.toString() ?? '',  // ← AGREGAR ESTA LÍNEA
      direccion: json['direccion']?.toString() ?? '',
      cuenta_ahorros: json['cuenta_ahorros']?.toString() ?? '',
      cuenta_corriente: json['cuenta_corriente']?.toString() ?? '',
    );
  }
}
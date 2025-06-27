//import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/empleado_model.dart';
import '../config/supabase_config.dart';

// 🚀 Servicio de Empleados - Conecta con Supabase
class EmpleadosService {
  //final SupabaseClient _supabase = Supabase.instance.client;

  // 🔍 Búsqueda optimizada - FUNCIÓN PRINCIPAL
  Future<List<Empleado>> buscarEmpleados(String termino) async {
    if (termino.isEmpty) {
      return []; // No mostrar nada si no hay búsqueda
    }

    // Si el término es muy corto, no buscar para evitar demasiados resultados
    if (termino.length < 2) {
      return [];
    }

    try {
      print('🔍 Buscando: "$termino"');
      
      // 🚀 BÚSQUEDA DIRECTA EN BASE DE DATOS - No descargar todo
      final response = await _supabase
          .from(SupabaseConfig.tablaEmpleados)
          .select()
          .or(
            'nombres.ilike.%$termino%,'
            'apellidos.ilike.%$termino%,'
            'cedula.like.%$termino%,'
            'nomcargo.ilike.%$termino%,'
            'nomdep.ilike.%$termino%'
          )
          .order('nombres')
          .limit(100); // Solo traer máximo 100 resultados

      final List<dynamic> datos = response as List<dynamic>;
      print('✅ Resultados encontrados directamente: ${datos.length}');
      
      if (datos.isEmpty) {
        print('❌ No se encontraron empleados para "$termino"');
        return [];
      }

      // 🔄 Convertir a objetos Empleado
      final empleados = datos.map((json) => Empleado.fromJson(json)).toList();
      
      print('🔍 Búsqueda "$termino": ${empleados.length} resultados encontrados');
      return empleados;
      
    } catch (e) {
      print('🔍 Error en búsqueda SQL: $e');
      print('🔄 Intentando búsqueda de respaldo...');
      
      // 🆘 BÚSQUEDA DE RESPALDO: Si falla el SQL, usar método anterior
      try {
        final response = await _supabase
            .from(SupabaseConfig.tablaEmpleados)
            .select()
            .limit(500);

        final List<dynamic> datos = response as List<dynamic>;
        final empleados = datos.map((json) => Empleado.fromJson(json)).toList();
        final terminoLower = termino.toLowerCase();
        
        final resultados = empleados.where((empleado) {
          return empleado.nombres.toLowerCase().contains(terminoLower) ||
                 empleado.apellidos.toLowerCase().contains(terminoLower) ||
                 empleado.cedula.contains(termino) ||
                 empleado.nomcargo.toLowerCase().contains(terminoLower) ||
                 empleado.nomdep.toLowerCase().contains(terminoLower);
        }).toList();
        
        print('🆘 Búsqueda de respaldo "$termino": ${resultados.length} resultados');
        return resultados;
        
      } catch (e2) {
        print('❌ Error total en búsqueda: $e2');
        return [];
      }
    }
  }

  // 📊 SOLO para uso interno - NO llamar desde UI
  Future<List<Empleado>> obtenerEmpleados() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tablaEmpleados)
          .select();

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Empleado.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error obteniendo empleados: $error');
      return [];
    }
  }

  // 🎯 Obtener empleado por ID
  Future<Empleado?> obtenerEmpleadoPorId(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tablaEmpleados)
          .select()
          .eq('codigo', id)
          .single();

      return Empleado.fromJson(response);
    } catch (error) {
      print('❌ Error obteniendo empleado: $error');
      return null;
    }
  }

  // 📊 Obtener estadísticas
  Future<Map<String, int>> obtenerEstadisticas() async {
    try {
      final empleados = await obtenerEmpleados();
      
      final Map<String, int> stats = {
        'total': empleados.length,
        'activos': empleados.where((e) => e.estado == 'ACT').length,
        'liquidados': empleados.where((e) => e.estado == 'LIQ').length,
        'suspendidos': empleados.where((e) => e.estado == 'SUS').length,
      };
      
      return stats;
    } catch (error) {
      print('❌ Error obteniendo estadísticas: $error');
      return {'total': 0, 'activos': 0, 'liquidados': 0, 'suspendidos': 0};
    }
  }
}

// 🔧 Configuración de Supabase
class SupabaseConfig {
  // 🔗 Tu URL de Supabase
  static const String supabaseUrl = 'https://buzcapcwmksasrtjofae.supabase.co';
  
  // 🔑 Tu clave pública (anon key)
  // IMPORTANTE: Esta es la clave PÚBLICA, segura para usar en Flutter
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1emNhcGN3bWtzYXNydGpvZmFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5OTY4MzcsImV4cCI6MjA2NTU3MjgzN30.RjxEf5JmhoxfHL6QoncwHM5smQaoWq9ipVlrK_i2mPA';
  
  // 🔑 Service Key (usar la misma anon key por ahora)
  static const String supabaseServiceKey = supabaseAnonKey;
  
  // 📋 Nombre de la tabla de empleados
  static const String tablaEmpleados = 'empleados';
}
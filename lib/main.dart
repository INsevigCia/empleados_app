import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ DESCOMENTADO
import 'config/supabase_config.dart';
import 'screens/empleados_screen.dart';

// 🚀 Función principal de la app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔧 Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseServiceKey, // 🔧 Usando SERVICE KEY para saltarse RLS
  );
  
  runApp(EmpleadosApp());
}

// 📱 Aplicación principal
class EmpleadosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '👥 Empleados App',
      debugShowCheckedModeBanner: false, // Quitar banner "DEBUG"
      theme: ThemeData(
        // 🎨 Tema principal de la app
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[700],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // 📊 Tema para AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        
        // 🔘 Tema para botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: EmpleadosScreen(), // ✅ SIN CONST - ARREGLADO
    );
  }
}

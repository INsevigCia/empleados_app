import 'package:flutter/material.dart';
import '../models/empleado.dart';

// 🎴 Tarjeta para mostrar empleado en la lista
class EmpleadoCard extends StatelessWidget {
  final Empleado empleado;
  final VoidCallback? onTap;

  const EmpleadoCard({
    Key? key,
    required this.empleado,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Fila principal con nombre y estado
              Row(
                children: [
                  // 🎯 Avatar con iniciales
                  _buildAvatar(),
                  SizedBox(width: 12),
                  
                  // 📝 Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 👤 Nombre completo
                        Text(
                          empleado.nombresCompletos,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        
                        // 🏢 Cargo
                        Text(
                          empleado.nomcargo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        // 🏬 Departamento
                        Text(
                          empleado.nomdep,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 🟢 Estado
                  _buildEstadoBadge(),
                ],
              ),
              
              SizedBox(height: 12),
              
              // 📊 Información secundaria
              Row(
                children: [
                  // 💰 Sueldo
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    label: empleado.sueldoFormateado,
                    color: Colors.green,
                  ),
                  
                  SizedBox(width: 8),
                  
                  // 🆔 Código
                  _buildInfoChip(
                    icon: Icons.badge,
                    label: 'COD: ${empleado.cod}',
                    color: Colors.orange,
                  ),
                  
                  SizedBox(width: 8),
                  
                  // 📱 Teléfono (si existe)
                  if (empleado.telefono.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.phone,
                      label: empleado.telefono,
                      color: Colors.blue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎯 Avatar con iniciales del empleado
  Widget _buildAvatar() {
    // Obtener iniciales
    String iniciales = '';
    if (empleado.nombres.isNotEmpty) {
      iniciales += empleado.nombres[0].toUpperCase();
    }
    if (empleado.apellidos.isNotEmpty) {
      iniciales += empleado.apellidos[0].toUpperCase();
    }
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: empleado.esActivo ? Colors.blue[100] : Colors.grey[300],
      child: Text(
        iniciales,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: empleado.esActivo ? Colors.blue[700] : Colors.grey[600],
        ),
      ),
    );
  }

  // 🟢 Badge de estado
  Widget _buildEstadoBadge() {
    Color color;
    IconData icon;
    
    switch (empleado.estado) {
      case 'ACT':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'LIQ':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'SUS':
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            empleado.estadoDescripcion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 💳 Chip de información
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
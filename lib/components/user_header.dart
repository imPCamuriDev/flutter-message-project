import 'package:flutter/material.dart';
import '../../usuarios/models/usuario.dart';

class UserHeader extends StatelessWidget {
  final Usuario usuario;

  const UserHeader({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal,
      child: Row(
        children: [
          CircleAvatar(child: Text(usuario.nome[0].toUpperCase())),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              usuario.nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            usuario.telefone,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

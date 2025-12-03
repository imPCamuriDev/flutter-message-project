import 'package:flutter/material.dart';
import '../../usuarios/models/usuario.dart';

class ContactHeader extends StatelessWidget {
  final Usuario contato;

  const ContactHeader({super.key, required this.contato});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal,
      child: Row(
        children: [
          CircleAvatar(child: Text(contato.nome[0].toUpperCase())),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contato.nome,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                contato.telefone,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../usuarios/models/usuario.dart';

class ContactList extends StatelessWidget {
  final List<Usuario> contatos;
  final Usuario? selectedContact;
  final Function(Usuario) onSelect;

  const ContactList({
    super.key,
    required this.contatos,
    required this.selectedContact,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return contatos.isEmpty
        ? const Center(
            child: Text('Nenhum contato encontrado', style: TextStyle(color: Colors.grey)),
          )
        : ListView.builder(
            itemCount: contatos.length,
            itemBuilder: (context, index) {
              final contato = contatos[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contato.nome[0].toUpperCase()),
                ),
                title: Text(contato.nome),
                subtitle: Text(contato.telefone),
                selected: selectedContact?.id == contato.id,
                selectedTileColor: Colors.teal.withOpacity(0.1),
                onTap: () => onSelect(contato),
              );
            },
          );
  }
}

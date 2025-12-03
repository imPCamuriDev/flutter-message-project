import 'package:flutter/material.dart';
import '../../mensagem/model/mensagem.dart';
import '../../usuarios/models/usuario.dart';

class MessageList extends StatelessWidget {
  final List<Mensagem> messages;
  final int meuId;
  final Usuario contato;

  const MessageList({
    super.key,
    required this.messages,
    required this.meuId,
    required this.contato,
  });

  String _format(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: messages.isEmpty
          ? const Center(
              child: Text('Nenhuma mensagem ainda', style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMine = msg.remetenteId == meuId;

                return Row(
                  mainAxisAlignment:
                      isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMine)
                      CircleAvatar(
                        radius: 16,
                        child: Text(contato.nome[0].toUpperCase(), style: const TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Card(
                        color: isMine ? Colors.teal : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.texto,
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _format(msg.dataEnvio),
                                style: TextStyle(
                                  color: isMine ? Colors.white70 : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isMine)
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.teal,
                        child: Text(
                          contato.nome[0].toUpperCase(),
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

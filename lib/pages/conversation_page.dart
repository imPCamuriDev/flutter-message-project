import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  String? selectedContact;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMine': true,
          'contact': selectedContact,
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lista de contatos (lado esquerdo)
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal,
                  child: const Row(
                    children: [
                      Text(
                        'Conversas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Text('P')),
                        title: const Text('Pedro Gabriel'),
                        subtitle: const Text('Oi, tudo bem?'),
                        selected: selectedContact == 'Pedro Gabriel',
                        onTap: () {
                          setState(() {
                            selectedContact = 'Pedro Gabriel';
                          });
                        },
                      ),
                      ListTile(
                        leading: const CircleAvatar(child: Text('M')),
                        title: const Text('Maria Silva'),
                        subtitle: const Text('Vamos marcar?'),
                        selected: selectedContact == 'Maria Silva',
                        onTap: () {
                          setState(() {
                            selectedContact = 'Maria Silva';
                          });
                        },
                      ),
                      ListTile(
                        leading: const CircleAvatar(child: Text('J')),
                        title: const Text('João Santos'),
                        subtitle: const Text('Obrigado!'),
                        selected: selectedContact == 'João Santos',
                        onTap: () {
                          setState(() {
                            selectedContact = 'João Santos';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Área de conversa (lado direito)
          Expanded(
            child: selectedContact == null
                ? const Center(
                    child: Text(
                      'Começe uma conversa com aquele(a) sumido(a)!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      // Cabeçalho da conversa
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.teal,
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(selectedContact![0]),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedContact!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Área de mensagens
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: [
                              // Mensagem fixa de exemplo
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Oi, tudo bem?'),
                                  ),
                                ),
                              ),
                              // Mensagens dinâmicas
                              ..._messages
                                  .where((msg) => msg['contact'] == selectedContact)
                                  .map((msg) {
                                return Align(
                                  alignment: msg['isMine']
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Card(
                                    color: msg['isMine'] ? Colors.teal : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        msg['text'],
                                        style: TextStyle(
                                          color: msg['isMine']
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      
                      // Campo de digitação
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Digite uma mensagem',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              color: Colors.teal,
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
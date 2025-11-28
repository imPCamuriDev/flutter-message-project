import 'package:flutter/material.dart';
import '../api/services/api_service.dart';
import '../websockets/service/websockets_service.dart';

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  
  const ConversationPage({super.key, required this.usuario});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  Map<String, dynamic>? selectedContact;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  List<dynamic> _contatos = [];

  @override
  void initState() {
    super.initState();
    _carregarContatos();
    
    // Escutar mensagens do WebSocket
    WebSocketService.onMessage = (dados) {
      if (dados['tipo'] == 'nova_mensagem') {
        _carregarMensagens(); // Recarrega mensagens quando recebe nova
      }
    };
  }

  Future<void> _carregarContatos() async {
    final contatos = await ApiService.buscarContatos(widget.usuario['id']);
    setState(() => _contatos = contatos);
  }

  Future<void> _carregarMensagens() async {
    if (selectedContact == null) return;
    
    final mensagens = await ApiService.buscarConversa(
      widget.usuario['id'],
      selectedContact!['id'],
    );
    
    setState(() {
      _messages = mensagens.map((m) => {
        'text': m['texto'],
        'isMine': m['remetente_id'] == widget.usuario['id'],
      }).toList();
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || selectedContact == null) return;

    final sucesso = await ApiService.enviarMensagem(
      widget.usuario['id'],
      selectedContact!['id'],
      _messageController.text,
    );

    if (sucesso) {
      _messageController.clear();
      _carregarMensagens(); // Recarrega para mostrar mensagem enviada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lista de contatos
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
                  child: Row(
                    children: [
                      Text(
                        widget.usuario['nome'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _contatos.length,
                    itemBuilder: (context, index) {
                      final contato = _contatos[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(contato['nome'][0].toUpperCase()),
                        ),
                        title: Text(contato['nome']),
                        subtitle: Text(contato['telefone']),
                        selected: selectedContact?['id'] == contato['id'],
                        onTap: () {
                          setState(() => selectedContact = contato);
                          _carregarMensagens();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Área de conversa
          Expanded(
            child: selectedContact == null
                ? const Center(
                    child: Text(
                      'Selecione um contato',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      // Cabeçalho
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.teal,
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(selectedContact!['nome'][0].toUpperCase()),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedContact!['nome'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Mensagens
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
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
                            },
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
    WebSocketService.desconectar();
    super.dispose();
  }
}
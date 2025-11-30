import 'package:flutter/material.dart';
import '../usuarios/service/usuario_service.dart';
import '../mensagem/service/mensagem_service.dart';
import '../mensagem/service/mensagem_websocket_service.dart';
import '../usuarios/models/usuario.dart';
import '../mensagem/model/mensagem.dart';

import 'package:http/http.dart' as http;

class ConversationPage extends StatefulWidget {
  final Usuario usuario;

  const ConversationPage({super.key, required this.usuario});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  Usuario? selectedContact;
  final TextEditingController _messageController = TextEditingController();
  List<Mensagem> _messages = [];
  List<Usuario> _contatos = [];

  // Instâncias dos serviços
  final UsuarioService _usuarioService = UsuarioService();
  final MensagemService _mensagemService = MensagemService();
  final MensagemWebSocketService _webSocketService = MensagemWebSocketService();

  @override
  void initState() {
    super.initState();
    _inicializarWebSocket();
    _carregarContatos();
  }

  void _inicializarWebSocket() {

    _webSocketService.onMessage = (Mensagem mensagem) {
      if (_isMensagemRelevante(mensagem)) {
        _adicionarMensagem(mensagem);
      }
    };
    _webSocketService.conectarParaUsuario(widget.usuario.id);
  }

  bool _isMensagemRelevante(Mensagem mensagem) {
    if (selectedContact == null) return false;

    final euEnviei =
        mensagem.remetenteId == widget.usuario.id &&
        mensagem.destinatarioId == selectedContact!.id;

    final contatoEnviou =
        mensagem.remetenteId == selectedContact!.id &&
        mensagem.destinatarioId == widget.usuario.id;

    return euEnviei || contatoEnviou;
  }

  Future<void> _carregarContatos() async {
    final contatos = await _usuarioService.buscarContatos(widget.usuario.id);
    setState(() => _contatos = contatos);
  }

  Future<void> _carregarMensagens() async {
    if (selectedContact == null) return;


    try {
      final mensagens = await _mensagemService.buscarConversa(
        widget.usuario.id,
        selectedContact!.id,
      );

      setState(() {
        _messages = mensagens;
        // Ordenar por data
        _messages.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar mensagens');
    }
  }

  void _adicionarMensagem(Mensagem mensagem) {
    setState(() {
      _messages.add(mensagem);
    });
  }

  Future<void> _sendMessage() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty || selectedContact == null) return;


    // Criar objeto Mensagem para envio
    final mensagem = Mensagem(
      id: 0, // ID temporário
      remetenteId: widget.usuario.id,
      destinatarioId: selectedContact!.id,
      texto: texto,
      dataEnvio: DateTime.now(),
      remetenteNome: widget.usuario.nome,
    );

    _adicionarMensagem(mensagem);
    _messageController.clear();

    final sucesso = await _mensagemService.enviarMensagem(
      widget.usuario.id,
      selectedContact!.id,
      texto,
    );

    if (sucesso) {
      // 3. Também enviar via WebSocket se necessário
      try {
        _webSocketService.enviarMensagem(mensagem);
      } catch (e) {
        print('⚠️ Erro ao enviar via WebSocket: $e');
      }
    } else {
      // Remover a mensagem local se falhou
      setState(() {
        _messages.removeWhere((m) => m.id == 0 && m.texto == texto);
      });
      _mostrarErro('Erro ao enviar mensagem');
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  // Método auxiliar para verificar se a mensagem é do usuário atual
  bool _isMinhaMensagem(Mensagem mensagem) {
    return mensagem.remetenteId == widget.usuario.id;
  }

  // Formatar data para exibição
  String _formatarData(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
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
                // Header do usuário
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal,
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(widget.usuario.nome[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.usuario.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.usuario.telefone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de contatos
                Expanded(
                  child: _contatos.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum contato encontrado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _contatos.length,
                          itemBuilder: (context, index) {
                            final contato = _contatos[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(contato.nome[0].toUpperCase()),
                              ),
                              title: Text(contato.nome),
                              subtitle: Text(contato.telefone),
                              selected: selectedContact?.id == contato.id,
                              selectedTileColor: Colors.teal.withOpacity(0.1),
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
                      'Selecione um contato para conversar',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      // Cabeçalho do contato
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.teal,
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                selectedContact!.nome[0].toUpperCase(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedContact!.nome,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  selectedContact!.telefone,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Mensagens
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          child: _messages.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma mensagem ainda',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final mensagem = _messages[index];
                                    final isMine = _isMinhaMensagem(mensagem);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: isMine
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (!isMine)
                                            CircleAvatar(
                                              radius: 16,
                                              child: Text(
                                                selectedContact!.nome[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Card(
                                              color: isMine
                                                  ? Colors.teal
                                                  : Colors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      mensagem.texto,
                                                      style: TextStyle(
                                                        color: isMine
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatarData(
                                                        mensagem.dataEnvio,
                                                      ),
                                                      style: TextStyle(
                                                        color: isMine
                                                            ? Colors.white70
                                                            : Colors.grey,
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
                                                widget.usuario.nome[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      // Campo de digitação
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Digite uma mensagem...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                                maxLines: null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: _sendMessage,
                              ),
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
    _webSocketService.desconectar();
    super.dispose();
  }
}

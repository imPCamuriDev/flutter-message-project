import 'package:flutter/material.dart';
import '../usuarios/service/usuario_service.dart';
import '../mensagem/service/mensagem_service.dart';
import '../mensagem/service/mensagem_websocket_service.dart';
import '../usuarios/models/usuario.dart';
import '../mensagem/model/mensagem.dart';

import '../components/user_header.dart';
import '../components/contact_list.dart';
import '../components/contact_header.dart';
import '../components/message_list.dart';
import '../components/message_input.dart';

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

    final euEnviei = mensagem.remetenteId == widget.usuario.id &&
        mensagem.destinatarioId == selectedContact!.id;

    final contatoEnviou = mensagem.remetenteId == selectedContact!.id &&
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
        _messages = mensagens..sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
      });
    } catch (_) {
      _mostrarErro("Erro ao carregar mensagens");
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

    final mensagem = Mensagem(
      id: 0,
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
      try {
        _webSocketService.enviarMensagem(mensagem);
      } catch (_) {}
    } else {
      setState(() {
        _messages.removeWhere((m) => m.id == 0 && m.texto == texto);
      });
      _mostrarErro("Erro ao enviar mensagem");
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _webSocketService.desconectar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                UserHeader(usuario: widget.usuario),

                Expanded(
                  child: ContactList(
                    contatos: _contatos,
                    selectedContact: selectedContact,
                    onSelect: (contato) {
                      setState(() => selectedContact = contato);
                      _carregarMensagens();
                    },
                  ),
                ),
              ],
            ),
          ),

          // RIGHT SIDE
          Expanded(
            child: selectedContact == null
                ? const Center(
                    child: Text(
                      "Selecione um contato para conversar",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : Column(
                    children: [
                      ContactHeader(contato: selectedContact!),

                      Expanded(
                        child: MessageList(
                          messages: _messages,
                          meuId: widget.usuario.id,
                          contato: selectedContact!,
                        ),
                      ),

                      MessageInput(
                        controller: _messageController,
                        onSend: _sendMessage,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

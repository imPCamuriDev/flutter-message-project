import 'package:flutter/material.dart';
import '../usuarios/service/usuario_service.dart';
import '../mensagem/service/mensagem_websocket_service.dart';
import '../usuarios/models/usuario.dart'; 
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _telefoneController = TextEditingController();
  bool _loading = false;
  final UsuarioService _usuarioService = UsuarioService(); // Instância do serviço
  final MensagemWebSocketService _webSocketService = MensagemWebSocketService(); // Novo WebSocket

  Future<void> _fazerLogin() async {
    final telefone = _telefoneController.text.trim();
    
    if (telefone.isEmpty) {
      _mostrarErro('Digite seu telefone');
      return;
    }

    setState(() => _loading = true);

    try {
      final Usuario? usuario = await _usuarioService.login(telefone);

      setState(() => _loading = false);

      if (usuario != null && mounted) {
        // Conectar ao WebSocket com o novo serviço
        _webSocketService.conectarParaUsuario(usuario.id!);
        
        // Ir para home passando o objeto Usuario
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(usuario: usuario), // Agora é Usuario
          ),
        );
      } else {
        _mostrarErro('Usuário não encontrado');
      }
    } catch (e) {
      setState(() => _loading = false);
      _mostrarErro('Erro ao fazer login: $e');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _irParaRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Ícone
              const Icon(Icons.chat, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'Chat App',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              
              // Campo de telefone
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '+5511999999999',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onSubmitted: (_) => _fazerLogin(),
              ),
              const SizedBox(height: 24),
              
              // Botão de login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Entrar', 
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Link para registro
              TextButton(
                onPressed: _loading ? null : _irParaRegistro,
                child: const Text(
                  'Não tem conta? Registre-se',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _telefoneController.dispose();
    _webSocketService.desconectar(); // Limpeza do WebSocket
    super.dispose();
  }
}
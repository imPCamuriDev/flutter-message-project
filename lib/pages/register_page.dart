import 'package:flutter/material.dart';
import '../usuarios/service/usuario_service.dart';
import '../usuarios/models/usuario.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  bool _loading = false;
  final UsuarioService _usuarioService = UsuarioService(); // Instância do serviço

  Future<void> _registrar() async {
    final nome = _nomeController.text.trim();
    final telefone = _telefoneController.text.trim();
    
    if (nome.isEmpty || telefone.isEmpty) {
      _mostrarErro('Preencha todos os campos');
      return;
    }

    setState(() => _loading = true);

    try {

      final Usuario? usuario = await _usuarioService.registrar(new Usuario(nome: nome, telefone: telefone, criadoEm: DateTime.now()));

      setState(() => _loading = false);

      if (usuario != null && mounted) {
        _mostrarSucesso('Conta criada com sucesso!');
        
        // Aguardar um pouco antes de voltar para mostrar o feedback
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pop(context, usuario); // Volta para login podendo retornar o usuário
        }
      } else {
        _mostrarErro('Erro ao criar conta. Telefone já existe?');
      }
    } catch (e) {
      setState(() => _loading = false);
      _mostrarErro('Erro ao criar conta: $e');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem), 
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem), 
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _voltarParaLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : _voltarParaLogin,
        ),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              const Icon(Icons.person_add, size: 80, color: Colors.teal),
              const SizedBox(height: 32),
              
              // Campo nome
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Campo telefone
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '+5511999999999',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onSubmitted: (_) => _registrar(),
              ),
              const SizedBox(height: 32),
              
              // Botão de registro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _registrar,
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
                          'Criar Conta', 
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              
              // Texto informativo
              const SizedBox(height: 24),
              const Text(
                'Ao criar uma conta, você concorda com nossos Termos de Serviço',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
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
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}
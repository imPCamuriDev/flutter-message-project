import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  // Criar usuário (registro)
  static Future<Map<String, dynamic>?> registrar(String nome, String telefone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'telefone': telefone}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao registrar: $e');
      return null;
    }
  }
  
  // Buscar usuário por telefone (login simples)
  static Future<Map<String, dynamic>?> login(String telefone) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios'));
      
      if (response.statusCode == 200) {
        final List<dynamic> usuarios = jsonDecode(response.body);
        
        // Busca usuário com o telefone informado
        for (var usuario in usuarios) {
          if (usuario['telefone'] == telefone) {
            return usuario;
          }
        }
      }
      return null;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }
  
  // Buscar todos os contatos (menos o usuário logado)
  static Future<List<dynamic>> buscarContatos(int meuId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios'));
      
      if (response.statusCode == 200) {
        final List<dynamic> usuarios = jsonDecode(response.body);
        return usuarios.where((u) => u['id'] != meuId).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar contatos: $e');
      return [];
    }
  }
  
  // Enviar mensagem
  static Future<bool> enviarMensagem(int remetenteId, int destinatarioId, String texto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mensagens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'remetente_id': remetenteId,
          'destinatario_id': destinatarioId,
          'texto': texto,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return false;
    }
  }
  
  // Buscar conversa entre dois usuários
  static Future<List<dynamic>> buscarConversa(int usuario1Id, int usuario2Id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mensagens/$usuario1Id/$usuario2Id')
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Erro ao buscar conversa: $e');
      return [];
    }
  }
}
import '../model/mensagem.dart';
import '../../api/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MensagemService extends ApiService<Mensagem> {
  MensagemService() : super(
    baseUrl: 'http://localhost:3000',
    fromJson: Mensagem.fromJson,
    toJson: (mensagem) => mensagem.toJson(),
  );
  
  Future<List<Mensagem>> buscarConversa(int usuarioAtualId, int contatoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mensagens/$usuarioAtualId/$contatoId')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((item) => fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar conversa: $e');
      return [];
    }
  }
  
  Future<bool> enviarMensagem(Mensagem mensagem) async {
    final resultado = await criar(mensagem, 'mensagens');
    return resultado != null;
  }
}
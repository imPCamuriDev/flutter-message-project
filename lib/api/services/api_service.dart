import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService<T> {
  final String baseUrl;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  
  ApiService({
    required this.baseUrl,
    required this.fromJson,
    required this.toJson,
  });
  
  // Buscar um item por ID
  Future<T?> buscarPorId(int id, String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));
      
      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Buscar todos os itens
  Future<List<T>> buscarTodos(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((item) => fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Criar novo item
  Future<T?> criar(T item, String endpoint) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(toJson(item)),
      );
      
      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Buscar com filtro personalizado
  Future<List<T>> buscarComFiltro(
    String endpoint, 
    bool Function(T) filtro
  ) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final todosItens = dados.map((item) => fromJson(item)).toList();
        return todosItens.where(filtro).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
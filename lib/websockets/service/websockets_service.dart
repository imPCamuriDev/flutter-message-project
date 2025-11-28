import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static Function(Map<String, dynamic>)? onMessage;
  
  // Conectar ao WebSocket
  static void conectar(int usuarioId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:3000'),
    );
    
    // Registrar usuário
    _channel!.sink.add(jsonEncode({
      'tipo': 'registrar',
      'usuario_id': usuarioId,
    }));
    
    // Escutar mensagens
    _channel!.stream.listen((mensagem) {
      final dados = jsonDecode(mensagem);
      if (onMessage != null) {
        onMessage!(dados);
      }
    });
    
    print('✅ WebSocket conectado para usuário $usuarioId');
  }
  
  // Desconectar
  static void desconectar() {
    _channel?.sink.close();
    print('❌ WebSocket desconectado');
  }
}

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService<T> {
  WebSocketChannel? _channel;
  Function(T)? onMessage;
  final T Function(Map<String, dynamic>) _fromJson;

  WebSocketService(this._fromJson);

  void conectar(int usuarioId) {
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

    // Registrar usuário
    _channel!.sink.add(
      jsonEncode({'tipo': 'registrar', 'usuario_id': usuarioId}),
    );

    // Escutar mensagens com tratamento melhorado
    _channel!.stream.listen(
      (mensagem) {
        print('📨 Mensagem WebSocket recebida: $mensagem');

        try {
          final dados = jsonDecode(mensagem);

          // Verificar se é uma mensagem do tipo que esperamos
          if (dados is Map<String, dynamic>) {
            // Se for uma mensagem de chat, processar
            if (dados['tipo'] == 'nova_mensagem' || dados['texto'] != null) {
              final objetoConvertido = _fromJson(dados);
              if (onMessage != null) {
                print('✅ Mensagem processada: ${objetoConvertido}');
                onMessage!(objetoConvertido);
              }
            } else {
              print('📝 Mensagem de outro tipo: ${dados['tipo']}');
            }
          }
        } catch (e) {
          print('❌ Erro ao processar mensagem WebSocket: $e');
          print('Mensagem recebida: $mensagem');
        }
      },
      onError: (error) {
        print('❌ Erro no WebSocket: $error');
      },
      onDone: () {
        print('📡 WebSocket desconectado');
      },
    );

    print('✅ WebSocket conectado para usuário $usuarioId');
  }

  void enviar(T dados) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(dados));
      } catch (e) {
        print('❌ Erro ao enviar mensagem WebSocket: $e');
      }
    }
  }

  void desconectar() {
    _channel?.sink.close();
    print('❌ WebSocket desconectado');
  }
}

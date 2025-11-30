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
        print('📨 WebSocket RAW recebido: $mensagem');

        try {
          final dados = jsonDecode(mensagem);

          if (dados is Map<String, dynamic>) {
            print('📦 Tipo de mensagem: ${dados['tipo']}');

            // CASO 1: Mensagem vem dentro de envelope 'nova_mensagem'
            if (dados['tipo'] == 'nova_mensagem') {
              print('📬 Processando nova_mensagem com envelope');

              // Extrair a mensagem de dentro do envelope
              final mensagemData = dados['mensagem'];

              if (mensagemData != null &&
                  mensagemData is Map<String, dynamic>) {
                print('📄 Dados da mensagem: $mensagemData');

                try {
                  final objetoConvertido = _fromJson(mensagemData);
                  print('✅ Mensagem convertida com sucesso');

                  if (onMessage != null) {
                    onMessage!(objetoConvertido);
                  }
                } catch (e) {
                  print('❌ Erro ao converter mensagem do envelope: $e');
                }
              }
            }
            // CASO 2: Mensagem vem diretamente (sem envelope)
            else if (dados['texto'] != null) {
              print('📬 Processando mensagem direta');

              try {
                final objetoConvertido = _fromJson(dados);
                print('✅ Mensagem direta convertida com sucesso');

                if (onMessage != null) {
                  onMessage!(objetoConvertido);
                }
              } catch (e) {
                print('❌ Erro ao converter mensagem direta: $e');
              }
            }
            // CASO 3: Mensagem de sistema (registro, etc)
            else {
              print('📝 Mensagem de sistema ignorada: ${dados['tipo']}');
            }
          }
        } catch (e, stackTrace) {
          print('❌ Erro ao processar mensagem WebSocket: $e');
          print('Stack trace: $stackTrace');
          print('Mensagem recebida: $mensagem');
        }
      },
      onError: (error) {
        print('❌ Erro no stream WebSocket: $error');
      },
      onDone: () {
        print('📡 WebSocket desconectado');
      },
    );

    print('✅ WebSocket conectado para usuário $usuarioId');
  }

  void enviar(Map<String, dynamic> dados) {
    if (_channel != null) {
      try {
        final json = jsonEncode(dados);
        _channel!.sink.add(json);
        print('📤 Mensagem enviada via WebSocket: $json');
      } catch (e) {
        print('❌ Erro ao enviar mensagem WebSocket: $e');
      }
    } else {
      print('⚠️ WebSocket não está conectado');
    }
  }

  void desconectar() {
    _channel?.sink.close();
    print('❌ WebSocket desconectado');
  }
}

import '../../websockets/service/websockets_service.dart';
import '../model/mensagem.dart';

class MensagemWebSocketService extends WebSocketService<Mensagem> {
  MensagemWebSocketService() : super(Mensagem.fromJson);
  
  void conectarParaUsuario(int usuarioId) {
    conectar(usuarioId);
  }
  
  void enviarMensagem(Mensagem mensagem) {
    enviar(mensagem);
  }
}
import '../models/usuario.dart';
import '../../api/services/api_service.dart';

class UsuarioService extends ApiService<Usuario> {
  UsuarioService() : super(
    baseUrl: 'http://localhost:3000',
    fromJson: Usuario.fromJson,
    toJson: (usuario) => usuario.toJson(),
  );
  
  // Métodos específicos para usuários
  Future<Usuario?> registrar(String nome, String telefone, DateTime criadoEm) async {
    final usuarioTemp = Usuario(
      id: 0, // ID temporário
      nome: nome,
      telefone: telefone,
      criadoEm: criadoEm,
    );
    return await criar(usuarioTemp, 'usuarios');
  }
  
  Future<Usuario?> login(String telefone) async {
    final usuarios = await buscarComFiltro(
      'usuarios', 
      (usuario) => usuario.telefone == telefone
    );
    return usuarios.isNotEmpty ? usuarios.first : null;
  }
  
  Future<List<Usuario>> buscarContatos(int meuId) async {
    return await buscarComFiltro(
      'usuarios',
      (usuario) => usuario.id != meuId
    );
  }
}
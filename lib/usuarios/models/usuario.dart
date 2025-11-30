class Usuario {
  final int id;
  final String nome;
  final String telefone;
  final DateTime? criadoEm;
  
  Usuario({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.criadoEm,
  });
  
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      telefone: json['telefone'] ?? '',
      criadoEm: DateTime.parse(json['criado_em'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'criado_em': criadoEm?.toIso8601String(),
    };
  }
}
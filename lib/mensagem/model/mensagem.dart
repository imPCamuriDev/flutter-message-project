class Mensagem {
  final int id;
  final int remetenteId;
  final int destinatarioId;
  final String texto;
  final DateTime dataEnvio;
  final String? remetenteNome; // Pode ser null
  final String? destinatarioNome; // Pode ser null
  
  Mensagem({
    required this.id,
    required this.remetenteId,
    required this.destinatarioId,
    required this.texto,
    required this.dataEnvio,
    this.remetenteNome,
    this.destinatarioNome,
  });
  
  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] ?? 0, // Valor padrão se for null
      remetenteId: json['remetente_id'] ?? 0,
      destinatarioId: json['destinatario_id'] ?? 0,
      texto: json['texto'] ?? '', // Valor padrão se for null
      dataEnvio: DateTime.parse(json['enviado_em'] ?? DateTime.now().toIso8601String()), // Campo correto é 'enviado_em'
      remetenteNome: json['remetente_nome'],
      destinatarioNome: json['destinatario_nome'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remetente_id': remetenteId,
      'destinatario_id': destinatarioId,
      'texto': texto,
      'enviado_em': dataEnvio.toIso8601String(), // Campo correto
      if (remetenteNome != null) 'remetente_nome': remetenteNome,
      if (destinatarioNome != null) 'destinatario_nome': destinatarioNome,
    };
  }
}
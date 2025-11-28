import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lista de status (lado esquerdo)
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Cabeçalho
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal,
                  child: const Row(
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Meu Status
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Text('EU', style: TextStyle(fontSize: 18)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meu status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Clique para adicionar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Título "Recentes"
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recentes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Lista de status de contatos
                Expanded(
                  child: ListView(
                    children: [
                      _buildStatusItem(
                        name: 'Pedro Gabriel',
                        time: 'Hoje, 10:30',
                        initial: 'P',
                        viewed: false,
                      ),
                      _buildStatusItem(
                        name: 'Maria Silva',
                        time: 'Hoje, 09:15',
                        initial: 'M',
                        viewed: false,
                      ),
                      _buildStatusItem(
                        name: 'João Santos',
                        time: 'Ontem, 23:45',
                        initial: 'J',
                        viewed: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Área de visualização (lado direito)
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Clique em um status para visualizar',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String name,
    required String time,
    required String initial,
    required bool viewed,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: viewed ? Colors.grey : Colors.teal,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          child: Text(initial),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(time),
      onTap: () {},
    );
  }
}
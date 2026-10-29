import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {
      'title': 'Haircut & Styling',
      'duration': '45 Menit',
      'durationMinutes': 45,
      'price': 'Rp 85.000',
      'priceValue': 85000.0,
      'icon': Icons.content_cut,
    },
    {
      'title': 'Creambath & Scalp Care',
      'duration': '60 Menit',
      'durationMinutes': 60,
      'price': 'Rp 120.000',
      'priceValue': 120000.0,
      'icon': Icons.spa,
    },
    {
      'title': 'Hair Coloring',
      'duration': '120 Menit',
      'durationMinutes': 120,
      'price': 'Rp 350.000',
      'priceValue': 350000.0,
      'icon': Icons.palette,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Salon', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Menghapus seluruh riwayat rute dan kembali ke LoginScreen ('/')
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, size: 36, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pesan perawatan favorit Anda tanpa antre langsung.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pilihan Perawatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...services.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(item['icon'] as IconData, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${item['duration']}\n${item['price']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/booking', arguments: item);
                  },
                  child: const Text('Pesan'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
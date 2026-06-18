import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 1. Inisialisasi client Supabase
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _historyFuture;

  // 2. Fungsi untuk mengambil data dari tabel 'calculation_history'
  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final response = await supabase
        .from('calculation_history')
        .select('*')
        .order('id', ascending: false); // Mengurutkan dari yang terbaru
    
    return List<Map<String, dynamic>>.from(response);
  }

  @override
void initState() {
  super.initState();
  _historyFuture = _fetchHistory(); // Membuka data pertama kali
}

  // ================= FUNGSI HAPUS SATU DATA =================
  Future<void> _deleteSingleHistory(int id) async {
    try {
      await supabase.from('calculation_history').delete().eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus')),
        );
      }

      setState(() {
        _historyFuture = _fetchHistory(); // Membaca ulang database setelah dihapus
      });// Segarkan halaman
    } catch (e) {
      debugPrint("❌ Gagal menghapus data: $e");
    }
  }

  // ================= FUNGSI HAPUS SEMUA DATA =================
  Future<void> _deleteAllHistory() async {
    try {
      // Menghapus semua baris yang id-nya tidak sama dengan 0 (alias semuanya)
      await supabase.from('calculation_history').delete().neq('id', 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua riwayat berhasil dibersihkan')),
        );
      }
      setState(() {
        _historyFuture = _fetchHistory(); // Membaca ulang database (hasilnya nanti kosong)
      }); // Segarkan halaman
    } catch (e) {
      debugPrint("❌ Gagal mengosongkan riwayat: $e");
    }
  }

  // ================= DIALOG KONFIRMASI HAPUS SEMUA =================
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Riwayat?'),
          content: const Text('Tindakan ini akan menghapus seluruh histori kalkulator Anda secara permanen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllHistory();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kalkulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Bersihkan Semua',
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada histori'));
          }

          final historyList = snapshot.data!;

          return ListView.builder(
            itemCount: historyList.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = historyList[index];
              // Mendefinisikan itemId dari database agar bisa dihapus
              final int itemId = item['id'] ?? 0; 
              
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.calculate, color: Colors.white),
                  ),
                  title: Text(
                    item['expression'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // 🔥 SOLUSI: Menggabungkan Teks Hasil dan Tombol Hapus ke dalam satu Row
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Agar row tidak memakan tempat terlalu lebar
                    children: [
                      Text(
                        '= ${item['result'] ?? ''}',
                        style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {
                          _deleteSingleHistory(itemId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
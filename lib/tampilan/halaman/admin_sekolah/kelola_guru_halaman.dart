import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/admin_roles_provider.dart';

/// Halaman Kelola Guru (Admin Sekolah)
class KelolaGuruHalaman extends StatefulWidget {
  const KelolaGuruHalaman({super.key});

  @override
  State<KelolaGuruHalaman> createState() => _KelolaGuruHalamanState();
}

class _KelolaGuruHalamanState extends State<KelolaGuruHalaman> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<AdminRolesProvider>().fetchGuruPembimbing();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredList(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((g) {
      final nama = (g['nama'] ?? '').toString().toLowerCase();
      final nip = (g['nip'] ?? '').toString().toLowerCase();
      return nama.contains(_searchQuery.toLowerCase()) ||
          nip.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Guru Pembimbing'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari guru (Nama / NIP)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(UkuranAplikasi.radiusSedang),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: Consumer<AdminRolesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = _getFilteredList(provider.guruList);

                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada data guru'));
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final guru = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text((guru['nama'] ?? '?')[0].toUpperCase()),
                          ),
                          title: Text(guru['nama'] ?? '-'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NIP: ${guru['nip'] ?? '-'}'),
                              if (guru['mata_pelajaran'] != null)
                                Text('Mapel: ${guru['mata_pelajaran']}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(guru),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTambahDialog() {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final nipController = TextEditingController();
    final mapelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Guru'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nipController,
                  decoration: const InputDecoration(labelText: 'NIP'),
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: mapelController,
                  decoration: const InputDecoration(
                      labelText: 'Mata Pelajaran (Opsional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email (Opsional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      (v?.length ?? 0) < 6 ? 'Minimal 6 karakter' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                final success =
                    await context.read<AdminRolesProvider>().tambahGuru({
                  'nama_lengkap': namaController.text.trim(),
                  'nip': nipController.text.trim(),
                  'mata_pelajaran': mapelController.text.trim(),
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                  'password': passwordController.text,
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil menambah guru'
                          : 'Gagal menambah guru'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> guru) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Guru'),
        content:
            Text('Hapus guru ${guru['nama']}? User terkait juga akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Asumsi ID user tersedia di dalam map guru
              // Pastikan query backend menyertakan id_user atau id_guru yang sesuai
              // Backend createGuru insert ke user lalu guru_pembimbing (id_user).
              // Fetch guru biasanya join atau select * form guru_pembimbing.
              // Cek id field. Usually id_user if coming from User table join, or id_guru_pembimbing + id_user FK.
              // AdminSekolahController.getGuruPembimbing returns g.* which has id_user.

              final idUser = guru['id_user'];
              if (idUser != null) {
                final success =
                    await context.read<AdminRolesProvider>().hapusGuru(idUser);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil menghapus guru'
                          : 'Gagal menghapus guru'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('ID User tidak ditemukan'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

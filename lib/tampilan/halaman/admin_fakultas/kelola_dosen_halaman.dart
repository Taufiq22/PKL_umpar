import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/admin_roles_provider.dart';

/// Halaman Kelola Dosen (Admin Fakultas)
class KelolaDosenHalaman extends StatefulWidget {
  const KelolaDosenHalaman({super.key});

  @override
  State<KelolaDosenHalaman> createState() => _KelolaDosenHalamanState();
}

class _KelolaDosenHalamanState extends State<KelolaDosenHalaman> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<AdminRolesProvider>().fetchDosenPembimbing();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredList(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((d) {
      final nama = (d['nama'] ?? '').toString().toLowerCase();
      final nidn = (d['nidn'] ?? '').toString().toLowerCase();
      return nama.contains(_searchQuery.toLowerCase()) ||
          nidn.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Dosen Pembimbing'),
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
                hintText: 'Cari dosen (Nama / NIDN)...',
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
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = _getFilteredList(provider.dosenList);

                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada data dosen'));
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final dosen = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child:
                                Text((dosen['nama'] ?? '?')[0].toUpperCase()),
                          ),
                          title: Text(dosen['nama'] ?? '-'),
                          subtitle: Text('NIDN: ${dosen['nidn'] ?? '-'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(dosen),
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
    final nidnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Dosen'),
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
                  controller: nidnController,
                  decoration: const InputDecoration(labelText: 'NIDN'),
                  validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
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
                    await context.read<AdminRolesProvider>().tambahDosen({
                  'nama_lengkap': namaController.text.trim(),
                  'nidn': nidnController.text.trim(),
                  'username': usernameController.text.trim(),
                  'email': emailController.text.trim(),
                  'password': passwordController.text,
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil menambah dosen'
                          : 'Gagal menambah dosen'),
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

  void _confirmDelete(Map<String, dynamic> dosen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dosen'),
        content: Text(
            'Hapus dosen ${dosen['nama']}? User terkait juga akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Note: dosen map has 'id_user' or 'id_dosen'?
              // Usually the list from getDosenPembimbing returns full join or specific columns
              // Check AdminFakultasController.getDosenPembimbing query: SELECT d.* ...
              // d.* contains id_user usually if mapped.
              // Wait, createDosen inserts into dosen_pembimbing (id_user, ...).
              // So 'id_user' should be present if selected properly.
              // Logic check: query SELECT d.* from dosen_pembimbing d.
              // Does d have id_user? Yes, it's a FK.
              final idUser = dosen['id_user'];
              if (idUser != null) {
                final success =
                    await context.read<AdminRolesProvider>().hapusDosen(idUser);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Berhasil menghapus dosen'
                          : 'Gagal menghapus dosen'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengguna.dart';
import '../../../provider/users_provider.dart';

/// Halaman Kelola User
/// Digunakan oleh Admin untuk CRUD semua akun pengguna
class KelolaUserHalaman extends StatefulWidget {
  const KelolaUserHalaman({super.key});

  @override
  State<KelolaUserHalaman> createState() => _KelolaUserHalamanState();
}

class _KelolaUserHalamanState extends State<KelolaUserHalaman> {
  String _filterRole = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<UsersProvider>().ambilSemuaUser();
  }

  List<Pengguna> _getFilteredList(List<Pengguna> list) {
    var filtered = list;

    // Filter by role
    if (_filterRole != 'Semua') {
      filtered = filtered.where((u) => u.role.label == _filterRole).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.namaLengkap
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              u.username.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTambahUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(UkuranAplikasi.radiusSedang),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // User list
          Expanded(
            child: Consumer<UsersProvider>(
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

                final filteredList = _getFilteredList(provider.daftarUsers);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: WarnaAplikasi.textLight),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pengguna',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: WarnaAplikasi.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: UkuranAplikasi.paddingSedang),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(filteredList[index]);
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

  Widget _buildUserCard(Pengguna user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
          child: Text(
            user.namaLengkap.isNotEmpty
                ? user.namaLengkap[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: _getRoleColor(user.role),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.namaLengkap,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusBadge(user.isActive),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('@${user.username}'),
            const SizedBox(height: 4),
            _buildRoleChip(user.role),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? WarnaAplikasi.success : WarnaAplikasi.error)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? WarnaAplikasi.success : WarnaAplikasi.error,
        ),
      ),
    );
  }

  Widget _buildRoleChip(RolePengguna role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getRoleColor(role),
        ),
      ),
    );
  }

  Color _getRoleColor(RolePengguna role) {
    switch (role) {
      case RolePengguna.admin:
        return Colors.purple;
      case RolePengguna.adminFakultas:
        return Colors.indigo;
      case RolePengguna.adminSekolah:
        return Colors.teal;
      case RolePengguna.mahasiswa:
        return WarnaAplikasi.primary;
      case RolePengguna.siswa:
        return WarnaAplikasi.info;
      case RolePengguna.dosen:
        return WarnaAplikasi.success;
      case RolePengguna.guru:
        return Colors.orange;
      case RolePengguna.instansi:
        return Colors.brown;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pengguna'),
        content: DropdownButtonFormField<String>(
          value: _filterRole,
          decoration: const InputDecoration(labelText: 'Role'),
          items: [
            'Semua',
            ...RolePengguna.values.map((r) => r.label),
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _filterRole = v ?? 'Semua'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterRole = 'Semua');
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  void _showTambahUserDialog() {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();

    // Controllers per Role
    final nimController = TextEditingController();
    final prodiController = TextEditingController();
    final fakultasController = TextEditingController();
    final niController = TextEditingController(); // NIDN or NIP or NISN
    final sekolahController = TextEditingController();
    final jurusanController = TextEditingController();
    final kelasController = TextEditingController();
    final jabatanController = TextEditingController();
    final alamatController = TextEditingController();
    final kontakController = TextEditingController();

    RolePengguna selectedRole = RolePengguna.mahasiswa;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Dynamic Fields Calculation
          List<Widget> roleFields = [];

          if (selectedRole == RolePengguna.mahasiswa) {
            roleFields = [
              TextFormField(
                controller: nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: prodiController,
                decoration: const InputDecoration(labelText: 'Program Studi'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fakultasController,
                decoration: const InputDecoration(labelText: 'Fakultas'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
            ];
          } else if (selectedRole == RolePengguna.siswa) {
            roleFields = [
              TextFormField(
                controller: niController,
                decoration: const InputDecoration(labelText: 'NISN'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sekolahController,
                decoration: const InputDecoration(labelText: 'Asal Sekolah'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: jurusanController,
                decoration: const InputDecoration(labelText: 'Jurusan'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kelasController,
                decoration: const InputDecoration(labelText: 'Kelas'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
            ];
          } else if (selectedRole == RolePengguna.dosen) {
            roleFields = [
              TextFormField(
                controller: niController,
                decoration: const InputDecoration(labelText: 'NIDN'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
            ];
          } else if (selectedRole == RolePengguna.guru) {
            roleFields = [
              TextFormField(
                controller: niController,
                decoration: const InputDecoration(labelText: 'NIP'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
            ];
          } else if (selectedRole == RolePengguna.instansi) {
            roleFields = [
              TextFormField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat Instansi'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kontakController,
                decoration:
                    const InputDecoration(labelText: 'Kontak (HP/Email)'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
            ];
          } else if (selectedRole == RolePengguna.adminFakultas) {
            roleFields = [
              TextFormField(
                controller: fakultasController,
                decoration: const InputDecoration(labelText: 'Fakultas'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: jabatanController,
                decoration: const InputDecoration(labelText: 'Jabatan'),
              ),
            ];
          } else if (selectedRole == RolePengguna.adminSekolah) {
            roleFields = [
              TextFormField(
                controller: sekolahController,
                decoration: const InputDecoration(labelText: 'Sekolah'),
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: jabatanController,
                decoration: const InputDecoration(labelText: 'Jabatan'),
              ),
            ];
          }

          return AlertDialog(
            title: const Text('Tambah Pengguna'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) =>
                          (v?.length ?? 0) < 6 ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RolePengguna>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: RolePengguna.values
                          .map((r) =>
                              DropdownMenuItem(value: r, child: Text(r.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedRole = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const Text('Data Profil',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...roleFields,
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

                    final Map<String, dynamic> payload = {
                      'nama_lengkap': namaController.text.trim(),
                      'username': usernameController.text.trim(),
                      'email': emailController.text.trim(),
                      'password': passwordController.text,
                      'role': selectedRole.kode,
                    };

                    // Append role fields
                    if (selectedRole == RolePengguna.mahasiswa) {
                      payload['nim'] = nimController.text.trim();
                      payload['prodi'] = prodiController.text.trim();
                      payload['fakultas'] = fakultasController.text.trim();
                    } else if (selectedRole == RolePengguna.siswa) {
                      payload['nisn'] = niController.text.trim();
                      payload['sekolah'] = sekolahController.text.trim();
                      payload['jurusan'] = jurusanController.text.trim();
                      payload['kelas'] = kelasController.text.trim();
                    } else if (selectedRole == RolePengguna.dosen) {
                      payload['nidn'] = niController.text.trim();
                    } else if (selectedRole == RolePengguna.guru) {
                      payload['nip'] = niController.text.trim();
                    } else if (selectedRole == RolePengguna.instansi) {
                      payload['alamat'] = alamatController.text.trim();
                      payload['kontak'] = kontakController.text.trim();
                    } else if (selectedRole == RolePengguna.adminFakultas) {
                      payload['fakultas'] = fakultasController.text.trim();
                      payload['jabatan'] = jabatanController.text.trim();
                    } else if (selectedRole == RolePengguna.adminSekolah) {
                      payload['sekolah'] = sekolahController.text.trim();
                      payload['jabatan'] = jabatanController.text.trim();
                    }

                    final success =
                        await context.read<UsersProvider>().tambahUser(payload);
                    _showResultSnackbar(success, 'menambah pengguna');
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleUserAction(String action, Pengguna user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _confirmDeleteUser(user);
        break;
    }
  }

  void _showEditUserDialog(Pengguna user) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: user.namaLengkap);
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email ?? '');
    RolePengguna selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Pengguna'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration:
                        const InputDecoration(labelText: 'Nama Lengkap'),
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
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RolePengguna>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: RolePengguna.values
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedRole = v);
                    },
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
                      await context.read<UsersProvider>().updateUser(
                    user.idUser,
                    {
                      'nama_lengkap': namaController.text.trim(),
                      'username': usernameController.text.trim(),
                      'email': emailController.text.trim(),
                      'role': selectedRole.kode,
                    },
                  );
                  _showResultSnackbar(success, 'mengubah pengguna');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(Pengguna user) async {
    final success = await context.read<UsersProvider>().updateUser(
      user.idUser,
      {'is_active': user.isActive ? 0 : 1},
    );
    _showResultSnackbar(
        success, user.isActive ? 'menonaktifkan' : 'mengaktifkan');
  }

  void _confirmDeleteUser(Pengguna user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${user.namaLengkap}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<UsersProvider>().hapusUser(user.idUser);
              _showResultSnackbar(success, 'menghapus pengguna');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showResultSnackbar(bool success, String action) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Berhasil $action' : 'Gagal $action'),
          backgroundColor:
              success ? WarnaAplikasi.success : WarnaAplikasi.error,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/pengguna.dart';
import '../../../../provider/users_provider.dart';
import '../../../../konfigurasi/konstanta.dart';

class UserFormHalaman extends StatefulWidget {
  final Pengguna? user;

  const UserFormHalaman({super.key, this.user});

  @override
  State<UserFormHalaman> createState() => _UserFormHalamanState();
}

class _UserFormHalamanState extends State<UserFormHalaman> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  RolePengguna _selectedRole = RolePengguna.mahasiswa;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _namaController.text = widget.user!.namaLengkap;
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email ?? '';
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsersProvider>();
    final data = {
      'nama_lengkap': _namaController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
      'role': _selectedRole.kode,
      'status_aktif': _isActive ? 1 : 0,
    };

    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }

    bool success;
    if (widget.user == null) {
      success = await provider.tambahUser(data);
    } else {
      success = await provider.updateUser(widget.user!.idUser, data);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.user == null
                ? 'User berhasil ditambah'
                : 'User berhasil diupdate')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal menyimpan user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Tambah User' : 'Edit User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.user == null
                      ? 'Password'
                      : 'Password (Kosongkan jika tidak diganti)',
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (v) => widget.user == null && v!.isEmpty
                    ? 'Password tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RolePengguna>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: RolePengguna.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.label),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      context.watch<UsersProvider>().isLoading ? null : _submit,
                  child: context.watch<UsersProvider>().isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

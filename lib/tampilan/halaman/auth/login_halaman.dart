import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';
import '../../../provider/auth_provider.dart';

/// Halaman Login
class LoginHalaman extends StatefulWidget {
  const LoginHalaman({super.key});

  @override
  State<LoginHalaman> createState() => _LoginHalamanState();
}

class _LoginHalamanState extends State<LoginHalaman> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  RolePengguna _selectedRole = RolePengguna.mahasiswa;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
      _selectedRole.kode,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        RuteAplikasi.getBerandaByRole(_selectedRole.kode),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login gagal'),
          backgroundColor: WarnaAplikasi.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingBesar),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo dan Judul
                _buildHeader(),

                const SizedBox(height: 40),

                // Tab Masuk/Daftar
                _buildTabs(),

                const SizedBox(height: 32),

                // Form Fields
                _buildRoleDropdown(),
                const SizedBox(height: 16),
                _buildUsernameField(),
                const SizedBox(height: 16),
                _buildPasswordField(),

                const SizedBox(height: 32),

                // Tombol Login
                _buildLoginButton(),

                const SizedBox(height: 16),

                // Link bantuan
                _buildHelpLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logoUmpar.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Nama Aplikasi
        Text(
          TeksAplikasi.namaAplikasi,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: WarnaAplikasi.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          TeksAplikasi.tagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WarnaAplikasi.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          TeksAplikasi.universitas,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: WarnaAplikasi.primary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: WarnaAplikasi.background,
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusKecil),
        ),
        child: Text(
          TeksAplikasi.masuk,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: WarnaAplikasi.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper untuk mendapatkan label dan hint berdasarkan role
  String _getUsernameLabel() {
    switch (_selectedRole) {
      case RolePengguna.mahasiswa:
        return 'NIM';
      case RolePengguna.siswa:
        return 'NISN';
      case RolePengguna.dosen:
        return 'NIDN';
      case RolePengguna.guru:
        return 'NIP';
      case RolePengguna.instansi:
        return 'Email / Username';
      case RolePengguna.admin:
      case RolePengguna.adminFakultas:
      case RolePengguna.adminSekolah:
        return 'Username';
    }
  }

  String _getUsernameHint() {
    switch (_selectedRole) {
      case RolePengguna.mahasiswa:
        return 'Masukkan NIM anda';
      case RolePengguna.siswa:
        return 'Masukkan NISN anda';
      case RolePengguna.dosen:
        return 'Masukkan NIDN anda';
      case RolePengguna.guru:
        return 'Masukkan NIP anda';
      case RolePengguna.instansi:
        return 'Masukkan email atau username';
      case RolePengguna.admin:
      case RolePengguna.adminFakultas:
      case RolePengguna.adminSekolah:
        return 'Masukkan username admin';
    }
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUsernameLabel(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: _getUsernameHint(),
          ),
          keyboardType: _selectedRole == RolePengguna.instansi
              ? TextInputType.emailAddress
              : TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${_getUsernameLabel()} tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: WarnaAplikasi.textLight,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Masuk Sebagai',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RolePengguna>(
          initialValue: _selectedRole,
          decoration: const InputDecoration(),
          items: RolePengguna.values
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.label),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRole = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ElevatedButton(
          onPressed: auth.isLoading ? null : _handleLogin,
          child: auth.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Masuk'),
        );
      },
    );
  }

  Widget _buildHelpLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum punya akun?'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RuteAplikasi.daftar);
              },
              child: const Text(
                'Daftar Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Bantuan'),
                content: const Text(
                  'Jika anda mengalami kendala saat login atau belum memiliki akun, '
                  'silakan hubungi admin fakultas atau sekolah masing-masing.\n\n'
                  'Email: admin@umpar.ac.id\n'
                  'Telp: (0421) 123456',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Bantuan'),
        ),
        Text(
          '${TeksAplikasi.lupaPassword} Hubungi administrator UMPAR.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/auth_provider.dart';

/// Halaman Pendaftaran
class DaftarHalaman extends StatefulWidget {
  const DaftarHalaman({super.key});

  @override
  State<DaftarHalaman> createState() => _DaftarHalamanState();
}

class _DaftarHalamanState extends State<DaftarHalaman> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _nimNisnController = TextEditingController();
  final _alamatController = TextEditingController(); // For Instansi
  final _kontakController = TextEditingController(); // For Instansi

  RolePengguna _selectedRole = RolePengguna.mahasiswa;
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _nimNisnController.dispose();
    _alamatController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  String _getLabelForIdNumber() {
    switch (_selectedRole) {
      case RolePengguna.mahasiswa:
        return 'NIM';
      case RolePengguna.siswa:
        return 'NISN';
      case RolePengguna.dosen:
        return 'NIDN';
      case RolePengguna.guru:
        return 'NIP';
      default:
        return 'ID Number';
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final data = {
      'nama_lengkap': _namaController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole.kode,
    };

    // Tambah field khusus berdasarkan role
    if (_selectedRole == RolePengguna.mahasiswa) {
      data['nim'] = _nimNisnController.text.trim();
    } else if (_selectedRole == RolePengguna.siswa) {
      data['nisn'] = _nimNisnController.text.trim();
    } else if (_selectedRole == RolePengguna.dosen) {
      data['nidn'] = _nimNisnController.text.trim();
    } else if (_selectedRole == RolePengguna.guru) {
      data['nip'] = _nimNisnController.text.trim();
    } else if (_selectedRole == RolePengguna.instansi) {
      data['alamat'] = _alamatController.text.trim();
      data['kontak'] = _kontakController.text.trim();
    }

    final success = await authProvider.register(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan tunggu aktivasi akun.'),
          backgroundColor: WarnaAplikasi.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Pendaftaran gagal'),
          backgroundColor: WarnaAplikasi.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UkuranAplikasi.paddingBesar),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data di bawah untuk mendaftar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WarnaAplikasi.textSecondary,
                      ),
                ),

                const SizedBox(height: 32),

                // Role Selection
                _buildRoleDropdown(),
                const SizedBox(height: 16),

                // Nama Lengkap
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // NIM/NISN
                // NIM/NISN/NIDN/NIP (Sembunyikan untuk Instansi)
                if (_selectedRole != RolePengguna.instansi)
                  _buildTextField(
                    controller: _nimNisnController,
                    label: _getLabelForIdNumber(),
                    hint: 'Masukkan ${_getLabelForIdNumber()}',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field ini tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                // Field khusus Instansi
                if (_selectedRole == RolePengguna.instansi) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _alamatController,
                    label: 'Alamat',
                    hint: 'Masukkan alamat lengkap',
                    icon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _kontakController,
                    label: 'Kontak',
                    hint: 'Email / No HP',
                    icon: Icons.phone_outlined,
                    validator: (value) => null, // Optional
                  ),
                ],
                const SizedBox(height: 16),

                // Username
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Buat username',
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.length < 4) {
                      return 'Username minimal 4 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Buat password',
                  obscure: _obscurePassword,
                  onToggle: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Konfirmasi Password
                _buildPasswordField(
                  controller: _konfirmasiController,
                  label: 'Konfirmasi Password',
                  hint: 'Ketik ulang password',
                  obscure: _obscureKonfirmasi,
                  onToggle: () {
                    setState(() => _obscureKonfirmasi = !_obscureKonfirmasi);
                  },
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Tombol Daftar
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Daftar Sekarang'),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Sebagai',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RolePengguna>(
          initialValue: _selectedRole,
          decoration: const InputDecoration(),
          items: const [
            RolePengguna.mahasiswa,
            RolePengguna.siswa,
            RolePengguna.dosen,
            RolePengguna.guru,
            RolePengguna.instansi,
          ]
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: WarnaAplikasi.textLight),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                const Icon(Icons.lock_outline, color: WarnaAplikasi.textLight),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: WarnaAplikasi.textLight,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

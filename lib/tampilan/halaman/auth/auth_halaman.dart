import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../konfigurasi/rute.dart';
import '../../../provider/auth_provider.dart';

/// Halaman Authentication (Login & Register) dengan TabBar
class AuthHalaman extends StatefulWidget {
  final int initialTab;

  const AuthHalaman({super.key, this.initialTab = 0});

  @override
  State<AuthHalaman> createState() => _AuthHalamanState();
}

class _AuthHalamanState extends State<AuthHalaman>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Logo dan Header
            _buildHeader(),

            const SizedBox(height: 32),

            // Tab Bar
            _buildTabBar(),

            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _LoginForm(),
                  _RegisterForm(),
                ],
              ),
            ),
          ],
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

  Widget _buildTabBar() {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: UkuranAplikasi.paddingBesar),
      decoration: BoxDecoration(
        color: WarnaAplikasi.background,
        borderRadius: BorderRadius.circular(UkuranAplikasi.radiusSedang),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UkuranAplikasi.radiusKecil),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: WarnaAplikasi.primary,
        unselectedLabelColor: WarnaAplikasi.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Masuk'),
          Tab(text: 'Daftar'),
        ],
      ),
    );
  }
}

/// Form Login
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
      '', // Role is auto-detected by backend
    );

    if (success && mounted) {
      // Get actual role from auth provider after login
      final role = authProvider.pengguna?.role.kode ?? 'mahasiswa';
      Navigator.pushReplacementNamed(
        context,
        RuteAplikasi.getBerandaByRole(role),
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
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: UkuranAplikasi.paddingBesar),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username/NIM/NISN Field
            _buildLabeledField(
              label: 'NIM / NISN / Username',
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan NIM, NISN, NIDN, NIP, atau username',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            _buildLabeledField(
              label: 'Password',
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: WarnaAplikasi.textLight,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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
            ),

            const SizedBox(height: 32),

            // Login Button
            Consumer<AuthProvider>(
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
            ),

            const SizedBox(height: 16),

            // Help Link
            Center(
              child: Text(
                '${TeksAplikasi.lupaPassword} Hubungi administrator UMPAR.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Form Register
class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _nimNisnController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kontakController = TextEditingController();

  // Siswa-specific fields
  final _sekolahController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _kelasController = TextEditingController();

  // Mahasiswa-specific fields
  final _prodiController = TextEditingController();
  final _fakultasController = TextEditingController();

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
    _sekolahController.dispose();
    _jurusanController.dispose();
    _kelasController.dispose();
    _prodiController.dispose();
    _fakultasController.dispose();
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
      case RolePengguna.admin:
      case RolePengguna.adminFakultas:
      case RolePengguna.adminSekolah:
      case RolePengguna.instansi:
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
      data['prodi'] = _prodiController.text.trim();
      data['fakultas'] = _fakultasController.text.trim();
    } else if (_selectedRole == RolePengguna.siswa) {
      data['nisn'] = _nimNisnController.text.trim();
      data['sekolah'] = _sekolahController.text.trim();
      data['jurusan'] = _jurusanController.text.trim();
      data['kelas'] = _kelasController.text.trim();
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
      // Switch to login tab
      DefaultTabController.of(context).animateTo(0);
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
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: UkuranAplikasi.paddingBesar),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Selection
            _buildLabeledField(
              label: 'Daftar Sebagai',
              child: DropdownButtonFormField<RolePengguna>(
                key: ValueKey(_selectedRole),
                initialValue: _selectedRole,
                decoration: const InputDecoration(),
                items: RolePengguna.values
                    .where((r) =>
                        r == RolePengguna.mahasiswa ||
                        r == RolePengguna.siswa ||
                        r ==
                            RolePengguna
                                .instansi) // Mahasiswa, Siswa, dan Instansi dapat register
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
            ),
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

            // NIM/NISN/NIDN/NIP
            if (_selectedRole != RolePengguna.instansi) ...[
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
              const SizedBox(height: 16),
            ],

            // Field khusus Mahasiswa (Prodi, Fakultas)
            if (_selectedRole == RolePengguna.mahasiswa) ...[
              _buildTextField(
                controller: _prodiController,
                label: 'Program Studi',
                hint: 'Contoh: Teknik Informatika',
                icon: Icons.school_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Program studi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fakultasController,
                label: 'Fakultas',
                hint: 'Contoh: Fakultas Teknik',
                icon: Icons.account_balance_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fakultas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Field khusus Siswa (Sekolah, Jurusan, Kelas)
            if (_selectedRole == RolePengguna.siswa) ...[
              _buildTextField(
                controller: _sekolahController,
                label: 'Nama Sekolah',
                hint: 'Contoh: SMK Negeri 1 Parepare',
                icon: Icons.school_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama sekolah tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jurusanController,
                label: 'Jurusan',
                hint: 'Contoh: Rekayasa Perangkat Lunak',
                icon: Icons.category_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jurusan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _kelasController,
                label: 'Kelas',
                hint: 'Contoh: XI RPL 1',
                icon: Icons.class_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kelas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Field khusus Instansi
            if (_selectedRole == RolePengguna.instansi) ...[
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
                validator: (value) => null,
              ),
              const SizedBox(height: 16),
            ],

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
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
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
              onToggle: () =>
                  setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Register Button
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
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

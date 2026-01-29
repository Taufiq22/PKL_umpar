import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../data/model/pengguna.dart';
import '../../../konfigurasi/rute.dart';
import '../../../provider/auth_provider.dart';

/// Halaman Profil - UI/UX Upgraded
class ProfilHalaman extends StatefulWidget {
  final bool showAppBar;

  const ProfilHalaman({super.key, this.showAppBar = false});

  @override
  State<ProfilHalaman> createState() => _ProfilHalamanState();
}

class _ProfilHalamanState extends State<ProfilHalaman> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pengguna = auth.pengguna;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: WarnaAplikasi.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Back button if standalone
                      if (widget.showAppBar)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withAlpha(40),
                          child: Text(
                            pengguna?.namaLengkap.isNotEmpty == true
                                ? pengguna!.namaLengkap[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pengguna?.namaLengkap ?? 'Nama Pengguna',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pengguna?.role.label ?? 'Role',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Quick Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeaderStat(
                              Icons.person_outline,
                              pengguna?.username ?? '-',
                              'Username',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withAlpha(50),
                            ),
                            _buildHeaderStat(
                              pengguna?.isActive == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              pengguna?.isActive == true ? 'Aktif' : 'Nonaktif',
                              'Status',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Section
                _buildSectionTitle('Akun'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _buildMenuItem(
                    Icons.edit_outlined,
                    'Edit Profil',
                    'Ubah nama dan informasi pribadi',
                    () => _showEditProfilDialog(context, auth),
                  ),
                  _buildMenuItem(
                    Icons.lock_outline,
                    'Ubah Password',
                    'Ganti kata sandi akun',
                    () => _showUbahPasswordDialog(context, auth),
                  ),
                ]),

                const SizedBox(height: 24),

                // Other Section
                _buildSectionTitle('Lainnya'),
                const SizedBox(height: 12),
                _buildMenuCard([
                  _buildMenuItem(
                    Icons.help_outline,
                    'Bantuan',
                    'FAQ dan kontak support',
                    () => _showBantuanDialog(context),
                  ),
                  _buildMenuItem(
                    Icons.info_outline,
                    'Tentang Aplikasi',
                    'Versi dan informasi',
                    () => _showTentangDialog(context),
                  ),
                ]),

                const SizedBox(height: 32),

                // Logout Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: WarnaAplikasi.error.withAlpha(50)),
                  ),
                  child: Material(
                    color: WarnaAplikasi.error.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _handleLogout(auth),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: WarnaAplikasi.error),
                            SizedBox(width: 12),
                            Text(
                              'Keluar dari Akun',
                              style: TextStyle(
                                color: WarnaAplikasi.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: WarnaAplikasi.textSecondary,
          ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: WarnaAplikasi.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: WarnaAplikasi.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: WarnaAplikasi.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await auth.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, RuteAplikasi.login);
      }
    }
  }

  void _showEditProfilDialog(BuildContext context, AuthProvider auth) {
    if (auth.pengguna == null) return;

    final role = auth.pengguna!.role;
    final user = auth.pengguna!;

    // Core controllers
    final namaController = TextEditingController(text: user.namaLengkap);
    final emailController = TextEditingController(text: user.email);

    // Role specific controllers
    final Map<String, TextEditingController> extraControllers = {};

    if (user is Mahasiswa) {
      extraControllers['nim'] = TextEditingController(text: user.nim);
      extraControllers['prodi'] = TextEditingController(text: user.prodi);
      extraControllers['fakultas'] = TextEditingController(text: user.fakultas);
    } else if (user is Siswa) {
      extraControllers['nisn'] = TextEditingController(text: user.nisn);
      extraControllers['jurusan'] = TextEditingController(text: user.jurusan);
      extraControllers['sekolah'] = TextEditingController(text: user.sekolah);
      extraControllers['kelas'] = TextEditingController(text: user.kelas);
    } else if (user is DosenPembimbing) {
      extraControllers['nidn'] = TextEditingController(text: user.nidn);
      extraControllers['jabatan'] = TextEditingController(text: user.jabatan);
    } else if (user is GuruPembimbing) {
      extraControllers['nip'] = TextEditingController(text: user.nip);
      extraControllers['mata_pelajaran'] =
          TextEditingController(text: user.mataPelajaran);
    } else if (user is Instansi) {
      extraControllers['alamat'] = TextEditingController(text: user.alamat);
      extraControllers['kontak'] = TextEditingController(text: user.kontak);
      extraControllers['bidang'] = TextEditingController(text: user.bidang);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Edit Profil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Nama & Email (Always available)
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: role == RolePengguna.instansi
                      ? 'Nama Instansi'
                      : 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              // Dynamic Fields based on Role
              if (role == RolePengguna.mahasiswa) ...[
                const SizedBox(height: 16),
                _buildTextField(
                    extraControllers['nim']!, 'NIM', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['prodi']!, 'Program Studi',
                    Icons.school_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['fakultas']!, 'Fakultas',
                    Icons.apartment_outlined),
              ] else if (role == RolePengguna.siswa) ...[
                const SizedBox(height: 16),
                _buildTextField(
                    extraControllers['nisn']!, 'NISN', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['jurusan']!, 'Jurusan',
                    Icons.school_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['sekolah']!, 'Asal Sekolah',
                    Icons.apartment_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                    extraControllers['kelas']!, 'Kelas', Icons.class_outlined),
              ] else if (role == RolePengguna.dosen) ...[
                const SizedBox(height: 16),
                _buildTextField(
                    extraControllers['nidn']!, 'NIDN', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['jabatan']!,
                    'Jabatan (Opsional)', Icons.work_outline),
              ] else if (role == RolePengguna.guru) ...[
                const SizedBox(height: 16),
                _buildTextField(
                    extraControllers['nip']!, 'NIP', Icons.badge_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['mata_pelajaran']!,
                    'Mata Pelajaran', Icons.book_outlined),
              ] else if (role == RolePengguna.instansi) ...[
                const SizedBox(height: 16),
                _buildTextField(extraControllers['alamat']!, 'Alamat Lengkap',
                    Icons.location_on_outlined,
                    maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['kontak']!,
                    'Kontak / No. Telepon', Icons.phone_outlined),
                const SizedBox(height: 16),
                _buildTextField(extraControllers['bidang']!,
                    'Bidang Usaha (Opsional)', Icons.business_outlined),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Prepare data map
                    final data = <String, dynamic>{
                      'nama_lengkap': namaController.text.trim(),
                      'email': emailController.text.trim(),
                    };

                    // Merge extra controllers
                    extraControllers.forEach((key, controller) {
                      data[key] = controller.text.trim();
                    });

                    final success = await auth.updateProfil(data);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Profil berhasil diperbarui'
                              : 'Gagal memperbarui profil'),
                          backgroundColor: success
                              ? WarnaAplikasi.success
                              : WarnaAplikasi.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showUbahPasswordDialog(BuildContext context, AuthProvider auth) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ubah Password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: oldPasswordController,
                obscureText: obscureOld,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscureOld ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setModalState(() => obscureOld = !obscureOld),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setModalState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setModalState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password baru tidak sama'),
                          backgroundColor: WarnaAplikasi.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password minimal 6 karakter'),
                          backgroundColor: WarnaAplikasi.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    final success = await auth.ubahPassword(
                      passwordLama: oldPasswordController.text,
                      passwordBaru: newPasswordController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Password berhasil diubah'
                              : 'Gagal mengubah password'),
                          backgroundColor: success
                              ? WarnaAplikasi.success
                              : WarnaAplikasi.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ubah Password'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showBantuanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: WarnaAplikasi.primary),
            SizedBox(width: 8),
            Text('Bantuan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hubungi kami jika ada pertanyaan:'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.email_outlined, 'support@magangku.id'),
            const SizedBox(height: 12),
            _buildContactRow(Icons.phone_outlined, '0411-123456'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: WarnaAplikasi.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: WarnaAplikasi.primary),
        ),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }

  void _showTentangDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: WarnaAplikasi.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('MagangKu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sistem Informasi Manajemen PKL & Magang'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WarnaAplikasi.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Versi 1.0.0',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            const Text('© 2024 UMPAR'),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi ini dikembangkan untuk memudahkan pengelolaan kegiatan Praktik Kerja Lapangan (PKL) dan Magang.',
              style: TextStyle(
                fontSize: 12,
                color: WarnaAplikasi.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

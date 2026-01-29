import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../konfigurasi/konstanta.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/nilai_provider.dart';

class NilaiInputHalaman extends StatefulWidget {
  final int idPengajuan;
  final String namaMahasiswa;

  const NilaiInputHalaman({
    super.key,
    required this.idPengajuan,
    required this.namaMahasiswa,
  });

  @override
  State<NilaiInputHalaman> createState() => _NilaiInputHalamanState();
}

class _NilaiInputHalamanState extends State<NilaiInputHalaman> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controllers
  final _aspekController = TextEditingController();
  final _nilaiController = TextEditingController();
  final _komentarController = TextEditingController();

  // Predefined aspects based on role
  List<String> _aspekList = [];
  String? _selectedAspek;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAspekList();
      _loadExistingNilai();
    });
  }

  @override
  void dispose() {
    _aspekController.dispose();
    _nilaiController.dispose();
    _komentarController.dispose();
    super.dispose();
  }

  void _setupAspekList() {
    final userRole = context.read<AuthProvider>().pengguna?.role;

    if (userRole == RolePengguna.instansi) {
      _aspekList = [
        'Kedisiplinan',
        'Kinerja',
        'Tanggung Jawab',
        'Sikap Kerja',
        'Kerjasama Tim',
      ];
    } else {
      // Dosen/Guru
      _aspekList = [
        'Kedisiplinan',
        'Kemampuan Teknis',
        'Kualitas Laporan',
        'Komunikasi',
        'Sikap',
      ];
    }
    setState(() {});
  }

  Future<void> _loadExistingNilai() async {
    setState(() => _isLoading = true);
    await context.read<NilaiProvider>().ambilNilai(widget.idPengajuan);
    setState(() => _isLoading = false);
  }

  Future<void> _simpanNilai() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAspek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih aspek penilaian'),
          backgroundColor: WarnaAplikasi.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<NilaiProvider>();
    final nilaiAngka = double.tryParse(_nilaiController.text) ?? 0;

    final success = await provider.inputNilai(
      idPengajuan: widget.idPengajuan,
      aspekPenilaian: _selectedAspek!,
      nilaiAngka: nilaiAngka,
      komentar:
          _komentarController.text.isNotEmpty ? _komentarController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai berhasil disimpan'),
          backgroundColor: WarnaAplikasi.success,
        ),
      );
      // Clear form
      _selectedAspek = null;
      _nilaiController.clear();
      _komentarController.clear();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal menyimpan nilai'),
          backgroundColor: WarnaAplikasi.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Penilaian - ${widget.namaMahasiswa}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Existing nilai list
                  Consumer<NilaiProvider>(
                    builder: (context, provider, _) {
                      if (provider.daftarNilai.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Belum ada nilai yang diinput.'),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nilai yang Sudah Diinput',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...provider.daftarNilai.map((n) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(n.aspekPenilaian ?? 'Aspek'),
                                  subtitle: Text(n.komentar ?? '-'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          WarnaAplikasi.primary.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      n.nilaiAngka.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: WarnaAplikasi.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 8),
                          Text(
                            'Rata-rata: ${provider.rataRataNilai.toStringAsFixed(1)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(height: 32),
                        ],
                      );
                    },
                  ),

                  // Input form
                  Text(
                    'Tambah Nilai Baru',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Aspek dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedAspek,
                          decoration: const InputDecoration(
                            labelText: 'Aspek Penilaian',
                            border: OutlineInputBorder(),
                          ),
                          items: _aspekList
                              .map((a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedAspek = val),
                          validator: (val) =>
                              val == null ? 'Pilih aspek penilaian' : null,
                        ),
                        const SizedBox(height: 16),

                        // Nilai input
                        TextFormField(
                          controller: _nilaiController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nilai (0-100)',
                            border: OutlineInputBorder(),
                            suffixText: '/ 100',
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Masukkan nilai';
                            }
                            final num = double.tryParse(val);
                            if (num == null || num < 0 || num > 100) {
                              return 'Nilai harus 0-100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Komentar
                        TextFormField(
                          controller: _komentarController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Komentar (Opsional)',
                            border: OutlineInputBorder(),
                            hintText: 'Berikan feedback untuk peserta...',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _simpanNilai,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Nilai'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

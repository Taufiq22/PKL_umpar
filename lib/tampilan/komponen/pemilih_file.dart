/// Pemilih File Diperkaya
/// UMPAR Magang & PKL System
///
/// Komponen untuk upload file dengan preview

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../konfigurasi/konstanta.dart';

/// Widget untuk memilih file dengan preview
class PemilihFile extends StatefulWidget {
  final List<String>? allowedExtensions;
  final int? maxFiles;
  final int? maxSizeBytes;
  final void Function(List<File>) onFilesSelected;
  final List<File>? initialFiles;
  final String label;
  final String hint;

  const PemilihFile({
    super.key,
    this.allowedExtensions,
    this.maxFiles = 1,
    this.maxSizeBytes,
    required this.onFilesSelected,
    this.initialFiles,
    this.label = 'Pilih File',
    this.hint = 'Klik untuk memilih file',
  });

  @override
  State<PemilihFile> createState() => _PemilihFileState();
}

class _PemilihFileState extends State<PemilihFile> {
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      _selectedFiles = List.from(widget.initialFiles!);
    }
  }

  Future<void> _pilihFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: (widget.maxFiles ?? 1) > 1,
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        final files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        // Check file size if maxSizeBytes is set
        if (widget.maxSizeBytes != null) {
          for (final file in files) {
            final size = await file.length();
            if (size > widget.maxSizeBytes!) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'File ${file.path.split('/').last} terlalu besar. Maksimal ${(widget.maxSizeBytes! / 1024 / 1024).toStringAsFixed(1)} MB',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }
        }

        // Limit files count
        final maxFiles = widget.maxFiles ?? 1;
        final newFiles = files.take(maxFiles).toList();

        setState(() {
          _selectedFiles = newFiles;
        });
        widget.onFilesSelected(newFiles);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void _hapusFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pilihFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: WarnaAplikasi.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hint,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildAllowedTypesText(),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFilePreview(file, index);
          }),
        ],
      ],
    );
  }

  String _buildAllowedTypesText() {
    if (widget.allowedExtensions != null) {
      return 'Format: ${widget.allowedExtensions!.join(', ').toUpperCase()}';
    }
    return 'Semua format file';
  }

  Widget _buildFilePreview(File file, int index) {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getFileColor(extension).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, fit: BoxFit.cover),
                )
              : Center(
                  child: Icon(
                    _getFileIcon(extension),
                    color: _getFileColor(extension),
                  ),
                ),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: FutureBuilder<int>(
          future: file.length(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(_formatFileSize(snapshot.data!));
            }
            return const Text('...');
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _hapusFile(index),
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
  }
}

/// Widget untuk preview gambar
class PreviewGambar extends StatelessWidget {
  final String? urlGambar;
  final File? fileGambar;
  final double ukuran;
  final double radius;
  final VoidCallback? onTap;
  final Widget? placeholder;

  const PreviewGambar({
    super.key,
    this.urlGambar,
    this.fileGambar,
    this.ukuran = 100,
    this.radius = 12,
    this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: ukuran,
        height: ukuran,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (fileGambar != null) {
      return Image.file(
        fileGambar!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (urlGambar != null && urlGambar!.isNotEmpty) {
      return Image.network(
        urlGambar!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Center(
          child: Icon(
            Icons.image,
            size: ukuran * 0.4,
            color: Colors.grey[400],
          ),
        );
  }
}

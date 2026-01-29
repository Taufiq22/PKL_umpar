import 'package:flutter/material.dart';
import '../../konfigurasi/konstanta.dart';

enum TipeStatus {
  info,
  sukses,
  warning,
  error,
}

class KartuStatus extends StatelessWidget {
  final String status;
  final TipeStatus tipe;
  final Color? customColor;

  const KartuStatus({
    super.key,
    required this.status,
    this.tipe = TipeStatus.info,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (customColor != null) {
      backgroundColor = customColor!.withAlpha(25); // 0.1 opacity
      textColor = customColor!;
    } else {
      switch (tipe) {
        case TipeStatus.sukses:
          backgroundColor = WarnaAplikasi.success.withValues(alpha: 0.1);
          textColor = WarnaAplikasi.success;
          break;
        case TipeStatus.warning:
          backgroundColor = WarnaAplikasi.warning.withValues(alpha: 0.1);
          textColor = WarnaAplikasi.warning;
          break;
        case TipeStatus.error:
          backgroundColor = WarnaAplikasi.error.withValues(alpha: 0.1);
          textColor = WarnaAplikasi.error;
          break;
        case TipeStatus.info:
          backgroundColor = WarnaAplikasi.primary.withValues(alpha: 0.1);
          textColor = WarnaAplikasi.primary;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

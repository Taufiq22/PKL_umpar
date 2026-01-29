import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../konfigurasi/konstanta.dart';

/// Komponen Shimmer Loading untuk berbagai bentuk
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
    this.isCircle = false,
  });

  /// Shimmer untuk card list
  const ShimmerLoading.card({super.key})
      : width = double.infinity,
        height = 120,
        borderRadius = 16,
        isCircle = false;

  /// Shimmer untuk avatar
  const ShimmerLoading.avatar({super.key, this.width = 50, this.height = 50})
      : borderRadius = 25,
        isCircle = true;

  /// Shimmer untuk text line
  const ShimmerLoading.text({super.key, this.width = 100, this.height = 16})
      : borderRadius = 4,
        isCircle = false;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

/// Shimmer untuk list pengajuan
class ShimmerListPengajuan extends StatelessWidget {
  final int itemCount;

  const ShimmerListPengajuan({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(UkuranAplikasi.paddingSedang),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UkuranAplikasi.radiusCard),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

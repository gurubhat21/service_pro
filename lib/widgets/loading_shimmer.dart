import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart'; // Ensure shimmer package is in pubspec.yaml

class LoadingShimmer extends StatelessWidget {
  final int itemCount;

  const LoadingShimmer({Key? key, this.itemCount = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Note: Assuming shimmer package is installed. If not, this is a fallback basic implementation.
    // Replace with true Shimmer widget when package is available.
    
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surface;
    final highlightColor = theme.colorScheme.surface.withOpacity(0.5);

    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: baseColor,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        color: baseColor,
                      ),
                    ],
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

import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImagePainterWidget extends StatelessWidget {
  const ImagePainterWidget({
    super.key,
    required this.imageBytes,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ảnh sự cố',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: hasImage
                  ? Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có ảnh. Chọn Camera hoặc Thư viện để tải ảnh lên.',
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Thư viện'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

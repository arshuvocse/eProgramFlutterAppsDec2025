import 'dart:io';
import 'package:flutter/material.dart';

class AttendancePhotoPreview extends StatelessWidget {
  final File? photo;
  const AttendancePhotoPreview({super.key, this.photo});

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return const Center(
        child: Text(
          'No photo captured yet.\nTap "Punch In" to take a photo.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        photo!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File? pickedImage) onPickImage;
  final String? existingImageUrl;
  final File? selectedImage;

  const UserImagePicker({
    super.key,
    required this.onPickImage,
    required this.existingImageUrl,
    this.selectedImage,
  });

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      widget.onPickImage(File(pickedImage.path));
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close the bottom sheet
                    _pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera),
                  label: Text(
                    'Camera',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close the bottom sheet
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: Text(
                    'Gallery',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _showImageSourceActionSheet,
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey,
            foregroundImage: widget.selectedImage != null
                ? FileImage(widget.selectedImage!)
                : (widget.existingImageUrl != null
                    ? NetworkImage(widget.existingImageUrl!)
                    : null),
            child:
                widget.selectedImage == null && widget.existingImageUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.black.withOpacity(0.3),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        )
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {

  final void Function(File? pickedImage) onPickImage;
  final String? exisitingImageUrl;

  const UserImagePicker({super.key, required this.onPickImage, required this.exisitingImageUrl, String? existingImageUrl});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  // file not necessarily set, may be null
  File? _pickedImageFile;

  void _pickImage(ImageSource source) async {
    // pickImage op returns an Xfile and is assigned to var called pickedImage
    final pickedImage = await ImagePicker().pickImage(
      source: source, 
      imageQuality: 100, 
      maxWidth: 150,
    );

    // if no image is selected, return without setting the state
    if (pickedImage == null) {
      return;
    }

    // ensure that the build method is triggered again to preview image
    // create a file object based on the path
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    // after preview, call widget
    widget.onPickImage(_pickedImageFile!);
  }

  // Method to show action sheet with options for Camera and Gallery
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close the bottom sheet
                    _pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close the bottom sheet
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (widget.exisitingImageUrl != null 
                  ? NetworkImage(widget.exisitingImageUrl!) 
                  : null),
          child: _pickedImageFile == null && widget.exisitingImageUrl == null
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        TextButton.icon(
          onPressed: _showImageSourceActionSheet, 
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary
            ),
          ),
        )
      ],
    );
  }
}
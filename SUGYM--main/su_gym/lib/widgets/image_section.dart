import 'package:flutter/material.dart';

class ImageSection extends StatelessWidget {
  const ImageSection({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: double.infinity, // Adjusts to the full width of its parent
      height: 720, // Set the height as needed
      fit: BoxFit.cover,
    );
  }
}

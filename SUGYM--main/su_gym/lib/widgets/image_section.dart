import 'package:flutter/material.dart';




class ImageSection extends StatelessWidget {
  const ImageSection({Key? key, required this.image}) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        image,
        fit: BoxFit.cover,
         color: Colors.black.withOpacity(0.4),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }
}

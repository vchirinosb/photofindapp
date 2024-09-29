import 'package:flutter/material.dart';
import 'package:photofindapp/models/photo_model.dart';

class PhotoTile extends StatelessWidget {
  final PhotoModel photo;
  final Function(PhotoModel) onFavorite;

  const PhotoTile({super.key, required this.photo, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Here you can implement navigation to a detailed view if desired
      },
      child: Stack(
        children: [
          Image.network(photo.imageUrl, fit: BoxFit.cover),
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () => onFavorite(photo),
            ),
          ),
        ],
      ),
    );
  }
}

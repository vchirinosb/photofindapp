import 'package:flutter/material.dart';
import 'package:photofindapp/models/photo_model.dart';
import 'package:photofindapp/screens/photo_detail_screen.dart';

class PhotoTile extends StatelessWidget {
  final PhotoModel photo;
  final Function(PhotoModel) onFavorite;
  final bool isFavorite;

  const PhotoTile({
    super.key,
    required this.photo,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo, isFavorite: isFavorite),
          ),
        );

        if (result != null && result is bool) {
          onFavorite(photo);
        }
      },
      child: Stack(
        children: [
          Hero(
            tag: photo.id,
            child: Image.network(
              photo.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),

          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () => onFavorite(photo),
            ),
          ),
        ],
      ),
    );
  }
}

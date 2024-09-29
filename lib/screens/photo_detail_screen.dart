import 'package:flutter/material.dart';
import 'package:photofindapp/models/photo_model.dart';

class PhotoDetailScreen extends StatefulWidget {
  final PhotoModel photo;
  final bool isFavorite;

  const PhotoDetailScreen(
      {super.key, required this.photo, required this.isFavorite});

  @override
  PhotoDetailScreenState createState() => PhotoDetailScreenState();
}

class PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.title ?? 'Photo Detail'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: widget.photo.id,
              child: Image.network(
                widget.photo.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.photo.title ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Photographer: ${widget.photo.photographerName ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isFavorite ? Colors.red : Colors.grey,
        onPressed: () {
          setState(() {
            isFavorite = !isFavorite;
          });
          Navigator.pop(context, isFavorite);
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }
}

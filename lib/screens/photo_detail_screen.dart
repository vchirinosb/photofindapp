import 'package:flutter/material.dart';
import 'package:photofindapp/models/photo_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:toastification/toastification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photofindapp/services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  String get userId => FirebaseFirestore.instance.collection('users').doc().id;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  Future<void> _downloadImage(String imageUrl) async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        var dio = Dio();
        var response = await dio.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );

        final directory = await getDownloadsDirectory();

        if (directory != null) {
          String filePath =
              '${directory.path}/${widget.photo.title ?? 'downloaded_image'}.jpg';

          File file = File(filePath);
          await file.writeAsBytes(response.data);

          if (mounted) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              title: const Text('Success!'),
              description: const Text('Image downloaded successfully!'),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        } else {
          if (mounted) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              title: const Text('Error!'),
              description: const Text('Failed to access Downloads directory.'),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            title: const Text('Error!'),
            description: Text('Failed to download image: $e'),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      }
    } else {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.warning,
          title: const Text('Permission Denied'),
          description:
              const Text('Please allow storage permission to download images.'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _saveFavorite() async {
    if (isFavorite) {
      return;
    }

    await _firestoreService.saveFavoritePhoto(userId, widget.photo);

    if (mounted) {
      setState(() {
        isFavorite = true;
      });
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text('Added to Favorites'),
        description: Text('Photo "${widget.photo.title}" added to favorites!'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  void _removeFavorite() async {
    await _firestoreService.removeFavoritePhoto(userId, widget.photo.id);

    if (mounted) {
      setState(() {
        isFavorite = false;
      });
      toastification.show(
        context: context,
        type: ToastificationType.info,
        title: const Text('Removed from Favorites'),
        description:
            Text('Photo "${widget.photo.title}" removed from favorites!'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEFA),
        title: Text(widget.photo.title ?? 'Photo Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? const Color(0xFF98FF98)
                  : const Color(0xFFD3D3D3),
            ),
            onPressed: () {
              if (!isFavorite) {
                _saveFavorite();
              } else {
                _removeFavorite();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _downloadImage(widget.photo.imageUrl);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
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
                        color: Color(0xFFF4A460),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Photographer: ${widget.photo.photographerName ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF808080),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            isFavorite ? const Color(0xFF98FF98) : const Color(0xFFD3D3D3),
        onPressed: () {
          if (!isFavorite) {
            _saveFavorite();
          } else {
            _removeFavorite();
          }
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }
}

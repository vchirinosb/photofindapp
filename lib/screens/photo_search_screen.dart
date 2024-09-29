import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:photofindapp/models/photo_model.dart';
import 'package:photofindapp/services/api_services.dart';
import 'package:photofindapp/services/firestore_service.dart';
import 'package:photofindapp/widgets/photo_service_dropdown.dart';
import 'package:photofindapp/widgets/photo_tile.dart';

class PhotoSearchScreen extends StatefulWidget {
  const PhotoSearchScreen({super.key});

  @override
  PhotoSearchScreenState createState() => PhotoSearchScreenState();
}

class PhotoSearchScreenState extends State<PhotoSearchScreen> {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final List<PhotoModel> _photos = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String _selectedService = 'Unsplash';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger();

  void _searchPhotos() async {
    setState(() {
      _isLoading = true;
      _photos.clear();
      _page = 1; // Reset page
    });

    try {
      List<PhotoModel> photos;

      switch (_selectedService) {
        case 'Pexels':
          photos = await _apiService.searchPexels(_searchQuery);
          break;
        case 'Pixabay':
          photos = await _apiService.searchPixabay(_searchQuery);
          break;
        case 'Unsplash':
        default:
          photos = await _apiService.searchUnsplash(_searchQuery);
          break;
      }

      setState(() {
        _photos.addAll(photos);
      });
    } catch (e) {
      _logger.e('Error fetching photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMorePhotos() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
      _page++;
    });

    try {
      List<PhotoModel> morePhotos;

      switch (_selectedService) {
        case 'Pexels':
          morePhotos =
              await _apiService.searchPexels(_searchQuery, page: _page);
          break;
        case 'Pixabay':
          morePhotos =
              await _apiService.searchPixabay(_searchQuery, page: _page);
          break;
        case 'Unsplash':
        default:
          morePhotos =
              await _apiService.searchUnsplash(_searchQuery, page: _page);
          break;
      }

      setState(() {
        _photos.addAll(morePhotos);
      });
    } catch (e) {
      _logger.e('Error loading more photos: $e');
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _saveFavorite(PhotoModel photo) async {
    if (photo.id.isNotEmpty) {
      final userId =
          FirebaseFirestore.instance.collection('users').doc(photo.id).id;

      await _firestoreService.saveFavoritePhoto(userId, photo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            PhotoServiceDropdown(
              onChanged: (value) {
                setState(() {
                  _selectedService = value!;
                });
              },
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchQuery = _searchController.text;
                    _searchPhotos();
                  },
                ),
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!scrollInfo.metrics.atEdge &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _loadMorePhotos();
                    return true;
                  }
                  return false;
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return PhotoTile(photo: photo, onFavorite: _saveFavorite);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

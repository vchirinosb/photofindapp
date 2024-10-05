import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:logger/logger.dart';
import 'package:photofindapp/models/photo_model.dart';
import 'package:photofindapp/services/api_services.dart';
import 'package:photofindapp/services/firestore_service.dart';
import 'package:photofindapp/widgets/photo_tile.dart';
import 'package:toastification/toastification.dart';

class PhotoSearchScreen extends StatefulWidget {
  const PhotoSearchScreen({super.key});
  @override
  PhotoSearchScreenState createState() => PhotoSearchScreenState();
}

class PhotoSearchScreenState extends State<PhotoSearchScreen> {
  late final ApiService _apiService;
  final FirestoreService _firestoreService = FirestoreService();
  final List<PhotoModel> _photos = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String _selectedService = 'Unsplash';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(context);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _loadMorePhotos();
    }
  }

  void _searchPhotos() async {
    setState(() {
      _isLoading = true;
      _photos.clear();
      _page = 1;
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

      if (mounted) {
        setState(() {
          _photos.addAll(photos);
        });

        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Photos Loaded'),
          description: Text('${photos.length} photos loaded successfully!'),
        );
      }
    } catch (e) {
      _logger.e('Error fetching photos: $e');

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error'),
          description: const Text('Failed to load photos.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadMorePhotos() async {
    if (_isFetchingMore || _isLoading) return;

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
      if (mounted) {
        setState(() {
          _photos.addAll(morePhotos);
        });
      }
    } catch (e) {
      _logger.e('Error loading more photos: $e');

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error'),
          description: const Text('Failed to load more photos.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMore = false;
        });
      }
    }
  }

  void _saveFavorite(PhotoModel photo) async {
    if (photo.id.isNotEmpty) {
      final userId = FirebaseFirestore.instance.collection('users').doc().id;

      await _firestoreService.saveFavoritePhoto(userId, photo);

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Added to Favorites'),
          description: Text('Photo "${photo.title}" added to favorites!'),
        );
      }
    } else {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error'),
          description: const Text('Failed to add photo to favorites.'),
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
            _buildServiceSwitcher(),
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
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification &&
                      _scrollController.position.pixels ==
                          _scrollController.position.maxScrollExtent &&
                      !_isFetchingMore) {
                    _loadMorePhotos();
                  }
                  return true;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ..._photos.map((photo) {
                        return StaggeredGridTile.fit(
                          crossAxisCellCount: 1,
                          child: PhotoTile(
                            photo: photo,
                            onFavorite: _saveFavorite,
                            isFavorite: false,
                          ),
                        );
                      }),
                      if (_isFetchingMore)
                        const StaggeredGridTile.fit(
                          crossAxisCellCount: 2,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSwitcher() {
    final services = ['Unsplash', 'Pexels', 'Pixabay'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(services.length, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedService = services[index];
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: _selectedService == services[index]
                  ? Colors.greenAccent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              services[index],
              style: TextStyle(
                color: _selectedService == services[index]
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

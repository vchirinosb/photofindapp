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
          title: const Text('Success!'),
          description: const Text('Your photos are now loaded and ready!'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _logger.e('Error fetching photos: $e');

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Oops!'),
          description: const Text('Something went wrong while loading photos.'),
          autoCloseDuration: const Duration(seconds: 3),
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
          autoCloseDuration: const Duration(seconds: 3),
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
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } else {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error'),
          description: const Text('Failed to add photo to favorites.'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Photos'),
        backgroundColor: const Color(0xFF87CEFA),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildServiceSwitcher(),
              const SizedBox(height: 12),
              _buildSearchBox(),
              const SizedBox(height: 12),
              if (_isLoading) _buildLoader(),
              const SizedBox(height: 12),
              Expanded(
                child: _photos.isEmpty && !_isLoading
                    ? const Center(
                        child: Text(
                          'Uncover Gorgeous Photo\nInspirations',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF4A460),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
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
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
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
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
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
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: _selectedService == services[index]
                  ? const Color(0xFFF4A460)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xFF87CEFA), width: 2),
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

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE6E6FA).withOpacity(0.8),
        labelText: 'Search...',
        labelStyle: const TextStyle(color: Color(0xFFF4A460)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFFF4A460)),
          onPressed: () {
            _searchQuery = _searchController.text;
            _searchPhotos();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4A460)),
      ),
    );
  }
}

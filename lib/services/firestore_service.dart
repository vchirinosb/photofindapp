import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photofindapp/models/photo_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save favorite photo
  Future<void> saveFavoritePhoto(String userId, PhotoModel photo) async {
    await _db.collection('favorites').add({
      'userId': userId,
      'imageUrl': photo.imageUrl,
      'photographer': photo.photographer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Fetch favorite photos for a user
  Future<List<PhotoModel>> fetchFavoritePhotos(String userId) async {
    final querySnapshot = await _db
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) {
      return PhotoModel(
        id: doc.id,
        imageUrl: doc['imageUrl'],
        photographer: doc['photographer'],
      );
    }).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photofindapp/models/photo_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFavoritePhoto(String userId, PhotoModel photo) async {
    await _db.collection('favorites').add({
      'userId': userId,
      'imageUrl': photo.imageUrl,
      'photographer': photo.photographerName,
      'timestamp': FieldValue.serverTimestamp(),
      'sourceImage': photo.sourceImage,
    });
  }

  Future<List<PhotoModel>> fetchFavoritePhotos(String userId) async {
    final querySnapshot = await _db
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) {
      return PhotoModel(
        id: doc.id,
        imageUrl: doc['imageUrl'],
        photographerName: doc['photographer'],
        sourceImage: doc['sourceImage'],
      );
    }).toList();
  }

  Future<void> removeFavoritePhoto(String userId, String photoId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(photoId)
        .delete();
  }

  Future<bool> isFavoritePhoto(String userId, String photoId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(photoId)
        .get();
    return doc.exists;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:photofindapp/models/photo_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String unsplashAccessKey = dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '';
  final String pexelsAccessKey = dotenv.env['PEXELS_ACCESS_KEY'] ?? '';
  final String pixabayAccessKey = dotenv.env['PIXABAY_ACCESS_KEY'] ?? '';

  Future<List<PhotoModel>> searchUnsplash(String query, {int page = 1}) async {
    final url = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$query&page=$page&client_id=$unsplashAccessKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((item) => PhotoModel(
                id: item['id'],
                imageUrl: item['urls']['small'],
                photographerName: item['user']['name'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load photos from Unsplash');
    }
  }

  Future<List<PhotoModel>> searchPexels(String query, {int page = 1}) async {
    final url =
        Uri.parse('https://api.pexels.com/v1/search?query=$query&page=$page');
    final response =
        await http.get(url, headers: {'Authorization': pexelsAccessKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['photos'] as List)
          .map((item) => PhotoModel(
                id: item['id'].toString(),
                imageUrl: item['src']['medium'],
                photographerName: item['photographer'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load photos from Pexels');
    }
  }

  Future<List<PhotoModel>> searchPixabay(String query, {int page = 1}) async {
    final url = Uri.parse(
        'https://pixabay.com/api/?key=$pixabayAccessKey&q=$query&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['hits'] as List)
          .map((item) => PhotoModel(
                id: item['id'].toString(),
                imageUrl: item['webformatURL'],
                photographerName: item['user'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load photos from Pixabay');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import 'package:photofindapp/models/photo_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class ApiService {
  final String unsplashAccessKey = dotenv.env['UNSPLASH_ACCESS_KEY']!;
  final String pexelsAccessKey = dotenv.env['PEXELS_ACCESS_KEY']!;
  final String pixabayAccessKey = dotenv.env['PIXABAY_ACCESS_KEY']!;
  final BuildContext context;
  ApiService(this.context);

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
      _showErrorToast('Failed to load photos from Unsplash');
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
      _showErrorToast('Failed to load photos from Pexels');
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
      _showErrorToast('Failed to load photos from Pixabay');
      throw Exception('Failed to load photos from Pixabay');
    }
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      title: const Text('Error'),
      description: Text(message),
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.error),
      showIcon: true,
      primaryColor: Colors.red,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: true,
    );
  }
}

class PhotoModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? photographerName;

  PhotoModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.photographerName,
  });
}

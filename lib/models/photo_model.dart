class PhotoModel {
  final String id;
  final String imageUrl;
  final String sourceImage;
  final String? title;
  final String? photographerName;

  PhotoModel({
    required this.id,
    required this.imageUrl,
    required this.sourceImage,
    this.title,
    this.photographerName,
  });
}

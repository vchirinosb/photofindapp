import 'package:flutter/material.dart';

class PhotoServiceDropdown extends StatelessWidget {
  final String value;
  final Function(String?)? onChanged;

  const PhotoServiceDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Unsplash', child: Text('Unsplash')),
        DropdownMenuItem(value: 'Pexels', child: Text('Pexels')),
        DropdownMenuItem(value: 'Pixabay', child: Text('Pixabay')),
      ],
      onChanged: onChanged,
    );
  }
}

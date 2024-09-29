import 'package:flutter/material.dart';

class PhotoServiceDropdown extends StatelessWidget {
  final Function(String?) onChanged;

  const PhotoServiceDropdown({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: 'Unsplash',
      items: const [
        DropdownMenuItem(value: 'Unsplash', child: Text('Unsplash')),
        DropdownMenuItem(value: 'Pexels', child: Text('Pexels')),
        DropdownMenuItem(value: 'Pixabay', child: Text('Pixabay')),
      ],
      onChanged: onChanged,
    );
  }
}

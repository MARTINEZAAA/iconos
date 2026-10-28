import 'package:flutter/material.dart';

class IconosBasicos extends StatelessWidget {
  const IconosBasicos({super.key});

  static const List<IconData> _iconos = [
    Icons.home,
    Icons.search,
    Icons.person,
    Icons.settings,
    Icons.favorite,
    Icons.menu,
    Icons.add,
    Icons.edit,
    Icons.delete,
    Icons.notifications,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _iconos
          .map((icono) => Icon(icono, size: 32))
          .toList(),
    );
  }
}

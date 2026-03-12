import 'package:flutter/material.dart';

class CategoryGridScroller extends StatelessWidget {
  const CategoryGridScroller({super.key, required this.categories});

  final List<Map<String, String>> categories;

  static const Map<String, IconData> _iconMap = <String, IconData>{
    'checkroom': Icons.checkroom,
    'smartphone': Icons.smartphone,
    'face_retouching_natural': Icons.face_retouching_natural,
    'kitchen': Icons.kitchen,
    'child_care': Icons.child_care,
    'shopping_basket': Icons.shopping_basket,
    'laptop_mac': Icons.laptop_mac,
    'sports_soccer': Icons.sports_soccer,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> category = categories[index];
          final IconData icon = _iconMap[category['icon']] ?? Icons.apps;
          final String title = category['title'] ?? '';

          return Container(
            width: 82,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0EC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFFFF5722), size: 18),
                ),
                const SizedBox(height: 5),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

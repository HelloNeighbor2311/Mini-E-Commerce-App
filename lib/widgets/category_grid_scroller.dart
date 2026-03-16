import 'package:flutter/material.dart';

class CategoryGridScroller extends StatelessWidget {
  const CategoryGridScroller({
    super.key, 
    required this.categories,
    required this.selectedCategoryTag, // Thêm biến nhận Tag đang được chọn
    required this.onCategorySelected,  // Thêm hàm callback khi bấm
  });

  final List<Map<String, String>> categories;
  final String selectedCategoryTag;
  final Function(String) onCategorySelected;

  static const Map<String, IconData> _iconMap = <String, IconData>{
    'smartphone': Icons.smartphone,
    'laptop_mac': Icons.laptop_mac,
    'face_retouching_natural': Icons.face_retouching_natural,
    'home': Icons.home, // Icon ngôi nhà cho đồ trang trí
    'checkroom': Icons.checkroom, // Váy vóc nữ
    'dry_cleaning': Icons.dry_cleaning, // Áo sơ mi nam
    'directions_run': Icons.directions_run, // Giày dép
    'watch': Icons.watch, // Đồng hồ
    'diamond': Icons.diamond, // Viên kim cương cho trang sức
    'directions_car': Icons.directions_car, // Xe hơi
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
          final String tag = category['tag'] ?? 'all';
          
          // Kiểm tra xem Icon này có đang được chọn không
          final bool isSelected = selectedCategoryTag == tag;

          return GestureDetector(
            onTap: () => onCategorySelected(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 82,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                // Đổi màu nền và viền nếu đang được chọn
                color: isSelected ? const Color(0xFFFFF0EC) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF5722) : Colors.black12,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFFFFF0EC),
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
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFFFF5722) : Colors.black87,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
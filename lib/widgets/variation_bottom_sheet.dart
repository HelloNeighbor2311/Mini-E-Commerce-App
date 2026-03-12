import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';

/// A modal BottomSheet for choosing variation (size, color) and quantity
/// before adding the product to the cart or proceeding to checkout.
class VariationBottomSheet extends StatefulWidget {
  const VariationBottomSheet({
    super.key,
    required this.product,
    required this.buyNow,
    required this.onConfirm,
  });

  final Product product;

  /// true  → confirm label says "Mua ngay"
  /// false → confirm label says "Them vao gio"
  final bool buyNow;

  final void Function(String size, String color, int quantity) onConfirm;

  @override
  State<VariationBottomSheet> createState() => _VariationBottomSheetState();
}

class _VariationBottomSheetState extends State<VariationBottomSheet> {
  static const List<String> _sizes = <String>['S', 'M', 'L', 'XL', 'XXL'];

  static const List<_ColorOption> _colorOptions = <_ColorOption>[
    _ColorOption(label: 'Xanh', color: Color(0xFF1976D2)),
    _ColorOption(label: 'Đỏ', color: Color(0xFFE53935)),
    _ColorOption(label: 'Trắng', color: Color(0xFFEEEEEE)),
    _ColorOption(label: 'Vàng', color: Color(0xFFFDD835)),
  ];

  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  String _fmt(int value) => '${NumberFormat('#,##0', 'vi_VN').format(value)}d';

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ── Handle bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // ── Product summary row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFF2F2F2),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _fmt(widget.product.price),
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_selectedSize != null || _selectedColor != null)
                          Text(
                            <String>[
                              if (_selectedSize != null) 'Size: $_selectedSize',
                              if (_selectedColor != null)
                                'Màu: $_selectedColor',
                            ].join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        Text(
                          'Số lượng: $_quantity',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // ── Scrollable body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Size chips
                    const Text(
                      'Kích cỡ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sizes.map((String size) {
                        return _SizeChip(
                          label: size,
                          selected: _selectedSize == size,
                          onTap: () => setState(() => _selectedSize = size),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Color chips
                    const Text(
                      'Màu sắc',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colorOptions.map((_ColorOption opt) {
                        return _ColorChip(
                          option: opt,
                          selected: _selectedColor == opt.label,
                          onTap: () =>
                              setState(() => _selectedColor = opt.label),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Quantity stepper
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Số lượng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QuantityStepper(
                          quantity: _quantity,
                          onDecrement: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                          onIncrement: () => setState(() => _quantity++),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => widget.onConfirm(
                          _selectedSize ?? 'M',
                          _selectedColor ?? 'Xanh',
                          _quantity,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.buyNow
                              ? 'Mua ngay'
                              : 'Xác nhận - Thêm vào giỏ',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _ColorOption {
  const _ColorOption({required this.label, required this.color});
  final String label;
  final Color color;
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0EC) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFFF5722) : Colors.black26,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? const Color(0xFFFF5722) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ColorOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0EC) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFFF5722) : Colors.black26,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? const Color(0xFFFF5722) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _StepButton(
          icon: Icons.remove,
          onTap: onDecrement,
          enabled: quantity > 1,
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: onIncrement, enabled: true),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: enabled ? Colors.black26 : Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.black87 : Colors.black26,
        ),
      ),
    );
  }
}

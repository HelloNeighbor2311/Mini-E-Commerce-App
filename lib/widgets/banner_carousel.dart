import 'dart:async';

import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.images});

  final List<String> images;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!mounted || widget.images.isEmpty) {
        return;
      }
      final int next = (_currentPage + 1) % widget.images.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return Container(
                                color: const Color(0xFFFFF0EC),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.local_offer,
                                  color: Color(0xFFFF5722),
                                  size: 30,
                                ),
                              );
                            },
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: <Color>[Colors.black45, Colors.transparent],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 12,
                        bottom: 12,
                        child: Text(
                          'Deal moi moi ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.images.length, (int index) {
            final bool active = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFF5722) : Colors.black26,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

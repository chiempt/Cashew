import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;

  PageIndicator({
    required this.controller,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        double? page = controller.page;
        int currentPage = page?.round().toInt() ?? controller.initialPage;
        double pageOffset = page ?? currentPage.toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            itemCount,
            (index) {
              double distance = (pageOffset - index).abs();
              double activeFactor = 1.0 - (distance.clamp(0.0, 1.0));

              double baseWidth = 8.0;
              double activeWidth = 24.0;
              double width =
                  baseWidth + (activeWidth - baseWidth) * activeFactor;
              double height = 8.0;

              bool isDark = Theme.of(context).brightness == Brightness.dark;
              Color activeColor =
                  isDark ? Colors.white : Colors.grey[700] ?? Colors.grey;
              Color inactiveColor = isDark
                  ? Colors.white.withOpacity(0.25)
                  : Colors.grey[400]?.withOpacity(0.4) ??
                      Colors.grey.withOpacity(0.4);

              double opacity = 0.4 + (activeFactor * 0.6);

              Color color = Color.lerp(
                    inactiveColor,
                    activeColor,
                    activeFactor,
                  ) ??
                  inactiveColor;

              return Container(
                width: width,
                height: height,
                margin: EdgeInsetsDirectional.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity),
                  borderRadius: BorderRadiusDirectional.circular(4),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

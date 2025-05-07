import 'package:flutter/material.dart';
import 'package:p2p_sharpdrop/utils/dimensions.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height10),
        height: Dimensions.height100,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: Colors.white,
            width: Dimensions.width5 / Dimensions.width5,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: Dimensions.height50,
              width: Dimensions.width50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(Dimensions.radius45),
              ),
            ),
            SizedBox(width: Dimensions.width20),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
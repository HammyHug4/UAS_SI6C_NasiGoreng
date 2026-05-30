import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String text;

  final VoidCallback onPressed;

  final bool isLoading;

  final IconData? icon;

  final Color backgroundColor;
  final Color foregroundColor;

  final double height;
  final double borderRadius;

  final double fontSize;

  final FontWeight fontWeight;

  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,

    required this.text,
    required this.onPressed,

    this.isLoading = false,

    this.icon,

    this.backgroundColor =
        Colors.orange,

    this.foregroundColor =
        Colors.white,

    this.height = 56,

    this.borderRadius = 18,

    this.fontSize = 16,

    this.fontWeight =
        FontWeight.bold,

    this.padding,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: height,

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor:
              backgroundColor,

          foregroundColor:
              foregroundColor,

          elevation: 3,

          shadowColor:
              Colors.black.withValues(alpha: 0.1),

          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              borderRadius,
            ),
          ),
        ),

        onPressed:
            isLoading
                ? null
                : onPressed,

        child:
            isLoading
                ? buildLoading()
                : buildButtonContent(),
      ),
    );
  }

  // BUTTON CONTENT
  Widget buildButtonContent() {

    if (icon == null) {

      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    }

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [

        Icon(icon),

        const SizedBox(width: 10),

        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }

  // LOADING UI
  Widget buildLoading() {

    return SizedBox(
      width: 24,
      height: 24,

      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: foregroundColor,
      ),
    );
  }
}

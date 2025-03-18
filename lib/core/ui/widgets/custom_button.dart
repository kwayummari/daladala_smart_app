import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild() {
      if (isLoading) {
        return SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              type == ButtonType.primary ? Colors.white : theme.primaryColor,
            ),
            strokeWidth: 2.5,
          ),
        );
      } else if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: _getForegroundColor(theme),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: textStyle ?? _getTextStyle(theme),
            ),
          ],
        );
      } else {
        return Text(
          text,
          style: textStyle ?? _getTextStyle(theme),
        );
      }
    }

    Widget buttonContent = Container(
      height: height,
      width: isFullWidth ? double.infinity : width,
      padding: padding,
      child: Center(child: buttonChild()),
    );

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.primaryColor,
            side: BorderSide(color: theme.primaryColor, width: 1.5),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.primaryColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return theme.textTheme.labelLarge!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
      case ButtonType.secondary:
      case ButtonType.text:
        return theme.textTheme.labelLarge!.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        );
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
      case ButtonType.text:
        return theme.primaryColor;
    }
  }
}
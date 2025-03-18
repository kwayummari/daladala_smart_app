import 'package:flutter/material.dart';
import 'package:daladala_smart_app/config/app_config.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  
  const LoadingIndicator({
    Key? key,
    this.size = 50,
    this.color = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
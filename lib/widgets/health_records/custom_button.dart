import 'package:flutter/material.dart';

class CustomButtonWatches extends StatelessWidget {
  const CustomButtonWatches({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = Colors.blue,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final Color color;
  final String label;
  final Function() onPressed;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // final borderRadius = borderRadius ?? BorderRadius.circular(10);

    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(.25),
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.all(15),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}

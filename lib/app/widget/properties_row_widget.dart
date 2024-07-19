import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertiesRowWidget extends StatelessWidget {
  const PropertiesRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.primary,
    this.color,
  });

  final String title;
  final String value;
  final String? subValue;
  final bool? primary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: primary != null && primary == true
                      ? context.textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.bold, color: color)
                      : context.textTheme.titleMedium!.copyWith(color: color)),
              Row(
                children: [
                  Text(
                    subValue ?? '',
                    style: context.textTheme.bodySmall!.copyWith(
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.lineThrough,
                        color: color),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
        Text(
          'Rp$value',
          style: primary != null && primary == true
              ? context.textTheme.titleLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: color)
              : context.textTheme.titleMedium!.copyWith(color: color),
        )
      ],
    );
  }
}

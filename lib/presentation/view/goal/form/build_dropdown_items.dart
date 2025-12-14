import 'package:flutter/material.dart';

List<DropdownMenuItem<T>> buildDropdownItems<T>({
  required List<T> values,
  required IconData Function(T) getIcon,
  required String Function(T) getLabel,
}) {
  return values.map((value) {
    return DropdownMenuItem<T>(
      value: value,
      child: Row(
        children: [
          Icon(getIcon(value)),
          const SizedBox(width: 8),
          Text(
            getLabel(value),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }).toList();
}

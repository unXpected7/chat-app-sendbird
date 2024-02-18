// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Widgets {
  Text buildPageTitle(String title, {int? maxLines}) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12.0, color: Colors.black),
      maxLines: maxLines ?? 1,
    );
  }

  Widget buildImageNetwork(String? imageUrl, double height, IconData errorIcon) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 58, 58, 58),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Image.network(
          imageUrl,
          width: height,
          height: height,
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            return Icon(errorIcon, size: height, color: Colors.white);
          },
        ),
        clipBehavior: Clip.hardEdge,
      );
    } else {
      return Icon(errorIcon, size: height, color: Colors.white);
    }
  }

  Widget buildTextField(
    TextEditingController controller,
    String labelText, {
    int? maxLines,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        labelText: labelText,
      ),
      maxLines: maxLines ?? 1,
      focusNode: focusNode,
    );
  }

  Widget buildNumberTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        labelText: labelText,
        contentPadding: const EdgeInsets.all(8.0),
      ),
      onChanged: onChanged,
    );
  }
}

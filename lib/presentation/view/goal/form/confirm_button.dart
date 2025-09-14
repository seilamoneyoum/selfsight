import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ElevatedButton confirmButton(
    GlobalKey<FormState> formKey, BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing Data')),
          );
        }
      },
      child: Text("Confirm",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
}

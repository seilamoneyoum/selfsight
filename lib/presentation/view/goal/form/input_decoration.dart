import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration inputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black,
      ));
}

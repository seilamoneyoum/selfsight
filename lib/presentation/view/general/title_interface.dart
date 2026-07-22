import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text titleInterface(String message) {
  return Text(
    message,
    style: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

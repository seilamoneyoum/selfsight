import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text text(String message) {
  return Text(
    message,
    style: GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.black,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/goal/form/input_decoration.dart';
import 'package:google_fonts/google_fonts.dart';

TextFormField titleField() {
  return TextFormField(
    decoration: inputDecoration("Title"),
    style: GoogleFonts.poppins(fontSize: 12),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Template du titre d'input
InputDecoration labelInput(String label) {
  return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
      ));
}

// Template du texte
Text message(String message) {
  return Text(
    message,
    style: GoogleFonts.poppins(
      fontSize: 13,
    ),
  );
}

// Template du titre de l'interface
Text titleInterface(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
  );
}

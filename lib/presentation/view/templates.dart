import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Template du titre d'input
InputDecoration labelInput(String label) {
  return InputDecoration(
      labelText: label,
      isDense: true,
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

// Template du "sous-texte"
Text subMessage(String message) {
  return Text(
    message,
    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
  );
}

// Template du titre de l'interface
Text titleInterface(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
  );
}

// Template du sous-titre de l'interface
Text subtitleInterface(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
  );
}

// Template du petit titre de l'interface
Text smallTitleInterface(String title) {
  return Text(
    title,
    style: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey[800]),
  );
}

Text errorMessage(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 10,
      color: Colors.red,
    ),
  );
}

import 'package:flutter/material.dart';

/// Classe contenente tutti i colori dell'applicazione.
/// Ispirata al design di Braynr.
class AppColors {
  // Colori principali
  static const primaryBlue = Color(0xFF3880FF);    // Blu principale
  static const secondaryBlue = Color(0xFF5A9DEE);  // Blu secondario, più chiaro
  
  // Colore di sfondo principale
  static const darkBackground = Color(0xFF242640);  // Blu scuro/navy (sfondo)
  static const backgroundGrey = Color(0xFF2D304D);  // Grigio-blu scuro per elementi di sfondo
  static const cardDark = Color(0xFF353853);        // Per card su sfondo scuro
  
  // Colori testo
  static const textLight = Color(0xFFFFFFFF);      // Bianco per testo su sfondo scuro
  static const textMedium = Color(0xFFB8BEDD);     // Grigio chiaro per testo secondario
  static const textDark = Color(0xFF333333);       // Per testo su sfondo chiaro
  
  // Accenti/Bordi
  static const lightBlue = Color(0xFFE0ECFF);      // Azzurro molto chiaro, per accenti
  static const border = Color(0xFF4E5278);         // Bordi su sfondo scuro
  static const divider = Color(0xFF4E5278);        // Divisori
  
  // Gradiente principale
  static const List<Color> blueGradient = [
    Color(0xFF3880FF),
    Color(0xFF5A9DEE),
  ];
  
  // Gradiente del bottone download
  static const List<Color> downloadGradient = [
    Color(0xFF5E72EB),
    Color(0xFF64C2DB),
  ];
  
  // Colori per le diverse funzionalità (seguendo l'immagine)
  static const flashcards = Color(0xFF4DA9FF);     // Azzurro per Flashcards
  static const questions = Color(0xFF5E72EB);      // Blu violaceo per Domande
  static const notes = Color(0xFF242640);          // Blu scuro per Note
  static const mindMaps = Color(0xFF64C2DB);       // Azzurro chiaro per Mappe mentali
  static const images = Color(0xFF64C2DB);         // Azzurro chiaro per Immagini 
  static const keywords = Color(0xFF3D84F5);       // Blu brillante per Parole chiave
  
  // Accenti delle funzionalità
  static const flashcardsAccent = Color(0xFF4DA9FF);
  static const questionsAccent = Color(0xFF5E72EB);
  static const notesAccent = Color(0xFF92AEFF);
  static const mindMapsAccent = Color(0xFF64C2DB);
  static const imagesAccent = Color(0xFF64C2DB);
  static const keywordsAccent = Color(0xFF3D84F5);
  
  // Colori per le azioni (mantenuti per compatibilità)
  static const success = Color(0xFF4CD964);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const info = Color(0xFF5AC8FA);
  
  // Colore ombra
  static const shadow = Color(0x40000000);
  
  // Getter per ottenere il colore in base alla categoria
  static Color getColorForCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return flashcards;
      case 1:
        return notes;
      case 2:
        return mindMaps;
      case 3:
        return questions;
      case 4:
        return keywords;
      default:
        return primaryBlue;
    }
  }
  
  // Getter per ottenere l'accento di colore in base alla categoria
  static Color getAccentForCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return flashcardsAccent;
      case 1:
        return notesAccent;
      case 2:
        return mindMapsAccent;
      case 3:
        return questionsAccent;
      case 4:
        return keywordsAccent;
      default:
        return primaryBlue;
    }
  }
  
  // Getter per ottenere la versione chiara di un colore (20% opacità)
  static Color getLightVersionOf(Color color) {
    return color.withOpacity(0.2);
  }
  
  // Getter per creare un colore semi-trasparente
  static Color getTransparentVersion(Color color, {double opacity = 0.5}) {
    return color.withOpacity(opacity);
  }
  
  // Getter per il colore del testo a seconda del tema
  static Color getTextColorOnBackground(bool isDarkTheme) {
    return isDarkTheme ? textLight : textDark;
  }
}
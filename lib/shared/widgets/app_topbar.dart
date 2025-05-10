import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget per la barra superiore dell'applicazione.
/// Adattabile sia per layout mobile che desktop, con stile Braynr.
class AppTopBar extends StatelessWidget {
  final bool isMobile;
  
  const AppTopBar({
    super.key,
    this.isMobile = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 70 : 64,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Parte sinistra: Logo e titolo
          _buildLeftSection(context),
          
          // Parte centrale: Barra di ricerca (solo desktop)
          if (!isMobile) _buildSearchBar(),
          
          // Parte destra: Icone azioni e avatar
          _buildRightSection(context),
        ],
      ),
    );
  }
  
  // Costruisce la sezione sinistra della barra superiore
  Widget _buildLeftSection(BuildContext context) {
    return Row(
      children: [
        // Icona menu (solo su mobile)
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textLight),
            onPressed: () {
              // Implementazione apertura drawer/menu mobile
              Scaffold.of(context).openDrawer();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        
        if (isMobile) const SizedBox(width: 16),
        
        // Logo Braynr dall'immagine assets
        Image.asset(
          'assets/images/braynr_logo.png', 
          height: 36,
          // Assicura che il logo abbia un aspetto buono su sfondo scuro
          filterQuality: FilterQuality.high,
        ),
        
        // Rimuoviamo il Container con l'icona e il testo "BraynR Studio" 
        // poiché li stiamo sostituendo con il logo dell'immagine
      ],
    );
  }
  
  // Costruisce la barra di ricerca
  Widget _buildSearchBar() {
    return Expanded(
      child: Center(
        child: Container(
          width: 300,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.textLight),
            decoration: const InputDecoration(
              hintText: 'Cerca',
              hintStyle: TextStyle(color: AppColors.textMedium),
              prefixIcon: Icon(Icons.search, color: AppColors.textMedium),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ),
    );
  }
  
  // Costruisce la sezione destra della barra superiore
  Widget _buildRightSection(BuildContext context) {
    return Row(
      children: [
        // Icone azioni (solo desktop)
        if (!isMobile) ...[
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textLight),
            onPressed: () {
              // Azione notifiche
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textLight),
            onPressed: () {
              // Azione impostazioni
            },
          ),
          const SizedBox(width: 8),
        ],
        
        // Avatar utente
        _UserAvatar(),
      ],
    );
  }
}

/// Widget per l'avatar dell'utente.
class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.downloadGradient,
        ),
      ),
      child: const Center(
        child: Text(
          'MS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
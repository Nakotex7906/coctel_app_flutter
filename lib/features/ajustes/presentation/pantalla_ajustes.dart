import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coctel_app/core/services/theme_provider.dart';
import './Pantalla_mis_cocteles_creados.dart' hide ThemeProvider;

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final scaffoldColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text(
          "Ajustes",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: iconColor,
              ),
              title: Text(
                "Modo Oscuro",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(); 
                },
                activeTrackColor: const Color(0xFF05AFF2).withAlpha((255 * 0.7).round()),
                activeThumbColor: const Color(0xFF05AFF2),
              ),
            ),
            const Divider(),

            // Icono para cócteles
            ListTile(
              leading: Icon(
                Icons.local_bar_rounded,
                color: iconColor,
              ),
              title: Text(
                "Mis Cócteles Creados",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: hintColor, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaMisCoctelesCreados()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: iconColor),
              title: Text(
                "Acerca de",
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: hintColor, size: 18),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "BlueMix",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2024 BlueMix. Todos los derechos reservados.",
                  barrierDismissible: true,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Esta aplicación fue creada para ayudarte a descubrir, crear y disfrutar de tus cócteles favoritos.",
                    ),
                  ],
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/theme_provider.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: textColor,
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
                activeColor: const Color(0xFF05AFF2),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: hintColor),
              title: Text(
                "Acerca de",
                style: TextStyle(color: hintColor),
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "BlueMix",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2024 BlueMix. Todos los derechos reservados.",
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Esta aplicación fue creada para ayudarte a descubrir, crear y disfrutar de tus cócteles favoritos.",
                      style: TextStyle(color: hintColor),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/services/theme_provider.dart';

class PantallaCrearCoctel extends StatefulWidget {
  const PantallaCrearCoctel({super.key});

  @override
  _PantallaCrearCoctelState createState() => _PantallaCrearCoctelState();
}

class _PantallaCrearCoctelState extends State<PantallaCrearCoctel> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final List<TextEditingController> _ingredienteControllers = [TextEditingController()];
  final List<TextEditingController> _medidaControllers = [TextEditingController()];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _addIngredienteField() {
    setState(() {
      _ingredienteControllers.add(TextEditingController());
      _medidaControllers.add(TextEditingController());
    });
  }

  void _removeIngredienteField(int index) {
    setState(() {
      _ingredienteControllers[index].dispose();
      _ingredienteControllers.removeAt(index);
      _medidaControllers[index].dispose();
      _medidaControllers.removeAt(index);
    });
  }

  void _publishCoctel() {
    // TODO: Implementar la lógica para publicar el cóctel
    final String nombre = _nombreController.text;
    final String descripcion = _descripcionController.text;
    final List<Map<String, String>> ingredientes = [];
    for (int i = 0; i < _ingredienteControllers.length; i++) {
      if (_ingredienteControllers[i].text.isNotEmpty) {
        ingredientes.add({
          "nombre": _ingredienteControllers[i].text,
          "medida": _medidaControllers[i].text,
        });
      }
    }

    print("Nombre: $nombre");
    print("Descripción: $descripcion");
    print("Ingredientes: $ingredientes");
    print("Imagen: ${_imageFile?.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cóctel publicado (simulado)!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    for (var controller in _ingredienteControllers) {
      controller.dispose();
    }
    for (var controller in _medidaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final hintColor = isDarkMode ? Colors.white60 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Crear Cóctel",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _publishCoctel,
            child: const Text(
              "Publicar",
              style: TextStyle(color: Color(0xFF05AFF2), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Área de la imagen del cóctel
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  image: _imageFile != null
                      ? DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: hintColor),
                    const SizedBox(height: 10),
                    Text(
                      "Toca para añadir una imagen",
                      style: TextStyle(color: hintColor),
                    ),
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nombre del Cóctel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  _buildTextField(_nombreController, "Ej. Mojito Clásico", isDarkMode: isDarkMode),
                  const SizedBox(height: 20),

                  Text("Descripción y Historia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  _buildTextField(_descripcionController, "Una refrescante mezcla...", maxLines: 4, isDarkMode: isDarkMode),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ingredientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF05AFF2)),
                        onPressed: _addIngredienteField,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredienteControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(_ingredienteControllers[index], "Ej. Ron Blanco", isDarkMode: isDarkMode),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(_medidaControllers[index], "Ej. 2 oz / 60 ml", isDarkMode: isDarkMode),
                            ),
                            if (_ingredienteControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Color(0xFFF44336)),
                                onPressed: () => _removeIngredienteField(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1, required bool isDarkMode}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade600),
        fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }
}
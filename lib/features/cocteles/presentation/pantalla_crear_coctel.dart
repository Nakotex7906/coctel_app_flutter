import 'package:coctel_app/core/models/coctel.dart';
import 'package:coctel_app/core/models/ingrediente.dart';
import 'package:coctel_app/core/services/cocteles_creados_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/services/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PantallaCrearCoctel extends StatefulWidget {

  // Para pasar el cóctel a editar
  final Coctel? coctelParaEditar;

  const PantallaCrearCoctel({super.key, this.coctelParaEditar});

  @override
  PantallaCrearCoctelState createState() => PantallaCrearCoctelState();
}

class PantallaCrearCoctelState extends State<PantallaCrearCoctel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late List<TextEditingController> _ingredienteControllers;
  late List<TextEditingController> _medidaControllers;
  File? _imageFile;
  String? _existingImageFilePath;
  final ImagePicker _picker = ImagePicker();

  // Helper para saber si estamos editando
  bool get _isEditing => widget.coctelParaEditar != null;

  @override
  void initState() {
    super.initState();
    final coctel = widget.coctelParaEditar;
    _nombreController = TextEditingController(text: coctel?.nombre ?? '');
    _descripcionController = TextEditingController(text: coctel?.instrucciones ?? '');

    if (coctel != null && coctel.ingredientes.isNotEmpty) {
      _ingredienteControllers = coctel.ingredientes
          .map((ing) => TextEditingController(text: ing.nombre))
          .toList();
      _medidaControllers = coctel.ingredientes
          .map((ing) => TextEditingController(text: ing.cantidad))
          .toList();
    } else {
      _ingredienteControllers = [TextEditingController()];
      _medidaControllers = [TextEditingController()];
    }

    if (coctel?.imagenUrl.isNotEmpty == true && coctel!.imagenUrl.startsWith('/')) {
      _existingImageFilePath = coctel.imagenUrl;
      _imageFile = File(coctel.imagenUrl); 
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);

        // Si se elige nueva imagen, la antigua ya no se usa
        _existingImageFilePath = null;
      });
    }
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

  Future<String> _saveImagePermanently(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imageFile.path);
    final newPath = p.join(directory.path, fileName);
    final newImage = await imageFile.copy(newPath);
    return newImage.path;
  }

  void _saveCoctel() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, corrige los errores del formulario.')),
        );
        return;
    }
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del cóctel no puede estar vacío.')),
      );
      return;
    }

    String imagePathToSave = _existingImageFilePath ?? '';
    if (_imageFile != null && _imageFile!.path != _existingImageFilePath) { // Si hay nueva imagen o se cambió la existente
        imagePathToSave = await _saveImagePermanently(_imageFile!);
    }
    
    final List<Ingrediente> ingredientes = [];
    for (int i = 0; i < _ingredienteControllers.length; i++) {
      if (_ingredienteControllers[i].text.isNotEmpty) {
        ingredientes.add(Ingrediente(
          nombre: _ingredienteControllers[i].text,
          cantidad: _medidaControllers[i].text,
        ));
      }
    }

    // Corregir esto mas tarde para alcohol y categoria
    final coctelData = Coctel(
      id: _isEditing ? widget.coctelParaEditar!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text,
      instrucciones: _descripcionController.text,
      imagenUrl: imagePathToSave,
      alcohol: 'Personalizado',
      categoria: 'Personalizado',
      ingredientes: ingredientes,
      isLocal: true,
    );

    final manager = Provider.of<CoctelesCreadosManager>(context, listen: false);
    String message;

    if (_isEditing) {
      await manager.actualizarCoctel(coctelData);
      message = '¡Cóctel actualizado con éxito!';
    } else {
      await manager.agregarCoctel(coctelData);
      message = '¡Cóctel creado con éxito!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Regresar a la pantalla anterior (lista de mis cócteles)
    Navigator.pop(context);

    // Si estamos editando, hacer pop una vez más para cerrar la pantalla de detalle si estaba abierta
    if (_isEditing) {
      Navigator.pop(context);
    }
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
          _isEditing ? "Editar Cóctel" : "Crear Cóctel", // MODIFICADO
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveCoctel,
            child: Text(
              _isEditing ? "Guardar Cambios" : "Publicar",
              style: const TextStyle(color: Color(0xFF05AFF2), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : (_existingImageFilePath != null && _existingImageFilePath!.isNotEmpty 
                            ? DecorationImage(image: FileImage(File(_existingImageFilePath!)), fit: BoxFit.cover) 
                            : null),
                  ),
                  child: _imageFile == null && (_existingImageFilePath == null || _existingImageFilePath!.isEmpty)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: hintColor),
                            const SizedBox(height: 10),
                            Text("Toca para añadir una imagen", style: TextStyle(color: hintColor)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text("Nombre del Cóctel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              _buildTextFormField(_nombreController, "Ej. Mojito Clásico", isDarkMode: isDarkMode, 
                validator: (value) => value == null || value.isEmpty ? 'El nombre no puede estar vacío' : null
              ),
              const SizedBox(height: 20),
              Text("Preparación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              _buildTextFormField(_descripcionController, "Una refrescante mezcla...", maxLines: 4, isDarkMode: isDarkMode, 
                validator: (value) => value == null || value.isEmpty ? 'La preparación no puede estar vacía' : null
              ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextFormField(_ingredienteControllers[index], "Ej. Ron Blanco", isDarkMode: isDarkMode,
                            validator: (value) {

                              // Solo validar si el de medida también tiene texto o es el único ingrediente
                              if (_medidaControllers[index].text.isNotEmpty && (value == null || value.isEmpty)) {
                                return 'Nombre ing.';
                              }
                              return null;
                            }
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildTextFormField(_medidaControllers[index], "Ej. 2 oz", isDarkMode: isDarkMode,
                           validator: (value) {
                              if (_ingredienteControllers[index].text.isNotEmpty && (value == null || value.isEmpty)) {
                                return 'Medida ing.';
                              }
                              return null;
                            }
                          ),
                        ),
                        (_ingredienteControllers.length > 1)
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove_circle, color: Color(0xFFF44336)),
                                onPressed: () => _removeIngredienteField(index),
                              )

                        // Espacio para alinear si solo hay un ingrediente
                            : const SizedBox(width: 48),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String hintText, {int maxLines = 1, required bool isDarkMode, String? Function(String?)? validator}) {
    return TextFormField(
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
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      validator: validator,
    );
  }
}

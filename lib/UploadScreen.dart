import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'main.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _matriculaController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _guardarImagen() async {
    if (_image == null || _matriculaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toma una foto y añade la matrícula.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final matricula = _matriculaController.text;
      final imagePath =
          'motos/$matricula-${DateTime.now().millisecondsSinceEpoch}${path.extension(_image!.path)}';
      final bytes = await _image!.readAsBytes();

      await supabase.storage.from('imagenes-motos').uploadBinary(imagePath, bytes);
      final imageUrl = supabase.storage.from('imagenes-motos').getPublicUrl(imagePath);

      final existingData = await supabase
          .from('motos')
          .select('image_url')
          .eq('matricula', matricula)
          .maybeSingle();

      String updatedImageUrls;
      if (existingData != null && existingData['image_url'] != null) {
        updatedImageUrls = "${existingData['image_url']},$imageUrl";
      } else {
        updatedImageUrls = imageUrl;
      }

      if (existingData == null) {
        await supabase.from('motos').insert({'matricula': matricula, 'image_url': updatedImageUrls});
      } else {
        await supabase.from('motos').update({'image_url': updatedImageUrls}).eq('matricula', matricula);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen guardada correctamente!')),
      );

      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ✅ Asegura que haya un Scaffold
      appBar: AppBar(title: const Text("Subir Fotos")),
      body: SingleChildScrollView( // ✅ Permite desplazamiento si hay overflow
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula de la Moto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _takePicture,
                child: const Text('Tomar Foto'),
              ),
              const SizedBox(height: 20),
              if (_image != null)
                Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _guardarImagen,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Imagen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Add this
import 'package:http/http.dart' as http;

import 'data_helper.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  final String language;

  const DiseaseDetectionScreen({super.key, required this.language});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _imageFile;
  Uint8List? _webImageBytes;
  bool _loading = false;
  Map<String, dynamic>? _result;

  final _picker = ImagePicker();
  // final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY'); // or dotenv.env['KEY']


  Future<void> _pickAndDetect() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _webImageBytes = result.files.single.bytes!;
          _imageFile = null;
          _result = null;
        });
        await _sendToGemini(_webImageBytes!);
      }
    } else {
      final XFile? picked =
      await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _imageFile = file;
          _webImageBytes = null;
          _result = null;
        });
        final bytes = await file.readAsBytes();
        await _sendToGemini(bytes);
      }
    }
  }

  Future<void> _sendToGemini(Uint8List bytes) async {
    final uri = Uri.parse('https://krishi-mitra-1080111382250.asia-south1.run.app/geminiAPI');

    // Exactly what Flask expects:
    final body = {"image_base64": base64Encode(bytes), "language": widget.language};
    setState(() => _loading = true);
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // print(res); // for debugging
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (raw != null) {
          final cleanJson = raw
              .replaceAll(RegExp(r'```json|```'), '') // remove triple backticks & json label
              .trim(); // remove leading/trailing whitespace
          setState(() => _result = jsonDecode(cleanJson));
        }
      } else {
        _showSnack('Server error ${res.statusCode}');
      }
    } catch (e) {
      // print(e); // for debugging
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primaryContainer, width: 2));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getTranslatedValue("Pest Disease Detection", widget.language) ?? "Pest & Disease Detection",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      backgroundColor: Colors.lightGreen[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // leave space for bottom button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: _imageFile == null && _webImageBytes == null
                  ? _Placeholder(cardShape)
                  : Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _webImageBytes != null
                      ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                      : Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _loading
                  ? const CircularProgressIndicator()
                  : _result == null
                  ? const SizedBox.shrink()
                  : Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(getTranslatedValue("Disease", widget.language) ?? "Disease", _result!['disease']),
                      _InfoRow(getTranslatedValue("Treatment", widget.language) ?? "Treatment", _result!['treatment']),
                      // _InfoRow('Crop Name', _result!['crop_name']),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[150],
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  elevation: 4,
                ),
                onPressed: _pickAndDetect,
                icon: const Icon(Icons.upload, color: Colors.brown),
                label: Text(
                  getTranslatedValue('Upload Image', widget.language) ?? 'Upload Image',
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- little helper widgets ----------
class _Placeholder extends StatelessWidget {
  final ShapeBorder shape;
  const _Placeholder(this.shape);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 300,
      decoration: ShapeDecoration(shape: shape),
      alignment: Alignment.center,
      child: Text('No image selected',
          style:
          Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
                text: '$label: ',
                style:
                const TextStyle(fontWeight: FontWeight.bold, height: 1.4)),
            TextSpan(text: value)
          ],
        ),
      ),
    );
  }
}

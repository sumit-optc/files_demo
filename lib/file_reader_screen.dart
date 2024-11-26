import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

class FileReaderScreen extends StatefulWidget {
  const FileReaderScreen({super.key});

  @override
  _FileReaderScreenState createState() => _FileReaderScreenState();
}

class _FileReaderScreenState extends State<FileReaderScreen> {
  File? _localFile;
  final TextEditingController _fileContentController = TextEditingController();
  String _fileName = 'text_file.txt';
  String _localFilePath = '';

  @override
  void initState() {
    super.initState();
    _loadInitialFile();
  }

  Future<void> _loadInitialFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      List<FileSystemEntity> localFiles = directory.listSync();
      List<String> localTextFiles = localFiles
          .where((file) => file.path.endsWith('.txt'))
          .map((file) => path.basename(file.path))
          .toList();

      String? selectedFile = await _showFileSelectionDialog(localTextFiles);

      if (selectedFile == null) return;

      String contents;
      if (selectedFile.startsWith('lib/')) {
        contents = await rootBundle.loadString(selectedFile);

        final file = File('${directory.path}/${path.basename(selectedFile)}');
        await file.writeAsString(contents);

        setState(() {
          _localFile = file;
          _localFilePath = file.path;
          _fileName = path.basename(selectedFile);
        });
      } else {
        final file = File('${directory.path}/$selectedFile');
        contents = await file.readAsString();

        setState(() {
          _localFile = file;
          _localFilePath = file.path;
          _fileName = selectedFile;
        });
      }

      _fileContentController.text = contents;
    } catch (e) {
      _showErrorDialog('Error loading file: $e');
    }
  }

  Future<String?> _showFileSelectionDialog(List<String> localFiles) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select File'),
          children: [
            const SimpleDialogOption(
              child: Text('Asset Files:'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'lib/text_file.txt'),
              child: const Text('text_file.txt'),
            ),
            if (localFiles.isNotEmpty) ...[
              const Divider(),
              const SimpleDialogOption(
                child: Text('Local Files:'),
              ),
              ...localFiles
                  .map((file) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, file),
                        child: Text(file),
                      ))
                  .toList(),
            ],
          ],
        );
      },
    );
  }

  Future<void> _saveLocalFile() async {
    if (_localFile == null) return;

    try {
      await _localFile!.writeAsString(_fileContentController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved locally: $_localFilePath')),
      );
    } catch (e) {
      _showErrorDialog('Error saving file: $e');
    }
  }

  Future<void> _shareFile() async {
    if (_localFile == null) return;

    try {
      await Share.shareXFiles([XFile(_localFile!.path)]);
    } catch (e) {
      _showErrorDialog('Error sharing file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: _loadInitialFile,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareFile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current File: $_fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Local Path: $_localFilePath',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _fileContentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'File Contents',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveLocalFile,
              child: const Text('Save Locally'),
            ),
          ],
        ),
      ),
    );
  }
}

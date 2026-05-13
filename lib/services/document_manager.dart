
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DocumentManager {
  static Future<String> get documentsDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(path.join(appDocDir.path, 'documents'));
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    return docDir.path;
  }

  static Future<String> createDocumentFolder(String folderName) async {
    final docsDir = await documentsDirectory;
    final folderPath = path.join(docsDir, folderName);
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folderPath;
  }

  static Future<String> saveHtmlContent(String folderName, String content) async {
    final folderPath = await createDocumentFolder(folderName);
    final filePath = path.join(folderPath, 'index.html');
    final file = File(filePath);
    await file.writeAsString(content);
    return filePath;
  }

  static Future<String?> loadHtmlContent(String folderName) async {
    final docsDir = await documentsDirectory;
    final filePath = path.join(docsDir, folderName, 'index.html');
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  static Future<bool> deleteDocumentFolder(String folderName) async {
    final docsDir = await documentsDirectory;
    final folderPath = path.join(docsDir, folderName);
    final folder = Directory(folderPath);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
      return true;
    }
    return false;
  }

  static Future<List<String>> listDocumentFolders() async {
    final docsDir = await documentsDirectory;
    final directory = Directory(docsDir);
    if (!await directory.exists()) {
      return [];
    }
    final folders = await directory.list().where((entity) => entity is Directory).toList();
    return folders.map((folder) => path.basename(folder.path)).toList();
  }

  static Future<String> generateFolderName(String title) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedTitle = title.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    return '${sanitizedTitle}_$timestamp';
  }

  static Future<String> saveMediaFile(String folderName, String fileName, List<int> bytes) async {
    final folderPath = await createDocumentFolder(folderName);
    final mediaDir = Directory(path.join(folderPath, 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create();
    }
    final filePath = path.join(mediaDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  static Future<List<String>> listMediaFiles(String folderName) async {
    final docsDir = await documentsDirectory;
    final mediaDir = Directory(path.join(docsDir, folderName, 'media'));
    if (!await mediaDir.exists()) {
      return [];
    }
    final files = await mediaDir.list().where((entity) => entity is File).toList();
    return files.map((file) => path.basename(file.path)).toList();
  }
}

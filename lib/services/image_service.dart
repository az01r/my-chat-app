import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utils/global_backend_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ImageService {
  static Future<void> uploadAvatar(File image) async {
    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/upload/avatar');

    try {
      final token = await authService.getToken();
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      String? mimeType = lookupMimeType(image.path);
      MediaType? contentType;
      if (mimeType != null) {
        contentType = MediaType.parse(mimeType);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          image.path,
          contentType: contentType,
        ),
      );

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 10));
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        throw Exception('Image upload failed: ${response.statusCode}');
      }
      // avatar = await image.readAsBytes();
    } on TimeoutException catch (_) {
      throw Exception(
          'Image upload request timed out. Please check your connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred during image upload: $e');
    }
  }

  static Future<Uint8List> fetchImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }
}

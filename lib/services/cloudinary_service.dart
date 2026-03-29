import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final _cloudinary = CloudinaryPublic('diiadmu9k', 'smart_city_preset');
  static Future<String> uploadImage(String path) async {
    var res = await _cloudinary.uploadFile(CloudinaryFile.fromFile(path, folder: 'reports'));
    return res.secureUrl;
  }
}
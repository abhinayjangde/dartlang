import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
    return file?.path;
  }

  Future<String?> pickCameraImage() async {
    final file = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1920);
    return file?.path;
  }

  Future<String?> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    return file?.path;
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlobalBackendUrl {
  static final String kBackendUrl =
      '${dotenv.env['BACKEND_URL']}:${dotenv.env['BACKEND_PORT']}';
}
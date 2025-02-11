import 'package:http/http.dart' as http;

extension HttpResponse on http.Response {
  bool get isOk {
    return (statusCode ~/ 100) == 2;
  }
}

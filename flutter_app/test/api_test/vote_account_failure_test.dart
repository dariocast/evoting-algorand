import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST', Uri.parse('http://localhost:8090/algorand/vote/16941383'));
  request.body = json.encode({
    "passphrase":
        "amazing squirrel lecture calm kick core regular skill lend flock mule audit mention orange toward search busy neutral record dilemma exile there tennis absent share",
    "choice": "OPT_1"
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  } else {
    print(response.reasonPhrase);
  }
}

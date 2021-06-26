import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request('POST', Uri.parse('http://localhost:8090/voting'));
  request.body = json.encode({
    "assetId": "16062863",
    "description": "DESCRIPTION",
    "title": "TITLE",
    "options": ["OPT_1", "OPT_2"],
    "passphrase":
        "amazing squirrel lecture calm kick core regular skill lend flock mule audit mention orange toward search busy neutral record dilemma exile there tennis absent share",
    "regBegin": "2021-06-19 13:13:17",
    "regEnd": "2021-06-20 13:12:47",
    "voteBegin": "2021-06-19 13:13:17",
    "voteEnd": "2021-06-20 13:12:47"
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  } else {
    print(response.reasonPhrase);
  }
}

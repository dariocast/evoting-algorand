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
        "head exile credit private couch special spawn also merry grant faith parent blade measure rigid mixed waste notice dizzy concert hidden nephew change absent emotion",
    "regBegin": "2021-06-18 13:28:00",
    "regEnd": "2021-06-18 18:00:00",
    "voteBegin": "2021-06-18 13:28:00",
    "voteEnd": "2021-06-18 18:00:00"
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  } else {
    print(response.reasonPhrase);
  }
}

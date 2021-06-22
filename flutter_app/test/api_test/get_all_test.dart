import 'package:algorand_evoting/modules/home/repository/home_repository.dart';

void main() async {
  // final secondResp = await RestApiService.getAllVoting();

  // print(secondResp.toString());
  final votings = await HomeRepository().getVotings();
  votings.forEach((voting) => print(voting));

  // var request = http.Request('GET', Uri.parse('http://localhost:8090/voting'));

  // http.StreamedResponse response = await request.send();

  // if (response.statusCode == 200) {
  //   final responseJsonString = await response.stream.bytesToString();
  //   final restResponse = RestApiResponse.fromJson(responseJsonString);
  //   final secondResp = await RestApiService.getAllVoting();

  //   assert(restResponse == secondResp);

  //   print(restResponse.toString());
  // } else {
  //   print(response.reasonPhrase);
  // }
}

import 'package:algorand_evoting/core/models/models.dart';
import 'package:algorand_evoting/utils/helpers/api_utils.dart';
import 'package:algorand_evoting/utils/services/rest_api_service.dart';

class HomeRepository {
  Future<List<Voting>> getVotings() async {
    final response = await RestApiService.getAllVoting();
    if (response.data != null) {
      List<Voting> votings = List<Voting>.from(
          response.data.map((voting) => Voting.fromMap(voting)));
      return votings;
    }
    return List<Voting>.empty();
  }

  // Future<Voting> createVoting(String votingData) async {
  //   if (!apiInputIsValid(votingData, RestApiOperation.create)) {
  //     throw RestApiException(message: 'Invalid input data');
  //   }
  //   final response = await RestApiService.createVoting(votingData);
  //   if (response.status == 200 && response.data != null) {
  //     return Voting.fromMap(response.data);
  //   } else {
  //     throw RestApiException(message: 'Creation failed');
  //   }
  // }

  Future<RestApiResponse> deleteVoting(String id, String passphrase) async {
    final response = await RestApiService.deleteVoting(id, passphrase);
    if (response.status == 200 && response.data != null) {
      return response;
    } else {
      throw RestApiException(message: 'Deletion failed');
    }
  }

  Future<RestApiResponse> registerIntoVoting(
      String id, String passphrase) async {
    final response = await RestApiService.registerForVoting(id, passphrase);
    if (response.status == 200 && response.data != null) {
      return response;
    } else {
      throw RestApiException(message: 'Registration failed');
    }
  }

  Future<RestApiResponse> castVoteForVoting(
      String id, String passphrase, String choice) async {
    final response = await RestApiService.voteForVoting(id, passphrase, choice);
    if (response.status == 200 && response.data != null) {
      return response;
    } else {
      throw RestApiException(message: 'Vote failed');
    }
  }
}

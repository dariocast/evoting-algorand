import 'package:algorand_dart/algorand_dart.dart';
import 'package:algorand_evoting/utils/services/algorand_service.dart';

class VotingProvider {
  Future<SearchTransactionsResponse> getAllVoting() async {
    final trxs = await algorand
        .indexer()
        .transactions()
        .whereNotePrefix("[voteapp][creation]")
        .search(limit: 1);
    return trxs;
  }
}

main() async {
  final transaction = await VotingProvider().getAllVoting();
  print(transaction);
}

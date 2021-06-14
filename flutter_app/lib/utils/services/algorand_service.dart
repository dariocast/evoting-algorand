import 'package:algorand_dart/algorand_dart.dart';

import '../../constants/app_constants.dart';

// final algorand = Algorand(
//   algodClient: AlgodClient(
//     apiUrl: PureStake.TESTNET_ALGOD_API_URL,
//     apiKey: pureStakeApiKey,
//   ),
//   indexerClient: IndexerClient(
//     apiUrl: PureStake.TESTNET_INDEXER_API_URL,
//     apiKey: pureStakeApiKey,
//   ),
// );

final algorand = Algorand(
  algodClient: AlgodClient(
    apiUrl: AlgoExplorer.TESTNET_ALGOD_API_URL,
    apiKey: '',
  ),
  indexerClient: IndexerClient(
    apiUrl: AlgoExplorer.TESTNET_INDEXER_API_URL,
    apiKey: '',
  ),
);

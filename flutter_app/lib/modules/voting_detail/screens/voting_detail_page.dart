import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/core/models/voting.dart';
import 'package:algorand_evoting/modules/voting_detail/voting_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VotingDetailPage extends StatelessWidget {
  const VotingDetailPage({Key? key}) : super(key: key);

  static Route route(Voting voting) {
    return MaterialPageRoute(
        builder: (_) => BlocProvider(
              create: (context) => VotingDetailBloc(
                  accountRepo: context.read<AccountRepository>(),
                  voting: voting),
              child: VotingDetailPage(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final voting = context.select((VotingDetailBloc bloc) => bloc.state.voting);
    return Scaffold(
      appBar: AppBar(
        title: Text(voting.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: _buildDetails(voting),
      ),
    );
  }

  _buildDetails(Voting voting) {
    final isRegistrationOpen = DateTime.now().isAfter(voting.regBegin) &&
        DateTime.now().isBefore(voting.regEnd);
    final isVoteOpen = DateTime.now().isAfter(voting.voteBegin) &&
        DateTime.now().isBefore(voting.voteEnd);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              voting.description ?? 'Description unavailable',
              style: TextStyle(
                  fontSize: fontSizeXXLarge, fontStyle: FontStyle.italic),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Registration from ${voting.regBegin.toString()} until ${voting.regEnd.toString()}',
            style: TextStyle(
              color: isRegistrationOpen ? Colors.green : Colors.red,
              fontSize: fontSizeMedium,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Voting from ${voting.voteBegin.toString()} until ${voting.voteEnd.toString()}',
            style: TextStyle(
              color: isVoteOpen ? Colors.green : Colors.red,
              fontSize: fontSizeMedium,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {},
                    child: Center(
                      child: Text('Register'),
                    )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {},
                    child: Center(
                      child: Text('Vote'),
                    )),
              ),
            ),
          ],
        )
      ],
    );
  }
}

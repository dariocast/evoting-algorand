import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/core/models/voting.dart';
import 'package:algorand_evoting/modules/voting_detail/voting_detail.dart';
import 'package:algorand_evoting/utils/services/rest_api_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VotingDetailPage extends StatelessWidget {
  const VotingDetailPage({Key? key}) : super(key: key);

  static Route route(Voting voting) {
    return MaterialPageRoute(
        builder: (_) => BlocProvider(
              create: (context) => VotingDetailBloc(
                  accountRepo: context.read<AccountRepository>(),
                  voting: voting)
                ..add(VotingDetailLoaded()),
              child: VotingDetailPage(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final voting = context.select((VotingDetailBloc bloc) => bloc.state.voting);
    final state = context.watch<VotingDetailBloc>().state;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(voting.title),
          actions: [
            // isRegistrationTime(state) || isVotingTime(state)
            !isRegistrationTime(state) && !isVotingTime(state)
                ? IconButton(
                    onPressed: () async {
                      final globalState = await _getGlobalState(voting);
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        builder: (context) => globalState.length > 0
                            ? Container(
                                height: 400,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: globalState
                                      .map((entry) => Text(
                                            '${entry.name}: ${entry.counter}',
                                            style: TextStyle(
                                              fontSize: fontSizeLarge,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )
                            : Center(
                                child: Text('No results'),
                              ),
                      );
                    },
                    icon: Icon(Icons.leaderboard),
                  )
                : Container(),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: _buildDetails(context),
        ),
      ),
    );
  }

  _buildDetails(BuildContext context) {
    final state = context.watch<VotingDetailBloc>().state;
    final isRegistrationOpen = isRegistrationTime(state);
    final isVoteOpen = isVotingTime(state);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          // flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  state.voting.description ?? 'Description unavailable',
                  style: TextStyle(
                      fontSize: fontSizeXXLarge, fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Available options'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: state.voting.options
                    .map((element) => Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              element,
                              style: TextStyle(
                                fontSize: fontSizeXLarge,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 100.0),
          child: Column(
            children: [
              Text(
                'This voting requires one unit of the following asset: ',
              ),
              Text(
                state.assetName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: fontSizeLarge),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Registration from ${DateFormat('yyyy-MM-dd HH:mm').format(state.voting.regBegin)} to ${DateFormat('yyyy-MM-dd HH:mm').format(state.voting.regEnd)}',
            style: TextStyle(
              color: isRegistrationOpen ? Colors.green : Colors.red,
              fontSize: fontSizeMedium,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Voting from ${DateFormat('yyyy-MM-dd HH:mm').format(state.voting.voteBegin)} to ${DateFormat('yyyy-MM-dd HH:mm').format(state.voting.voteEnd)}',
            style: TextStyle(
              color: isVoteOpen ? Colors.green : Colors.red,
              fontSize: fontSizeMedium,
            ),
          ),
        ),
        state.loading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: LinearProgressIndicator(),
                ),
              )
            : !isRegistrationOpen && !isVoteOpen
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text('This voting is closed, check results'),
                    ),
                  )
                : _buildActions(state, context)
      ],
    );
  }

  Widget _buildActions(VotingDetailState votingState, BuildContext context) {
    if (!votingState.optedIn) {
      return BlocListener<VotingDetailBloc, VotingDetailState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text('Successfully registered for voting')));
        },
        listenWhen: (previous, current) => previous.optedIn != current.optedIn,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                context.read<VotingDetailBloc>().add(VotingDetailOptedIn());
              },
              child: Center(
                child: Text('Register'),
              )),
        ),
      );
    } else if (votingState.optedIn && !votingState.voted) {
      return BlocListener<VotingDetailBloc, VotingDetailState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Thank you. Your vote counts!')));
        },
        listenWhen: (previous, current) => previous.voted != current.voted,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () async {
                final choice = await showConfirmationDialog(
                  context: context,
                  title: 'Vote',
                  message: 'Choose the option you want to vote for.',
                  actions: votingState.voting.options
                      .map((e) => AlertDialogAction(key: e, label: e))
                      .toList(),
                );
                if (choice != null && choice.length > 0) {
                  context
                      .read<VotingDetailBloc>()
                      .add(VotingDetailVoted(choice));
                }
              },
              child: Center(
                child: Text('Vote'),
              )),
        ),
      );
    } else
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'You have already voted for this voting',
          style: TextStyle(
            fontSize: fontSizeLarge,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            backgroundColor: Colors.lightGreen[300],
          ),
        ),
      );
  }

  bool isVotingTime(VotingDetailState state) {
    return DateTime.now().isAfter(state.voting.voteBegin) &&
        DateTime.now().isBefore(state.voting.voteEnd);
  }

  bool isRegistrationTime(VotingDetailState state) {
    return DateTime.now().isAfter(state.voting.regBegin) &&
        DateTime.now().isBefore(state.voting.regEnd);
  }

  Future<List<VoteTally>> _getGlobalState(Voting voting) async {
    List<VoteTally> counters = List.empty(growable: true);
    RestApiResponse response =
        await RestApiService.votingGlobalState(voting.votingId);
    if (response.status == 200) {
      (response.data as Map).forEach((key, value) {
        if (voting.options.contains(key)) {
          counters.add(VoteTally(key, value));
        }
      });
    }
    return counters;
  }
}

class VoteTally {
  final String name;
  final int counter;

  VoteTally(this.name, this.counter);
}

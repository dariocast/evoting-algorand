import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:algorand_evoting/modules/home/repository/home_repository.dart';
import 'package:algorand_evoting/modules/modules.dart';

import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/modules/voting_creation/voting_creation.dart';
import 'package:algorand_evoting/modules/voting_detail/voting_detail.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
              create: (context) =>
                  HomeBloc(context.read<AccountBloc>(), HomeRepository())
                    ..add(HomeStarted()),
              child: HomePage(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: () => context.read<HomeBloc>().add(
                  HomeStarted(),
                ),
          ),
          IconButton(
              icon: Icon(Icons.qr_code),
              onPressed: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    context: context,
                    builder: (context) {
                      AccountLoaded state =
                          context.read<AccountBloc>().state as AccountLoaded;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'This is your address, use it to receive voting tokens',
                                style: TextStyle(
                                  fontSize: fontSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: state.account!.publicAddress));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      content: Text('Copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ));
                                },
                                child: Text(
                                  state.account!.publicAddress,
                                  style: TextStyle(
                                    fontSize: fontSizeMedium,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0,
                                  right: 30.0,
                                  top: 8.0,
                                  bottom: 8.0),
                              child:
                                  QrImage(data: state.account!.publicAddress),
                            ),
                          ],
                        ),
                      );
                    });
              }),
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.red,
            onPressed: () async {
              final result = await showOkCancelAlertDialog(
                context: context,
                title: 'Clear account',
                message:
                    'This will remove your existing account. Make sure you backed up the passphrase before continuing or you will lose your account.',
              );
              if (result == OkCancelResult.ok) {
                context.read<AccountBloc>().add(
                      AccountDeleteRequested(),
                    );
              }
            },
          ),
        ],
      ),
      body: state.loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildList(state: state),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.plus_one_rounded),
        onPressed: () async {
          bool success =
              await Navigator.of(context).push(VotingCreationPage.route());
          if (success) {
            // ! Need this because of indexer per second requests...
            await Future.delayed(const Duration(seconds: 1));
            context.read<HomeBloc>().add(
                  HomeStarted(),
                );
          }
        },
      ),
    );
  }
}

class _buildList extends StatelessWidget {
  const _buildList({
    Key? key,
    required this.state,
  }) : super(key: key);

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.votings.length > 0) {
      return ListView.builder(
        itemCount: state.votings.length,
        itemBuilder: (context, index) {
          final isRegistrationOpen =
              DateTime.now().isAfter(state.votings[index].regBegin) &&
                  DateTime.now().isBefore(state.votings[index].regEnd);
          return ListTile(
              title: Text(state.votings[index].title),
              subtitle: Text(state.votings[index].description ?? ''),
              trailing: isRegistrationOpen
                  ? Text(
                      'OPEN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  : Text(
                      'CLOSED',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
              onTap: () => Navigator.of(context).push(
                    VotingDetailPage.route(state.votings[index]),
                  ),
              onLongPress: () async {
                final result = await showOkCancelAlertDialog(
                  context: context,
                  title: 'Are you sure?',
                  message: 'This will remove the voting from the system.',
                );
                if (result == OkCancelResult.ok) {
                  context
                      .read<HomeBloc>()
                      .add(HomeDeleteVoting(state.votings[index]));
                }
              });
        },
      );
    } else {
      return Center(
        child: Text('No votings available or server offline'),
      );
    }
  }
}

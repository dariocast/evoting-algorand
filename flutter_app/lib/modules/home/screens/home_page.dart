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
      drawer: Drawer(
        child: _buildDrawer(context),
      ),
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: () => context.read<HomeBloc>().add(
                  HomeStarted(),
                ),
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
            // ! Need this because of indexer per second requests limit...
            await Future.delayed(const Duration(seconds: 1));
            context.read<HomeBloc>().add(
                  HomeStarted(),
                );
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final accountState = context.read<AccountBloc>().state;
    final address = accountState is AccountLoaded
        ? accountState.account!.publicAddress
        : '';
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: address));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ));
                      },
                      child: QrImage(
                        backgroundColor: Colors.white,
                        data: address,
                      ),
                    )),
                    Positioned(
                      bottom: 10.0,
                      right: 8.0,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Text(
                          'Send voting assets to your address\n(Here on QR)',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                trailing: Icon(Icons.format_list_bulleted),
                title: Text('Your passphrase'),
                onTap: () => _showPassphrase(context, accountState),
              ),
              ListTile(
                trailing: Icon(Icons.card_membership),
                title: Text('Your assets'),
                onTap: () => _showAssets(context, accountState),
              ),
            ],
          ),
        ),
        Spacer(),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: InkWell(
            onTap: () async {
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
            child: Center(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showPassphrase(BuildContext context, AccountState accountState) async {
    final passphrase = accountState is AccountLoaded
        ? await accountState.account!.seedPhrase
        : null;
    final splitPhrase = passphrase != null
        ? [
            passphrase.getRange(0, 8),
            passphrase.getRange(8, 17),
            passphrase.getRange(17, passphrase.length),
          ]
        : null;
    Navigator.of(context).pop();
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                child: Text('Your Passphrase'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(
                    child: Container(
                      height: 500,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: splitPhrase![0]
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          '${splitPhrase[0].toList().indexOf(e) + 1}. $e',
                                          style: TextStyle(
                                            fontSize: fontSizeMedium,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: splitPhrase[1]
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          '${splitPhrase[1].toList().indexOf(e) + 9}. $e',
                                          style: TextStyle(
                                            fontSize: fontSizeMedium,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: splitPhrase[2]
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          '${splitPhrase[2].toList().indexOf(e) + 17}. $e',
                                          style: TextStyle(
                                            fontSize: fontSizeMedium,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                child: Text(
                    'Make sure you record these words in the correct\norder, using the corresponding numbers'),
              ),
            ],
          );
        });
  }

  _showAssets(BuildContext context, AccountState accountState) {
    final HomeState homeState = context.read<HomeBloc>().state;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          if (homeState.assets.length == 0)
            return Center(child: Text("You don't have any assets"));
          else {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: homeState.assets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Column(
                    children: [
                      Icon(Icons.receipt_outlined),
                      Text(
                        homeState.assets[index].isCreator ? 'creator' : '',
                        style: TextStyle(fontSize: fontSizeMicro),
                      ),
                    ],
                  ),
                  title: Text(homeState.assets[index].name),
                  subtitle: Text(
                    'balance: ${homeState.assets[index].balance.toString()} ${homeState.assets[index].unitName}',
                  ),
                  trailing: Text(
                    'ID: ${homeState.assets[index].id}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          }
        });
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

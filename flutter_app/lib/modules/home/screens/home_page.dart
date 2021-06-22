import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:algorand_evoting/modules/home/repository/home_repository.dart';
import 'package:algorand_evoting/modules/modules.dart';

import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            icon: Icon(Icons.delete_forever),
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
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: state.votings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.votings[index].title),
                  subtitle: Text(state.votings[index].description ?? ''),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.plus_one_rounded),
        onPressed: () {},
      ),
    );
  }
}

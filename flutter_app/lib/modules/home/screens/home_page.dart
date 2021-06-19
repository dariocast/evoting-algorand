import 'package:algorand_evoting/utils/services/algorand_service.dart';
import 'package:algorand_evoting/modules/modules.dart';

import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? passphrase;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountBloc>().state;
    if (state is AccountLoaded) {
      state.account!.seedPhrase.then((words) {
        setState(() {
          print(passphrase);
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.red,
            onPressed: () {
              context.read<AccountBloc>().add(
                    AccountDeleteRequested(),
                  );
            },
          ),
        ],
      ),
      body: Center(
        child: state is AccountLoaded
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(passphrase ?? ''),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

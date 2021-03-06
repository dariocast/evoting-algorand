import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/modules/voting_creation/voting_creation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VotingCreationPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => VotingCreationPage());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create a voting'),
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: BlocProvider(
            create: (context) =>
                VotingCreationBloc(context.read<AccountRepository>())
                  ..add(VotingCreationStarted()),
            child: VotingCreationForm(),
          ),
        ),
      ),
    );
  }
}

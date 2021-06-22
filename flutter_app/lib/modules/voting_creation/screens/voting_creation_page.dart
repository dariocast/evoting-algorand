import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/modules/voting_creation/voting_creation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VotingCreationPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => VotingCreationPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a voting'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: BlocProvider(
          create: (context) => VotingCreationBloc(),
          child: VotingCreationForm(),
        ),
      ),
    );
  }
}

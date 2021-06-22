import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/constants/app_constants.dart';
import 'package:algorand_evoting/core/account_repository/account_repository.dart';
import 'package:algorand_evoting/widgets/widgets.dart';

import '../wallet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (_) => WalletBloc(
          accountRepository: RepositoryProvider.of<AccountRepository>(context),
        ),
        child: WalletPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.message),
            ),
          );
          context.read<WalletBloc>().add(WalletStarted());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Wallet',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create or import an account',
                style: Theme.of(context).textTheme.headline5?.copyWith(
                      fontSize: fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              VerticalSpacing(of: paddingSizeNormal),
              WalletCard(
                title: 'Create',
                subtitle: 'a new account',
                onTapped: () async {
                  final result = await showOkCancelAlertDialog(
                    context: context,
                    title: 'Create new account',
                    message: 'This will generate a whole new account.',
                  );

                  if (result == OkCancelResult.ok) {
                    context.read<WalletBloc>().add(
                          WalletCreateStarted(),
                        );
                  }
                },
              ),
              VerticalSpacing(of: paddingSizeNormal),
              WalletCard(
                title: 'Import',
                subtitle: 'existing account',
                onTapped: () async {
                  final input = await showTextInputDialog(
                    textFields: [DialogTextField()],
                    context: context,
                    title: 'Recover from Passphrase',
                    message: 'Recover an account with a 25-word passphrase.',
                  );

                  if (input != null && input.length > 0) {
                    context.read<WalletBloc>().add(
                          WalletImportStarted(passphrase: input[0]),
                        );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       body: Padding(
  //     padding: EdgeInsets.all(paddingSizeDefault),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Wallets',
  //           style: Theme.of(context).textTheme.headline5?.copyWith(
  //                 fontSize: fontSizeXLarge,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //         ),
  //         VerticalSpacing(of: paddingSizeNormal),
  //         Text(
  //           'Create or import a wallet to start sending and receiving digital currency',
  //           style: Theme.of(context).textTheme.bodyText1?.copyWith(),
  //         ),
  //         Spacer(),
  //         WalletCard(
  //           title: 'Create',
  //           subtitle: 'a new wallet',
  //           onTapped: () {
  //             context.read<WalletBloc>().createWallet();
  //           },
  //         ),
  //         VerticalSpacing(of: paddingSizeNormal),
  //         WalletCard(
  //           title: 'Import',
  //           subtitle: 'an existing wallet',
  //           textColor: Palette.white,
  //           backgroundColor: Palette.accentColor,
  //           onTapped: () {
  //             context.read<WalletBloc>().importWallet(testnetPassphrase);
  //           },
  //         ),
  //         Spacer(
  //           flex: 2,
  //         ),
  //       ],
  //     ),
  //   ));
  // }
}

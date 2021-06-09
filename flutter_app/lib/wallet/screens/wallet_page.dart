import '../../account/account.dart';
import '../../config/themes/themes.dart';
import '../../constants/app_constants.dart';
import '../../core/account_repository/account_repository.dart';
import '../wallet.dart';
import '../../widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => WalletPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: BlocProvider(
          create: (context) {
            return WalletBloc(
              accountRepository:
                  RepositoryProvider.of<AccountRepository>(context),
            );
          },
          child: WalletView(),
        ),
      ),
    );
  }
}

class WalletView extends StatelessWidget {
  const WalletView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallets',
            style: Theme.of(context).textTheme.headline5?.copyWith(
                  fontSize: fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
          ),
          VerticalSpacing(of: paddingSizeNormal),
          Text(
            'Create or import a wallet to start sending and receiving digital currency',
            style: Theme.of(context).textTheme.bodyText1?.copyWith(),
          ),
          Spacer(),
          WalletCard(
            title: 'Create',
            subtitle: 'a new wallet',
            onTapped: () {
              context.read<WalletBloc>().createWallet();
            },
          ),
          VerticalSpacing(of: paddingSizeNormal),
          WalletCard(
            title: 'Import',
            subtitle: 'an existing wallet',
            textColor: Palette.white,
            backgroundColor: Palette.accentColor,
            onTapped: () {
              context.read<WalletBloc>().importWallet(testnetPassphrase);
            },
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}

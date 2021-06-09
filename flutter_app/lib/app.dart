import 'config/routes/app_router.dart';
import 'core/account_repository/account_repository.dart';
import 'home/home.dart';
import 'splash/splash.dart';
import 'wallet/wallet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'account/account.dart';

class App extends StatelessWidget {
  const App({
    required this.accountRepository,
  });

  final AccountRepository accountRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: accountRepository,
      child: BlocProvider(
        create: (_) => AccountBloc(
          accountRepository: accountRepository,
        ),
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            print(state);
            if (state is AccountLoaded) {
              _navigator.pushAndRemoveUntil(
                HomePage.route(),
                (route) => false,
              );
            } else {
              _navigator.pushAndRemoveUntil(
                WalletPage.route(),
                (route) => false,
              );
            }
          },
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}

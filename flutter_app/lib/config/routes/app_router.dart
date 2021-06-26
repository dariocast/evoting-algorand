import 'package:algorand_evoting/config/themes/themes.dart';
import 'package:algorand_evoting/modules/modules.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      case '/wallet':
        return MaterialPageRoute(
          builder: (context) => WalletPage(),
        );
      case '/splash':
        return MaterialPageRoute(
          builder: (context) => SplashPage(),
        );
      default:
        return null;
    }
  }
}

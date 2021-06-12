import '../themes/themes.dart';
import '../../home/home.dart';
import '../../splash/screens/splash_page.dart';
import '../../wallet/wallet.dart';

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

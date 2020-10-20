import 'package:carniceriaDelivery/Providers/Push_notification_Provider.dart';
import 'package:flutter/material.dart';
import 'package:carniceriaDelivery/Screens/Welcome/welcome_screen.dart';
import 'package:carniceriaDelivery/constants.dart';
import 'package:provider/provider.dart';

import 'Providers/loginState.dart';
import 'Screens/Login/login_screen.dart';
import 'Screens/scanqr.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  /*void initState() {
      super.initState();
    final pushProvider = new pushNotifProvider();
    pushProvider.initNotifications();
  }*/
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginState>(create: (_) => LoginState()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Carniceria',
          theme: ThemeData(
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
          ),
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) {
              var state = Provider.of<LoginState>(context, listen: false);
              if (state.isLoggedIn()) {
                return QrScan();
              } else {
                return LoginScreen();
              }
            }
          }
          // WelcomeScreen(),
          ),
    );
  }
}

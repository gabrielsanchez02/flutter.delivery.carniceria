import 'file:///D:/gaby/Aplicaciones/App%20Carniceria/flutter.delivery.carniceria/lib/Providers/loginState.dart';
import 'package:carniceriaDelivery/Screens/scanqr.dart';
import 'package:flutter/material.dart';
import 'package:carniceriaDelivery/Screens/Signup/signup_screen.dart';
import 'package:carniceriaDelivery/Screens/Welcome/components/background.dart';
import 'package:carniceriaDelivery/components/rounded_button.dart';
import 'package:carniceriaDelivery/constants.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    // ignore: missing_required_param
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Carniceria Iñaki...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, fontFamily: 'Raleway'),
            ),
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/images/isolologo1.png",
              height: size.height * 0.30,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              text: "ACCEDER",
              conIcono: false,
              press: () {
                if (Provider.of<LoginState>(context, listen: false).isLoggedIn() == true)
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => QrScan()));
              },
            ),
            RoundedButton(
              text: "CREA TU CUENTA",
              color: kPrimaryLightColor,
              textColor: Colors.black,
              conIcono: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

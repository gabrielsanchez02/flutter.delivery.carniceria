import 'package:flutter/material.dart';

import 'package:accesosqr/Screens/Signup/signup_screen.dart';
import 'package:accesosqr/Screens/Welcome/components/background.dart';
import 'package:accesosqr/components/rounded_button.dart';
import 'package:accesosqr/constants.dart';

import '../../scanqr.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Control de Ingresos",
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return QrScan();
                    },
                  ),
                );
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

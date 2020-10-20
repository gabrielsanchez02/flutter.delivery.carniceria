import 'package:carniceriaDelivery/Screens/Escaneo/escaneo_screen.dart';
import 'file:///D:/gaby/Aplicaciones/App%20Carniceria/flutter.delivery.carniceria/lib/Providers/loginState.dart';
import 'package:flutter/material.dart';
import 'package:carniceriaDelivery/Screens/Login/components/background.dart';
import 'package:carniceriaDelivery/components/already_have_an_account_acheck.dart';
import 'package:carniceriaDelivery/components/rounded_button.dart';
import 'package:carniceriaDelivery/components/rounded_input_field.dart';
import 'package:carniceriaDelivery/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "escanear",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "Tu email",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "Loguearse ",
              conIcono: false,
              press: () {
                Provider.of<LoginState>(context, listen: false).login();
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Escaneo2()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

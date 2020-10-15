import 'package:accesosqr/Screens/Escaneo/escaneo_screen.dart';
import 'package:flutter/material.dart';
import 'package:accesosqr/Screens/Login/components/background.dart';
import 'package:accesosqr/Screens/Signup/signup_screen.dart';
import 'package:accesosqr/components/already_have_an_account_acheck.dart';
import 'package:accesosqr/components/rounded_button.dart';
import 'package:accesosqr/components/rounded_input_field.dart';
import 'package:accesosqr/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';

class Body extends StatelessWidget {
  const Body({
    Key key,
  }) : super(key: key);

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
              text: "ACCEDER",
              conIcono: false,
              press: () {},
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

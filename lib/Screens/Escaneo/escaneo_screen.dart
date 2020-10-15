import 'package:flutter/material.dart';

import 'package:accesosqr/components/rounded_button.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class Escaneo2 extends StatefulWidget {
  const Escaneo2({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EscaneoState();
  }
}

class EscaneoState extends State {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _barcode = "";
  String _codQRleido;
  var _dni = TextEditingController(text: "");
  var _sexo = TextEditingController();

  String _nomtripulante = "";
  String _apptripulante = " ";
  bool _isButtonDisabled;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Ingreso",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              text: "INGRESO POR QR",
              conIcono: false,
              press: () {
                scan();
              },
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this._barcode = barcode;
        var string = _barcode;
        _codQRleido = _barcode;

        var dni2 = string.split('@');
        print('es de los otros DNI');
        print(dni2);
        if (string[0] == '@') {
          print('es de los otros DNI');
          _dni.text = dni2[1];
          _sexo.text = dni2[8];
          _nomtripulante = dni2[5];
          _apptripulante = dni2[4];
          _isButtonDisabled = false;
        } else {
          // print(string);
          // dni2.forEach((txt) => print(txt));
          // print(dni2);
          // print(dni2.take(5).skip(4).take(1).toList());
          _dni.text = dni2[4];
          _sexo.text = dni2[3];
          _nomtripulante = dni2[2];
          _apptripulante = dni2[1];
          // print('el dni es: ' + dni.toString());
          // print('el sexo es: ' + sex.toString());
          _isButtonDisabled = false;
        }

        if (_sexo.text == "M") {
          _sexo.text = "masculino";
        }
        if (_sexo.text == "F") {
          _sexo.text = "femenino";
        }
      });
      _barcode = "";
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this._barcode = 'El usuario no dio permiso para el uso de la cámara!';
        });
      } else {
        setState(() => this._barcode = 'Error desconocido $e');
      }
    } on FormatException {
      setState(() => this._barcode = 'El usuario presionó el botón de volver antes de escanear algo');
    } catch (e) {
      setState(() => this._barcode = 'Error desconocido : $e');
    }
  }
}

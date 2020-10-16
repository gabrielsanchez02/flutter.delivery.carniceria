import 'dart:convert';
import 'package:carniceriaDelivery/components/rounded_button.dart';
import 'package:carniceriaDelivery/components/rounded_input_field.dart';
import 'package:carniceriaDelivery/estilos/colores.dart';
import 'package:carniceriaDelivery/estilos/fuentes.dart';
import 'package:carniceriaDelivery/services/storeLogin.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:carniceriaDelivery/models/tripulantes.dart';
import 'dart:convert' as convert;

import 'package:simple_connectivity/simple_connectivity.dart';

import '../constants.dart';
import 'Welcome/components/background.dart';
import 'Welcome/welcome_screen.dart';

class QrScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanQrState();
  }
}

class ScanQrState extends State<QrScan> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _barcode = "";
  var _dni = TextEditingController(text: "");
  var _sexo = TextEditingController();

  TextStyle style = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18.0,
  );
  bool _isButtonDisabled;
  bool _isCargando;
  bool _isEnviado;
  bool _botonQR;
  bool _botonManual;
  bool _escaneoManual;
  bool _botonURL;
  static int _cantConsultas = 0;
  static int _cantPersonas = 0;

  String _estado = 'Seleccione Estado';
  String _nomUsuario;
  String _titulo;
  String _nomtripulante = "";
  String _apptripulante = " ";

  String _deviceid = "";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;

  String board, brand, device, hardware, host, id, manufacture, model, product, type, androidid;
  bool isphysicaldevice;
  bool _isCargaManual = false;
  bool _isSexoSeleccionado = false;
  bool _isEscaneoQr = true;
  bool isLoading;
  bool _isPress;
  String _codQRleido;
  bool conectado = null;
  Position _position;
  Geolocator geolocator;
  bool isLocationEnabled = null;

  bool desencolando = false;
  static List<Consulta> encolados = [];
  Consulta _consultaToPush = new Consulta();

  var _nomT = TextEditingController();
  var _appT = TextEditingController();

  ScanQrState();

  // get sex => null;

  @override
  void initState() {
    _codQRleido = " ";
    _isButtonDisabled = true;
    _isCargando = true;
    _isEnviado = false;
    // _nomUsuario = usuario.usuario;
    _deviceid = "usuario.nombre_apellido";
    _sexo.text = "Género";
    _escaneoManual = false;
    _botonQR = true;
    _botonManual = true;
    _botonURL = true;
    _isEscaneoQr = false;
    isLoading = true;
    _isPress = false;
    _titulo = "Control de Ingreso";
    // getDeviceinfo();
    //OfflineHttp.initiate();
    // storeLogin.initiate();
    // storeLogin.storageConsultas.clear();
    //encolados.clear();
    getUbicacion();
    checkConection();
    getDeviceinfo();
    if (desencolando == false) {
      desencolar();
    }
    eliminaDesencolados();
    print("Consultas encoladas ${encolados.length}");

    ComparaCacheListY_Encolados();
  }

  void eliminaDesencolados() async {
    if (conectado == true) {
      if (encolados.length != 0) {
        storeLogin.CachelistConsultas = await storeLogin().getListPostFromCache();
        var i = 0, total = 0, enviados = 0;
        int tamanio = encolados.length;
        while (encolados[i] != null) {
          if (encolados[i].enviado == true) {
            //await encolados.remove(encolados[i]);
            if (storeLogin.CachelistConsultas != null) {
              storeLogin().CacheDelete_ELEMENT_Encolados(total);
              print("Elemento ${total} eliminado de cache");
              total++;
            }
            enviados++;
          }
          i++;
          if (tamanio == i) break;
        }
        if (tamanio == enviados && storeLogin.CachelistConsultas == null) {
          encolados.clear();
          List<Consulta> o = await storeLogin().RecorreGetList(enviados);
          if (o != null && encolados.length == 0) {
            print("Elementos agregados pendiente en cache");
            encolados = storeLogin.CachelistConsultas;
          }
        }
      }
    }
  }

  void desencolar() async {
    if (conectado == true) {
      if (encolados.length > 0) {
        desencolando = true;

        var i, _Element;
        for (i = 0; i < encolados.length; i++) {
          print("encolados  ${i} ");
          _Element = encolados[i];
          if (_Element != null) {
            print("Elemento ${i} esta enviado = ${_Element.enviado}"); // todos los a enviar
            if (encolados[i].enviado == false) {
              try {
                var response = await http.post(_Element.url.toString(),
                    body: _Element.body.toString(),
                    headers: Map<String, String>.from(_Element.headers),
                    encoding: _Element.encoding);
                if (await response.statusCode == 200) {
                  print("OK Enviado Desencolado! ${i}");
                  // encolados[i].enviado = true;
                  //print("idConsulta:${_Element.idConsulta} esta enviado = ${_Element.enviado}");
                  _Element.enviado = true;
                  encolados[i] = _Element;
                  _displaySnackBarGreen(context, 'Conectado! desencolando elementos! ${i}');
                } else {
                  print("Error Enviando");
                  encolados[i].enviado = false;
                  print("Encolado");
                }
              } catch (ex) {
                print("Elemento ${i} no se pudo enviar ${ex}");
                _Element.enviado = false;
                encolados[i] = _Element;
                _displaySnackBarred(context, 'Desconectado!Elemento ${i} sin enviar');
              }
            } else {}
          }
        }
        if (i == encolados.length) {
          desencolando = false;
        }
      }
    }
  }

  void ComparaCacheListY_Encolados() async {
    await storeLogin.storageConsultas.ready;
    storeLogin.CachelistConsultas = await storeLogin().getListPostFromCache();
    if (conectado == true) {
      if (encolados.length == 0) {
        if (storeLogin.CachelistConsultas != null) {
          if (storeLogin.CachelistConsultas.length > encolados.length) {
            print("El tamaño de las listas es mayor el de la cache");
            encolados = storeLogin.CachelistConsultas; //asigno la lista de cache a proxima a desencolar
            if (await storeLogin().CacheDeleteEncolados() == true) {
              //elimino la lista de cache
              storeLogin.CachelistConsultas = await storeLogin().getListPostFromCache();
              if (storeLogin.CachelistConsultas == null) print("la lista de cache esta vacia");
            } else {
              print("la lista en chache tiene ${storeLogin.CachelistConsultas.length} elementos");
            }
          }
        }
      }
    }
  }

  void checkConection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.

      setState(() {
        conectado = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      setState(() {
        conectado = true;
      });
    } else if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        conectado = false;
      });
    }
  }

  void getDeviceinfo() async {
    androidDeviceInfo = await deviceInfo.androidInfo; // instantiate Android Device Infoformation

    setState(() {
      board = androidDeviceInfo.board;
      brand = androidDeviceInfo.brand;
      device = androidDeviceInfo.device;

      hardware = androidDeviceInfo.hardware;
      host = androidDeviceInfo.host;
      id = androidDeviceInfo.id;
      manufacture = androidDeviceInfo.manufacturer;
      model = androidDeviceInfo.model;
      product = androidDeviceInfo.product;

      type = androidDeviceInfo.type;
      isphysicaldevice = androidDeviceInfo.isPhysicalDevice;
      androidid = androidDeviceInfo.androidId;
    });
  }

  _displaySnackBarGreen(BuildContext context, String texto) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(milliseconds: 100),
      elevation: 1,
      backgroundColor: Colors.green,
      content: Text(texto),
    ));
  }

  _displaySnackBarred(BuildContext context, String texto) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(milliseconds: 50),
      elevation: 1,
      backgroundColor: Colors.red,
      content: Text(texto),
    ));
  }

  _displaySnackBarredUBI(BuildContext context, String texto) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      elevation: 1,
      backgroundColor: Colors.red,
      content: Text(texto),
    ));
  }

  Future<String> getUbicacion() async {
    //  final GeolocationResult result = await Geolocation.isLocationOperational();
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _displaySnackBarredUBI(context, "Debe activar la ubicacion para continuar");
    }
    Position position;
    if (isLocationEnabled) {
      print('_position en getUbic');
      print(_position);
      try {
        position =
            await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best).timeout(new Duration(seconds: 5));
        setState(() {
          _position = position;
          isLocationEnabled;
        });
        print('Ubicacion de dispositivo');
        print(_position);
      } catch (e) {
        setState(() {});
        //_checkGps();
        // _showActivaGPS();
        print('Error: ${e.toString()}');
      }
    } else if (_position != null) {
      // await last known position
      position = await geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _position = position;
        isLocationEnabled;
      });
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 5,
            contentPadding: EdgeInsets.all(5),
            title: Text('Desea confirmar?'),
            children: <Widget>[
              ListTile(
                title: Text(
                  "Confirmar",
                  style: TextStyle(fontSize: 20),
                ),
                leading: Icon(
                  Icons.save,
                  color: Colors.green,
                  size: 50,
                ),
                onTap: () {
                  Navigator.pop(context);

                  // MensajeState();
                },
              ),
              ListTile(
                title: Text("Cancelar"),
                leading: Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 50,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _showciudadanoCargado() {
    // flutter defined function
    showDialog(
        context: context,
        builder: (context) {
          //cancelar();
          initState();
          return SimpleDialog(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: blueColor),
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                )),
            elevation: 15,
            contentPadding: EdgeInsets.all(20),
            title: Container(
                alignment: Alignment.center,
                child: Center(
                    child: Text(
                  'Ciudadano cargado correctamente!',
                  style: whitebotonTextStyle,
                ))),
            titlePadding: EdgeInsets.all(20.0),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.person_add,
                              color: primaryTextColor,
                              size: 20,
                            ),
                            Text(
                              "CARGAR NUEVO",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        onPressed: () {
                          cancelar();
                          initState();
                          setState(() {
                            _apptripulante = "";
                            _nomtripulante = "";
                            _dni.text = "";
                            _isEscaneoQr = true;
                            _botonManual = false;
                            _botonQR = false;
                            _isCargando = true;
                            _botonURL = false;
                            _titulo = "Acceso mediante QR";
                            checkConection();
                          });
                          Navigator.pop(context);
                          scan();
                          // cancelar();
                        },
                      ),
                    ),
                    SizedBox(width: 25),
                    Container(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.exit_to_app,
                              color: primaryTextColor,
                              size: 20,
                            ),
                            Text(
                              "salir",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 21),
                            ),
                          ],
                        ),
                        onPressed: () {
                          cancelar();
                          initState();
                          Navigator.pop(context);
                          // cancelar();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _showPantallaCompleta(String texto, bool band, Icon ico) {
    // flutter defined function
    showGeneralDialog(
        barrierDismissible: false,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (BuildContext context, Animation animation, Animation seconAnimation) {
          return Center(
            child: (Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: RaisedButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 50,
                      ),
                      Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    // cancelar();
                  },
                ),
              ),
            )),
          );
        });
  }

  _displaySnackBar(BuildContext context, String texto) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      elevation: 0,
      backgroundColor: primaryColor,
      content: Text(texto),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_titulo),
        /*Text("Control Ciudadano")*/
        leading: GestureDetector(
          onTap: () {
            setState(() {
              initState();
            });
          },
          child: Icon(
            Icons.arrow_back, // add custom icons also
          ),
        ),
        actions: <Widget>[
          /*Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        UsuarioInfo(usuario: usuario)));
              },
              child: Icon(
                Icons.person_pin,
                size: 26.0,
              ),
            )),*/
          Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  return showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                          backgroundColor: hintTextColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: primaryTextColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              )),
                          title: new Text(
                            '¿Desea cerrar sesión?',
                            style: primaryHeadingTextStyle,
                          ),
                          //content: new Text('Se perderán los cambios.'),
                          actions: <Widget>[
                            Column(
                              children: <Widget>[
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: secondaryColor),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      )),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        "Si",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    storeLogin().CachedeleteUSR();
                                    /*
                                    initState(); */
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()));
                                  },
                                ),
                                SizedBox(
                                  width: 280,
                                ),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: secondaryColor),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      )),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        "No",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                child: Icon(Icons.exit_to_app),
              )),
        ],
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => Center(child: selector(context)),
      ),
    );
  }

  Widget selector(BuildContext context) {
    final _formKeyManual = GlobalKey<FormState>();

    Future<void> enviarData() async {
      if (_escaneoManual) {
        if (_sexo.text == "Género") _displaySnackBar(context, "Debe seleccionar el campo Género");

        if (_formKeyManual.currentState.validate()) {}
        _codQRleido = _nomtripulante + "." + _apptripulante + "." + _sexo.text;
      }
      if (!_isButtonDisabled) {
        // _showPantallaConfirmacion("Dede Escanear un DNI", false);
        bool todoOk = true;
        String _campoFaltante = "nada";
        if (_dni.text == "") {
          todoOk = false;
          _campoFaltante = "DNI";
        }

        setState(() {
          _isPress = true;
          //_isCargando = false;
        });

        if (todoOk) {
          await checkConection();
          consumeWs(
            _dni.text,
            _sexo.text,
            _position.latitude,
            _position.longitude,
            _codQRleido,
            '1234567',
            id,
            '0.0.1',
          ).catchError((e) {
            _displaySnackBar(context, "Error ");
            print(e);
          }).then((e) {
            if (e == "false") {
              _displaySnackBar(context, "Error 2 ");
            } else {
              _showciudadanoCargado();
            }
          });
        } else {
          _displaySnackBar(context, "falto campo requerido : " + _campoFaltante);
        }
      } else {
        // _showPantallaCompleta("Dede Escanear un DNI", false, Icon(Icons.error));
        // print('el boton esta deshabilitado')
      }
    }

    return Background(
      child: Container(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              //SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Visibility(
                    visible: false,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: Text(
                            "Ingresá los datos del ciudadano",
                            style: primaryHeadingTextStyle,
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: secondaryColor),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  )),
                              color: secondaryColor,
                              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                              textColor: Colors.black,
                              splashColor: Colors.green,
                              elevation: 4.0,
                              onPressed: () {
                                setState(() {
                                  _apptripulante = "";
                                  _nomtripulante = "";
                                  _dni.text = "";
                                  _isEscaneoQr = true;
                                  _botonManual = false;
                                  _botonQR = false;
                                  _isCargando = true;
                                  _botonURL = false;
                                  _titulo = "Acceso mediante QR";
                                  checkConection();
                                });
                              },
                              child: Text("Ingresar D.N.I con código QR",
                                  textAlign: TextAlign.center, style: whiteSubHeadingTextStyle),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ), //Boton qr
                  Visibility(
                    visible: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            _apptripulante + " " + _nomtripulante,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            _dni.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        RoundedInputField(
                          controlador: _dni,
                          hintText: "Ingrese D.N.I",
                          icon: Icons.chrome_reader_mode,
                          it: TextInputType.text,
                          onChanged: (value) {},
                        ),
                        RoundedButton(
                          text: "LEER DNI CON QR",
                          color: kPrimaryColor,
                          conIcono: false,
                          press: () {
                            getUbicacion();
                            if (isLocationEnabled) {
                              scan();
                            } else {
                              _displaySnackBarredUBI(context, "Debe activar la ubicacion para continuar");
                            }
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            _barcode,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ), //Escane qr
                  Visibility(
                    visible: false,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: secondaryColor),
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          )),
                      color: secondaryColor,
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      textColor: Colors.black,
                      splashColor: Colors.green,
                      elevation: 4.0,
                      onPressed: () {
                        setState(() {
                          _appT.text = "";
                          _nomT.text = "";
                          _dni.text = "";
                          _isEscaneoQr = false;
                          _escaneoManual = true;
                          _botonManual = false;
                          _botonQR = false;
                          _isCargando = true;
                          _botonURL = false;
                          _titulo = "Acceso D.N.I manual";
                          checkConection();
                        });
                      },
                      child: Text("Ingresar D.N.I manualmente", textAlign: TextAlign.center, style: whiteSubHeadingTextStyle),
                    ),
                  ), //Boton carga Manual
                  Visibility(
                    visible: _escaneoManual,
                    child: Form(
                      key: _formKeyManual,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            //Padding(padding: const EdgeInsets.only(top: 50)),
                            TextFormField(
                              controller: _appT,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                //filled: true,
                                //  fillColor: hintTextColor,
                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 15.0),
                                hintText: "Apellido",
                                hintStyle: subTitleStyle,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              //decoration: InputDecoration(labelText: "Apellido"),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'El campo APELLIDO no puede estar vacío';
                                } else {
                                  if (value.length < 3) {
                                    return 'El campo APELLIDO debe tener al menos 3 caracteres';
                                  } else {
                                    setState(() {
                                      _apptripulante = value;
                                    });
                                    return null;
                                  }
                                }
                              },
                              onChanged: (String newVal) {
                                _apptripulante = newVal;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: _nomT,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                //filled: true,
                                // fillColor: hintTextColor,
                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 15.0),
                                hintText: "Nombre",
                                hintStyle: subTitleStyle,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                ),
                              ),
                              onChanged: (String newVal) {
                                _nomtripulante = newVal;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'El campo NOMBRE no puede estar vacío';
                                } else {
                                  if (value.length < 3) {
                                    return 'El campo NOMBRE debe tener al menos 3 caracteres';
                                  } else {
                                    setState(() {
                                      _nomtripulante = value;
                                    });
                                    return null;
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: _dni,
                              keyboardType: TextInputType.number,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                //filled: true,
                                //fillColor: hintTextColor,
                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 15.0),
                                hintText: "D.N.I",
                                hintStyle: subTitleStyle,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'El campo D.N.I no puede estar vacío';
                                } else {
                                  if (value.length < 7) {
                                    return 'El campo D.N.I debe tener al menos 7 caracteres';
                                  } else {
                                    return null;
                                  }
                                }
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Visibility(
                              visible: _isSexoSeleccionado == false,
                              child: DropdownButton<String>(
                                value: _sexo.text,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 50,
                                iconEnabledColor: Colors.red[700],
                                elevation: 8,
                                isExpanded: true,
                                underline: Container(
                                  height: 1,
                                  color: Colors.black45,
                                ),
                                onChanged: (String val) {
                                  setState(() {
                                    _sexo.text = val;
                                    _isSexoSeleccionado = false;
                                  });
                                  if (_formKeyManual.currentState.validate()) {
                                    _isButtonDisabled = false;
                                  }
                                },
                                items: <String>['Género', 'masculino', 'femenino'].map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), //Form escaneo manual
                  Visibility(
                    visible: false, //_botonURL,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: secondaryColor),
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          )),
                      color: secondaryColor,
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      textColor: Colors.black,
                      splashColor: Colors.blueGrey,
                      onPressed: () {
                        setState(() {
                          String url = "http://compromisociudadano.sanjuan.gob.ar/index.php?id=$_deviceid";

                          // launch(url);
                          /* _isEscaneoQr = false;
                          _escaneoManual = false;
                          _botonManual = false;
                          _botonQR = false;
                          _isCargando = false;*/
                          initState();
                        });
                      },
                      child: Text("Registrar Dispositivo",
                          textAlign: TextAlign.center, style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ), //Url Redireccion
                  Visibility(
                    visible: _isCargando,
                    child: Column(
                      children: [
                        RoundedButton(
                          text: !_isButtonDisabled ? "CONFIRMAR" : " INGRESE UN DNI",
                          color: !_isButtonDisabled ? kSecondaryColor : kPrimaryLightColor,
                          textColor: !_isButtonDisabled ? kPrimaryLightColor : kPrimaryColor,
                          conIcono: false,
                          press: _isPress ? null : enviarData,
                        ),
                        Visibility(
                          visible: _isPress,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  /*
                  Visibility(
                      visible: _isCargando,
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FloatingActionButton.extended(
                                      splashColor: Colors.green,
                                      elevation: 4.0,
                                      label: Row(
                                        children: <Widget>[
                                          Icon(!_isButtonDisabled ? Icons.send : Icons.error),
                                          new Text(
                                            !_isButtonDisabled ? "Confirmar" : " Cargar Datos",
                                            style: whitebotonTextStyle,
                                          ),
                                        ],
                                      ),
                                      onPressed: _isPress ? null : enviarData),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _isPress,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ],
                      )),
                      */
                  SizedBox(
                    height: 50.0,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text("Factor de Ocupación del salón ",
                            textAlign: TextAlign.center, style: style.copyWith(color: Colors.white)),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: CircleAvatar(
                            radius: 30,
                            child: Text(_cantPersonas.toString(),
                                textAlign: TextAlign.center,
                                style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0)),
                          ),
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: primaryColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50.0),
                              )),
                          color: primaryColor,
                          padding: EdgeInsets.fromLTRB(10.0, 5, 10.0, 5.0),
                          textColor: Colors.black,
                          splashColor: Colors.blueAccent,
                          elevation: 4.0,
                          onPressed: () {
                            setState(() {
                              if (_cantPersonas > 0) _cantPersonas--;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("persona salió", textAlign: TextAlign.center, style: whiteSubHeadingTextStyle),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Empresa: ",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black45, fontSize: 12),
                            ),
                            Text(
                              '1234567',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[700], fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          "ID: $id",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ), // Boton enviar datos
                  /*Container(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 1.0, top: 80.0, bottom: 1.0),
                    alignment: Alignment.bottomLeft,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      color: Colors.grey[700],
                      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      textColor: Colors.black,
                      splashColor: Colors.redAccent,
                      onPressed: () {
                        setState(() {
                          initState();
                        });
                      },
                      child: Text("Volver",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),*/ //Bton volver
                  /* RaisedButton(
                    color: Colors.blueAccent[700],
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    textColor: Colors.black,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      _showciudadanoCargado();
                    },
                    child: Text("mostrar",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    setState(() {
      initState();
    });
  }

/*
  Future<String> consumeWsCa(
      _xdni,
      _xsexo,
      _xTel,
      _xdominio,
      _xestado,
      _xnombre,
      _xapp,
      _esTransportista,
      _esResidente,
      _domicilio,
      _empresa,
      xIdDispositivo,
      xVersionApp,
      xprovincia,
      xdestino,
      xcontenido,
      xpais,
      xtipoScand,
      xTemperatura) async {
    setState(() {
      _isCargando = true;
      _isEnviado = false;
      // if (_escaneoManual) _isCargando = false;
    });

    void getsex() {
      var sex;
      if (_xsexo == "masculino")
        sex = "M";
      else
        sex = "F";
      setState(() {
        sex;
      });
    }

    String username = 'gobElec1';
    String password = 'g0b3lec1';

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    // print(basicAuth);
    Map<String, String> headers = {'content-type': 'application/json', 'accept': 'application/json', 'authorization': basicAuth};

    final msg = jsonEncode({
      "IdProyecto": "448",
      "nombreBAM": "",
      "plantilla": "",
      "camposExtras": {
        "campoExtra": [
          {"campo": "filtro_unico", "valor": "118;" + _xdni + ";119;" + _xsexo + "", "id": ""},
          {"campo": "Nombre", "valor": "$_xnombre", "id": "116"},
          {"campo": "apellido", "valor": "$_xapp", "id": "117"},
          {"campo": "Dni", "valor": "$_xdni", "id": "118"},
          {"campo": "Sexo", "valor": "$_xsexo", "id": "119"},
          {"campo": "Usuario", "valor": "$_xdni.$_xsexo.$_nomtripulante $_apptripulante", "id": "213"},
          {"campo": "ID Dispositivo", "valor": "$xIdDispositivo", "id": "271"},
        ]
      }
    });
    final encod = Encoding.getByName("utf8");
    try {
      Response r = await OfflineHttp.post(
          "https://soa.sanjuan.gob.ar/redmine/get_insert_uptdate",
          true, // intentarEnvioOnlineUnaVez
          headers,
          msg,
          encod);
      print(r.statusCode);
      print(msg);
      print(r.body);
      if (r.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(r.body);
        // print('Respuesta Ok');
        // print(jsonResponse);
        final serverError = jsonResponse["error"];
        print(serverError);
        if (jsonResponse["error"] == null) {
          final serverFamilias = jsonResponse["datos"];
          for (Map i in serverFamilias) {
            // comandaItemList.items.add(ComandaItemModel.fromJson(i));
            print(i["descripcion"]);
          }
          setState(() {
            // _barcode = "Enviado!";
            _isCargando = false;
            _isEnviado = true;
          });
        } else {
          _showPantallaCompleta(jsonResponse["error"].toString(), false, Icon(Icons.error));
        }

        return "";

        // var datosFromJson = jsonResponse['datos'];
        // List<String> datosList = new List<String>.from(datosFromJson);

      } else {
        setState(() {
          _isEnviado = true;
          _showPantallaCompleta('Error enviando!', false, Icon(Icons.error));
        });
      }
    } catch (ex) {
      _showPantallaCompleta("Dió Error! $ex", false, Icon(Icons.error));
      return Future.error("dio error! $ex");
    }
  }
*/
  Future<String> consumeWs(_xdni, _xsexo, _xlatitud, _xlongitud, _xcodQRleido, _xdniUsr, _xIdDispositivo, _xVersionApp) async {
    getUbicacion();
    setState(() {
      _isCargando = true;
      _isEnviado = false;
    });

    Map<String, String> headers = {'content-type': 'application/json'};
    if (_position != null && _xlongitud == null) {
      _xlatitud = _position.latitude;

      _xlongitud = _position.longitude;
    }
    /*
    final msg = jsonEncode(<String, String>{
      'dni': _xdni,
      'sexo': _xsexo,
      'latitud': _xlatitud.toString(),
      'longitud': _xlongitud.toString(),
      'codQRleido': _xcodQRleido.toString(),
      'dniUsr': _xdniUsr,
      'IdDispositivo': _xIdDispositivo.toString(),
      'VersionApp': _xVersionApp.toString(),
    });*/
    var url = "http://c1611423.ferozo.com/api/appacceso.php?opcion=3";

    /*final encod = Encoding.getByName("utf-8");*/

    /*_consultaToPush = new Consulta();
    _consultaToPush.SetData(_cantConsultas, url, headers, msg, encod, false);*/
    await checkConection();
    if (conectado) {
      try {
        /*http.Response r = await http.post(url, body: msg);*/
        final http.Response r2 = await http.post(
          'http://c1611423.ferozo.com/api/appacceso.php?opcion=3',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'dni': _xdni,
            'sexo': _xsexo,
            'latitud': _xlatitud,
            'longitud': _xlongitud,
            'codQRleido': _xcodQRleido,
            'dniUsr': _xdniUsr,
            'IdDispositivo': _xIdDispositivo,
            'VersionApp': _xVersionApp,
          }),
        );
        Map<String, dynamic> body = {
          "dni": _xdni,
          'sexo': _xsexo,
          'latitud': _xlatitud.toString(),
          'longitud': _xlongitud.toString(),
          'qr_leido': _xcodQRleido,
          'dniUsr': _xdniUsr,
          'idDispositivo': _xIdDispositivo.toString(),
          'versionapp': _xVersionApp.toString(),
        };
        final http.Response r = await http.post('http://c1611423.ferozo.com/api/appacceso.php?opcion=3',
            headers: {"Accept": "application/json", "Content-Type": "application/x-www-form-urlencoded"},
            encoding: Encoding.getByName("utf-8"),
            body: body);
        print(r.statusCode);
        // print(msg);
        print(r.body);

        if (r.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(r.body);
          final serverError = jsonResponse["error"];
          print(serverError);

          if (jsonResponse["error"] == false) {
            setState(() {
              // _barcode = "Enviado!";
              _isCargando = false;
              _isEnviado = true;
            });
            print("online OK Enviado");
          } else {
            _showPantallaCompleta(jsonResponse["error"].toString(), false, Icon(Icons.error));
          }
          return "true";
          // var datosFromJson = jsonResponse['datos'];
          // List<String> datosList = new List<String>.from(datosFromJson);

        } else {
          /* encolados.insert(0, _consultaToPush);
          //encolados.add(_consultaToPush);
          print("encolado online resp != 200");
          storeLogin().savePostLista(encolados);*/
          setState(() {
            _isEnviado = true;
            // _showPantallaCompleta('Error enviando!', false, Icon(Icons.error));
          });
          _cantConsultas++;
          return "true";
        }
      } catch (ex) {
        // _showciudadanoCargado();
        _showPantallaCompleta("Dió Error! ${ex}", false, Icon(Icons.error));
        setState(() {
          _isPress = false;
        });
        /*  encolados.insert(0, _consultaToPush);
        // encolados.add(_consultaToPush);
        storeLogin().savePostLista(encolados);
        print("encolado online $ex");
        _cantConsultas++;*/
        return Future.error("dio error! $ex");
        //return "";

      }
    } else {
      //encolamil();
      // encolados.add(_consultaToPush);

      /* encolados.insert(0, _consultaToPush);
      storeLogin().savePostLista(encolados);
      print("encolado offline");
      _cantConsultas++;*/
      return "true";
    }
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
      _cantPersonas++;
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

  cancelar() {
    setState(() {
      _dni.clear();
      _nomtripulante = "";
      _apptripulante = "";
      _sexo.clear();
      _estado = "Seleccione Estado";
      _isCargando = false;
      _barcode = "";
      _isEnviado = false;
      _isButtonDisabled = true;
      // _botonQR = true;
      // _botonManual = true;
      //  _botonURL = true;
    });
  }

  Widget _buildOneItem(String nombrePersona, String dniPersona) {
    child:
    return new ListTile(
      title: new Text(nombrePersona),
      subtitle: new Text(dniPersona),
      leading: new Icon(Icons.perm_identity),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Car', icon: Icons.person_add),
  const Choice(title: 'Bicycle', icon: Icons.directions_bike),
  const Choice(title: 'Boat', icon: Icons.directions_boat),
  const Choice(title: 'Bus', icon: Icons.directions_bus),
  const Choice(title: 'Train', icon: Icons.directions_railway),
  const Choice(title: 'Walk', icon: Icons.exit_to_app),
];

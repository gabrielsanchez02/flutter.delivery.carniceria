import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'dart:core';

class storeLogin {
  static LocalStorage storageLogin = new LocalStorage('login');
  static LocalStorage storageConsultas = new LocalStorage('Consultas');
  static PostUsr usuariologueado;
  static List<Consulta> CachelistConsultas;
  static int indice = 0;

  static initiate() async {
    //usuariologueado = await storeLogin().getUsrPostFromCache();
    CachelistConsultas = await storeLogin().getListPostFromCache();
    // print(usuariologueado.toJson());
    //print("getPostFromcache");
  }

  /* Dictionary() {
    const file = 'assets/EnRuBig.json';
  }*/

  void savePostUsr(PostUsr _usr) async {
    await storageLogin.ready;
    storageLogin.setItem("login", _usr);
    print(_usr.toJson());
    print("Usuario guardado en cache");
  }

  void savePostLista(List<Consulta> List) async {
    await storageConsultas.ready;
    //cons.toEncodable();.
    var i = 0;
    indice = List.length;
    List.forEach((element) {
      // ignore: unrelated_type_equality_checks
      storageConsultas.setItem("lista ${i}", element);

      if (List.length > i) {
        print("Elemento ${i} guardado en cache");
      } else if (List.length == i) {
        print("error almacenando elemento de la lista ${i}");
      } else {
        print("Tamaños distintos al savePostLista ${i}");
      }
      i++;
    });
    //CachelistConsultas = await storeLogin().getListPostFromCache();
  }

  Future<List<Consulta>> RecorreGetList(int total) async {
    await storageConsultas.ready;
    int i = 0, j = 0;
    Consulta consul;
    List<Consulta> listConsul = [];
    String data = null;

    for (j = 0; j < total * 2; j++) {
      data = await storageConsultas.getItem("lista ${j}");
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        consul = Consulta.fromJson(map);
        listConsul.add(consul);
        i++;
      }
    }
    if (listConsul.length != 0) {
      indice = i;
      CachelistConsultas = listConsul;
      storageConsultas.clear();
      return listConsul;
    } else {
      return null;
    }
  }

  Future<List<Consulta>> getListPostFromCache() async {
    await storageConsultas.ready;
    int i = 0, j = 0;
    Consulta consul;
    List<Consulta> listConsul = [];
    String data = null;

    print("For de lista = ${indice}");
    for (j = 0; j < indice; j++) {
      data = await storageConsultas.getItem("lista ${j}");
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        consul = Consulta.fromJson(map);
        listConsul.add(consul);
        i++;
      }
    }
    if (data == null) {
      data = await storageConsultas.getItem("lista ${indice}");
    }
    if (data != null) {
      i = indice;
      if (indice == j)
        do {
          data = await storageConsultas.getItem("lista ${i}");
          if (data != null) {
            Map<String, dynamic> map = json.decode(data);
            consul = Consulta.fromJson(map);
            listConsul.add(consul);
            i++;
          }
          data = await storageConsultas.getItem("lista ${i}");
        } while (data != null);
      if (indice < i) {
        indice = i;
      }
    }
    if (listConsul.length == 0) {
      print("lista Data en cache = 0");
      indice = 0;
      return null;
    } else {
      indice = listConsul.length;
      print("cache listConsul cantidad ${listConsul.length}");
      // post.fromCache = true; //to indicate post is pulled from cache
      if (listConsul != null)
        return listConsul;
      else
        return null;
    }
  }

  Future<PostUsr> getUsrPostFromCache() async {
    await storageLogin.ready;
    Map<String, dynamic> data = storageLogin.getItem('login');

    if (data == null) {
      print("no hay un usuario logueado");
      return null;
    }
    PostUsr post = PostUsr.fromJson(data);
    post.fromCache = true; //to indicate post is pulled from cache
    print("Usuario logueado ${post.dni}");
    return post;
  }

  Future<bool> CacheDeleteEncolados() async {
    await storageConsultas.ready;
    //print(usuariologueado.toJson());
    storageConsultas.clear();
    await storageConsultas.ready;
    CachelistConsultas = await storeLogin().getListPostFromCache();
    if (CachelistConsultas == null) {
      return true;
    } else {
      print("cantidad de cachelist = ${CachelistConsultas.length}");
      return false;
    }
  }

  void CachedeleteUSR() async {
    await storageLogin.ready;
    //print(usuariologueado.toJson());
    storageLogin.deleteItem('login');
    usuariologueado = await storeLogin().getUsrPostFromCache();
    await storageLogin.ready;
    print(usuariologueado.toJson());
    print("Usuario eliminado de cache");
  }

  void CacheDelete_ELEMENT_Encolados(int elem) async {
    await storageConsultas.ready;
    // CachelistConsultas = await storeLogin().getListPostFromCache();
    if (CachelistConsultas != null) {
      await storageConsultas.deleteItem("lista ${elem}");
      print("elemento eliminado de cachelist = ${elem}");
      indice--;
      CachelistConsultas = await storeLogin().getListPostFromCache();
      if (CachelistConsultas == null) {
        print("Cachelist = null");
        indice = 0;
      } else {
        print(
            "NO se elimino, cachelist el elemento =${elem} cachelist =${CachelistConsultas.length}");
      }
    }
  }

/*
  Future<PostUsr> getPostFromAPI() async {
    PostUsr post = await fetchPost();
    post.fromCache = false; //to indicate post is pulled from API
    savePostUsr(post);
    return post;
  }

  Future<PostUsr> fetchPost() async {
    String _endpoint = '/login/1';

    dynamic post = await _get(_endpoint);
    if (post == null) {
      return null;
    }
    PostUsr p = new PostUsr.fromJson(post);
    return p;
  }

  Future _get(String url) async {
    String endpoint = '$url';
    try {
      final response = await http.get(endpoint);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (err) {
      throw Exception(err);
    }
  }*/
}

class Consulta {
  int idConsulta;
  String url;
  Map<String, String> headers;
  String body;
  Encoding encoding;
  bool enviado;

  Consulta({
    this.idConsulta,
    this.url,
    this.headers,
    this.body,
    this.encoding,
    this.enviado,
  });

  void SetData(
      int i, String u, Map<String, String> h, String b, Encoding e, bool env) {
    this.idConsulta = i;
    this.url = u;
    this.headers = h;
    this.body = b;
    this.encoding = e;
    this.enviado = env;
  }

  String toJson() {
    return jsonEncode({
      'idConsulta': idConsulta,
      'url': url,
      'headers': headers,
      'body': body,
      'encoding': encoding.toString(),
      'enviado': enviado
    });
  }

  factory Consulta.fromJson(Map<String, dynamic> jsons) {
    Map<String, String> map;
    Map<String, dynamic> head = jsons['headers'];
    map = new Map<String, String>.from(head);
    return Consulta(
      idConsulta: jsons['idConsulta'],
      url: jsons['url'],
      headers: map,
      body: jsons['body'],
      encoding: Encoding.getByName("utf-8"),
      enviado: jsons['enviado'],
    );
  }
}

class PostUsr {
  String dni;
  String nombre;
  String apellido;
  String sexo;
  String body;
  bool fromCache = false;

  PostUsr(
      {this.dni,
      this.nombre,
      this.apellido,
      this.sexo,
      this.body,
      this.fromCache});

  Map<String, dynamic> toJson() => {
        'dni': dni,
        'nombre': nombre,
        'apellido': apellido,
        'sexo': sexo,
        'body': body
      };

  factory PostUsr.fromJson(Map<String, dynamic> json) {
    return PostUsr(
        dni: json['dni'],
        nombre: json['nombre'],
        apellido: json['apellido'],
        sexo: json['sexo'],
        body: json['body']);
  }
}

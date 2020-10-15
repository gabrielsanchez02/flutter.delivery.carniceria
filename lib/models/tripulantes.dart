import 'dart:ffi';

class Usuario {
  final String usuario;
  final String nombre_apellido;
  final String email;
  final String services;
  final String token;
  final String contadorcontrasenia;
  final String resultadoW;
  final String esResidente;
  final String EsTransportista;
  final String telefono;
  final String domicilio;
  final String versionapp;
  final double Latitud;
  final double Longitud;
  final String sexo;
  final String idDispositivo;

  const Usuario(
      this.usuario,
      this.nombre_apellido,
      this.email,
      this.services,
      this.token,
      this.contadorcontrasenia,
      this.resultadoW,
      this.esResidente,
      this.EsTransportista,
      this.telefono,
      this.domicilio,
      this.versionapp,
      this.Latitud,
      this.Longitud,
      this.sexo,
      this.idDispositivo);

  factory Usuario.fromJson(Map j) {
    return Usuario(
        j["usuario"],
        j["nombre_apellido"],
        j["email"],
        j["services"],
        j["token"],
        j["contadorcontrasenia"],
        j["resultadoW"],
        j["esResidente"],
        j["EsTransportista"],
        j["telefono"],
        j["domicilio"],
        j["versionapp"],
        j["Latitud"],
        j["Longitud"],
        j["sexo"],
        j["idDispositivo"]);
  }
}

class Persona {
  final String nombre;
  final String apellido;
  final String dni;
  final String sexo;
  final String telefono;
  final String esResidente;
  final String esTransportista;
  final String domicilio;
  final String empresa;
  final String dominio;
  final String estado;
  final String provincia;
  final String destino;
  final String contenido;
  final String pais;
  final int temperatura;
  final String Latitud;
  final String Longitud;

  const Persona(
      this.nombre,
      this.apellido,
      this.dni,
      this.sexo,
      this.telefono,
      this.esResidente,
      this.esTransportista,
      this.domicilio,
      this.empresa,
      this.dominio,
      this.estado,
      this.provincia,
      this.destino,
      this.contenido,
      this.pais,
      this.temperatura,
      this.Latitud,
      this.Longitud);
  factory Persona.fromJson(Map p) {
    return Persona(
      p["nombre"],
      p["apellido"],
      p["dni"],
      p["sexo"],
      p["telefono"],
      p["esResidente"],
      p["esTransportista"],
      p["domicilio"],
      p["empresa"],
      p["dominio"],
      p["estado"],
      p["provincia"],
      p["destino"],
      p["contenido"],
      p["pais"],
      int.parse(p["temperatura"].toString()),
      p["Latitud"],
      p["Longitud"],
    );
  }
}

class Acompaniantes {
  final String nombre;
  final String apellido;
  final String dni;
  final String sexo;
  final String telefono;
  final String temperatura;
  const Acompaniantes(this.nombre, this.dni, this.sexo, this.telefono,
      this.apellido, this.temperatura);
}

class Country {
  final String name;
  final String capital;
  final String region;
  final int population;

  const Country({this.name, this.capital, this.region, this.population});
}

// final listaAco = [new Acompaniantes("nito", "262")];

final countries = [
  new Country(
      name: 'Belarus', capital: 'Minsk', region: 'Europe', population: 9498700),
  new Country(
      name: 'Bulgaria',
      capital: 'Sofia',
      region: 'Europe',
      population: 7153784),
  new Country(
      name: 'Czech Republic',
      capital: 'Prague',
      region: 'Europe',
      population: 10558524),
  new Country(
      name: 'Denmark',
      capital: 'Copenhagen',
      region: 'Europe',
      population: 5717014),
  new Country(
      name: 'Italy', capital: 'Rome', region: 'Europe', population: 60665551),
  new Country(
      name: 'Liechtenstein',
      capital: 'Vaduz',
      region: 'Europe',
      population: 37623),
  new Country(
      name: 'Norway', capital: 'Oslo', region: 'Europe', population: 5223256),
  new Country(
      name: 'Spain', capital: 'Madrid', region: 'Europe', population: 46438422),
  new Country(
      name: 'Sweden',
      capital: 'Stockholm',
      region: 'Europe',
      population: 9894888),
  new Country(
      name: 'Ukraine', capital: 'Kiev', region: 'Europe', population: 42692393),
];

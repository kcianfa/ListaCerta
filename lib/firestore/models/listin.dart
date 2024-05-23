class Listin {
  String id;
  String name;

  Listin({required this.id, required this.name}); //construtor

  Listin.fromMap(Map<String, dynamic> map) //construtor nomeado
      : id = map["id"],
        name = map["name"];

  Map<String, dynamic> toMap() { //pega o objeto do tipo list e vai transformar ele em um map, importante quando vamos enviar 
    return {
      "id": id,
      "name": name,
    };
  }
}

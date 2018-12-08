class Pergunta {
  int id;
  String texto;

  Pergunta();

  // Customizacao do == para comparar dois objetos
  bool operator ==(o) =>
      o is Pergunta && o.id == id && o.texto == texto;
  int get hashCode => id.hashCode ^ texto.hashCode;

  // Construtor que transforma um Map em Pergunta
  Pergunta.fromMap(Map map) {
    id = map["id"];
    texto = map["texto"];
  }

  // Transforma o objeto em um mapa para ser inserido no BD
  Map toMap() {
    Map<String, dynamic> map = {"texto": texto};

    if (id != null) map["id"] = id;

    return map;
  }

  @override
  String toString() {
    return "Pergunta (id: $id, texto: $texto)\n";
  }
}
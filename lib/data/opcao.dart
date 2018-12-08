class Opcao {
  int id;
  String texto;

  Opcao();

  // Customizacao do == para comparar dois objetos
  bool operator ==(o) =>
      o is Opcao && o.id == id && o.texto == texto;
  int get hashCode => id.hashCode ^ texto.hashCode;

  // Construtor que transforma um Map em Opcao
  Opcao.fromMap(Map map) {
    id = map["id"];
    texto = map["texto"];
  }

  // Transforma o objeto em um mapa para ser inserido no BD
  Map toMap() {
    Map<String, dynamic> map = {"text": texto};

    if (id != null) map["id"] = id;

    return map;
  }

  @override
  String toString() {
    return "Opção (id: $id, texto: $texto)\n";
  }
}

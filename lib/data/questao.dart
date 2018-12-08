import 'package:sqflite_app/data/pergunta.dart';
import 'package:sqflite_app/data/opcao.dart';

class Questao {
  int id;

  Pergunta pergunta;

  List<Opcao> opcoes;

  Questao();

  Questao.fromMap(Map map) {
    id = map["id"];
  }

  Map toMap() {
    Map<String, dynamic> map = {};

    if (id != null) map["id"] = id;

    return map;
  }

  @override
  String toString() {
    return "Questão (id: $id pergunta: $pergunta, opções: $opcoes)\n";
  }
}

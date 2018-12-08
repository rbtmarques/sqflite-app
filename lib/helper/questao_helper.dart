import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:sqflite_app/data/pergunta.dart';
import 'package:sqflite_app/data/opcao.dart';
import 'package:sqflite_app/data/questao.dart';

class QuestaoHelper {
  // Singleton para instanciar o BD
  static final QuestaoHelper _instance = QuestaoHelper.internal();
  factory QuestaoHelper() => _instance;
  QuestaoHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db == null) _db = await initDb();

    return _db;
  }

  /// Funcao que inicializa ou importa o BD, depende
  /// se o mesmo ja foi importado ou nao
  Future<Database> initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "questoes.db");

    // Tenta abrir o banco de dados
    Database db;
    try {
      db = await openDatabase(path, readOnly: true);
    } catch (e) {
      print("Error $e");
    }

    // Nao existindo ele importa da pasta assets
    if (db == null) {
      print("\n---------Criando uma nova copia do assets---------\n");

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "questoes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);

      // open the database
      db = await openDatabase(path, readOnly: true);
    } else {
      print("\n---------Abrindo banco de dados existente---------\n");
    }

    return db;
  }

  /// Busca as [Questoes]
  Future<List> getFormulario() async {
    Database appDatabase = await db;

    // Busca as perguntas
    List listMapPergunta = await appDatabase.rawQuery('''
      SELECT pergunta.*
      FROM questao
      INNER JOIN pergunta ON questao.id_pergunta = pergunta.id
      GROUP BY questao.id_pergunta;
      ''');

    // Busca as opcoes de cada pergunta
    List listMapOpcoes = await appDatabase.rawQuery('''
      SELECT questao.id_pergunta, opcao.*
      FROM questao 
      INNER JOIN opcao ON questao.id_opcao = opcao.id;
      ''');

    List<Questao> listObjects = List();

    // Para cada pergunta cria uma questao (Pergunta + Opcoes)
    listMapPergunta.forEach((p) {
      // Retorna as opcoes da pergunta
      Questao questao = Questao();
      questao.pergunta = Pergunta.fromMap(p);
      questao.opcoes = [];

      var opcoes =
          listMapOpcoes.where((o) => o["id_pergunta"] == questao.pergunta.id);

      for (Map o in opcoes) {
        Opcao opcao = Opcao.fromMap(o);
        questao.opcoes.add(opcao);
      }

      listObjects.add(questao);
    });

    return listObjects;
  }

  Future<Questao> getObject({int id}) async {
    Database appDatabase = await db;

    List<Map> maps = await appDatabase.query("questao",
        columns: [
          "id",
          "id_pergunta",
          "id_opcao",
        ],
        where: "id = ?",
        whereArgs: [id]);

    return (maps.length > 0) ? Questao.fromMap(maps.first) : null;
  }

  Future close() async {
    Database appDatabase = await db;

    appDatabase.close();
  }
}

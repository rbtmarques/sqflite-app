import 'package:flutter/material.dart';

import 'package:sqflite_app/data/pergunta.dart';
import 'package:sqflite_app/data/opcao.dart';
import 'package:sqflite_app/data/questao.dart';
import 'package:sqflite_app/helper/questao_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  List<Questao> _questoes = <Questao>[];
  Map<Pergunta, Opcao> _respostas = <Pergunta, Opcao>{};

  /// Carrega as informacoes iniciais
  /// Busca [Questoes] ([Pergunta] + [Opcoes])
  void _loadInfo() async {
    // Verificar o tipo do ponto e buscar as questoes
    QuestaoHelper helper = QuestaoHelper();
    var questoes = await helper.getFormulario();
    setState(() => _questoes = questoes);
  }

  /// Apresenta um [Dialog] com a pergunta completa
  Widget _infoQuestao(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Pergunta:'),
                content: Text(_questoes[index].pergunta.texto),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('Fechar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      child: Icon(Icons.help_outline),
    );
  }

  /// Constroi para cada [Questao] um [Dropdown]
  Widget _buildDropdown(BuildContext context, int index) {
    Pergunta pergunta = _questoes[index].pergunta;
    Opcao op = (_respostas[pergunta] != null) ? _respostas[pergunta] : null;

    return FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: pergunta.texto,
            prefixIcon: _infoQuestao(context, index),
            errorText: state.hasError ? state.errorText : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: op,
              onChanged: (Opcao itemSelecionado) {
                setState(() {
                  // Se a resposta para a pergunta ja existe entao apenas atualiza
                  (_respostas.containsKey(pergunta))
                      ? _respostas.update(pergunta, (value) => itemSelecionado)
                      : _respostas[pergunta] = itemSelecionado;
                  state.didChange(itemSelecionado);
                });
              },
              items: _questoes[index].opcoes.map((Opcao opcao) {
                return DropdownMenuItem<Opcao>(
                  value: opcao,
                  child: Text(opcao.texto),
                );
              }).toList(),
            ),
          ),
        );
      },
      validator: (_) {
        return (op == null) ? "Opção inválida!" : null;
      },
    );
  }

  @override
  void initState() {
    _loadInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questoes"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Perguntas
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: _questoes.length,
                  itemBuilder: (context, index) {
                    return _buildDropdown(context, index);
                  },
                ),
              ),
              // Botao Salvar
              SizedBox(
                height: 44.0,
                child: RaisedButton(
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    (_formKey.currentState.validate())
                        ? print(_respostas)
                        : null;
                  },
                ),
              ),
            ],
          )),
    );
  }
}

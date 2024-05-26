import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '../../model/home_page/curso.dart';
import '../../util/util_style.dart';

class FormEnvioDeMsgWidget extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _controllerMsg;
  final MultiSelectController<String> _selectController;

  const FormEnvioDeMsgWidget(
      this._formKey, this._controllerMsg, this._selectController,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormEnvioDeMsgWidgetState();
  }
}

class FormEnvioDeMsgWidgetState extends State<FormEnvioDeMsgWidget> {
  final FocusNode _nodeMsg = FocusNode();
  final FocusNode _nodeTurmas = FocusNode();
  final List<ValueItem<String>> listaTurmas = [];
  bool turmaValida = true;

  bool validaTurmaSelecionada() {
    var aux = widget._selectController.selectedOptions.isEmpty;
    setState(() {
      turmaValida = !aux;
    });
    return !aux;
  }

  @override
  void initState() {
    _getTurmas();
    super.initState();
  }

  Future<void> _getTurmas() async {
    var snap = await FirebaseFirestore.instance.collection('turmas').get();
    List<DocumentSnapshot<Object?>> turmas = snap.docs;
    List<ValueItem<String>> aux = [];

    for (var snapshot in turmas) {
      var data = snapshot.data() as Map<String, dynamic>;
      var curso = await _getDadosCurso(snapshot['curso']);
      aux.add(ValueItem<String>(
          label:
              '${curso.nome} ${data['complemento'] ?? ''} - ${data['semestre']}° semestre - ${data['periodo']}',
          value: snapshot.id));
    }

    setState(() {
      listaTurmas.clear();
      listaTurmas.addAll(aux);
      widget._selectController.setOptions(listaTurmas);
      if (listaTurmas.length == 1 &&
          widget._selectController.selectedOptions.isEmpty) {
        widget._selectController.setSelectedOptions([listaTurmas.first]);
      }
    });
  }

  Future<Curso> _getDadosCurso(DocumentReference curso) async {
    DocumentSnapshot ds = await curso.get();
    var data = ds.data() as Map<String, dynamic>;
    return Curso(data['nome']);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
      child: Form(
        key: widget._formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MultiSelectDropDown<String>(
              focusNode: _nodeTurmas,
              onOptionSelected: (List<ValueItem> selectedOptions) {},
              controller: widget._selectController,
              options: listaTurmas,
              selectionType: SelectionType.multi,
              dropdownHeight: 300,
              optionTextStyle:
                  const TextStyle(fontSize: 13, color: Colors.white),
              selectedOptionIcon: const Icon(Icons.check_circle),
              hint: 'Selecione a(s) turma(s)',
              borderColor: turmaValida
                  ? UtilStyle.instance.corPrimaria
                  : const Color.fromRGBO(186, 26, 26, 1),
              borderWidth: 1.5,
              dropdownBackgroundColor: Colors.black,
              fieldBackgroundColor: Colors.transparent,
              selectedOptionBackgroundColor:
                  UtilStyle.instance.corPrimaria.withOpacity(1),
              optionsBackgroundColor: Colors.white12,
            ),
            turmaValida
                ? const Text('')
                : const Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Text(
                      'Selecione pelo menos uma turma',
                      style: TextStyle(
                          color: Color.fromRGBO(186, 26, 26, 1), fontSize: 11),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
                focusNode: _nodeMsg,
                controller: widget._controllerMsg,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Mensagem',
                  labelStyle: _labelTextStyle(),
                  enabledBorder: _enabledBorder(),
                  focusedBorder: _focusBorder(),
                ),
                validator: (text) {
                  if (text!.isEmpty) {
                    return 'Informe a mensagem';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (widget._controllerMsg.text.isEmpty) {
                    widget._formKey.currentState?.validate();
                  }
                  if (widget._selectController.selectedOptions.isEmpty) {
                    FocusScope.of(context).requestFocus(_nodeTurmas);
                  }
                }),
          ],
        ),
      ),
    );
  }

  TextStyle _labelTextStyle() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.grey,
    );
  }

  InputBorder _focusBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: UtilStyle.instance.corPrimaria,
      ),
    );
  }

  InputBorder _enabledBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: UtilStyle.instance.corPrimaria,
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupost/model/home_page/arquivo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import '../../model/home_page/curso.dart';
import '../../util/util_style.dart';

class FormEnvioDeMsgWidget extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _controllerMsg;
  final MultiSelectController<String> _selectController;
  final FocusNode _nodeMsg = FocusNode();
  final FocusNode _nodeTurmas = FocusNode();
  TextEditingController a = TextEditingController();

  final Function(List<Arquivo>) onArquivosAlterados;

  FormEnvioDeMsgWidget(this._formKey, this._controllerMsg,
      this._selectController, this.onArquivosAlterados,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormEnvioDeMsgWidgetState();
  }
}

class FormEnvioDeMsgWidgetState extends State<FormEnvioDeMsgWidget> {
  final List<ValueItem<String>> listaTurmas = [];
  bool turmaValida = true;
  List<Arquivo> arquivosSelecionados = [];
  final List<String> extensoesPermitidas = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'svg',
    'pdf',
    'doc',
    'docx',
    'odt',
    'txt',
    'rtf',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'mp4',
    'avi',
    'mkv',
  ];

  void _removeFile(Arquivo arq) {
    setState(() {
      arquivosSelecionados.remove(arq);
    });
    widget.onArquivosAlterados(arquivosSelecionados);
  }

  @override
  void initState() {
    super.initState();
    // _getTurmas();
  }

  String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }

  Future<void> uploadFile(context) async {
    // Seleciona o arquivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: extensoesPermitidas,
        type: FileType.custom);

    if (result != null) {
      var files = result.files;
      for (var arq in files) {
        File file = File(arq.path!);
        String mimeType = getMimeType(arq.path!);
        var a = Arquivo(arq.name, '', mimeType, file);
        arquivosSelecionados.add(a);
      }
      setState(() {});
      widget.onArquivosAlterados(arquivosSelecionados);
    }
  }

  Future<List<ValueItem<String>>> _getTurmas() async {
    var snap = await FirebaseFirestore.instance.collection('turmas').get();
    List<DocumentSnapshot<Object?>> turmas = snap.docs;
    List<ValueItem<String>> aux = [];

    for (var snapshot in turmas) {
      var data = snapshot.data() as Map<String, dynamic>;
      aux.add(ValueItem<String>(
          label:
              '${data['curso']} ${data['complemento'] ?? ''} - ${data['semestre']}° semestre - ${data['periodo']}',
          value: snapshot.id));
    }
    return aux;
    // setState(() {
    //   listaTurmas.clear();
    //   listaTurmas.addAll(aux);
    //   widget._selectController.setOptions(listaTurmas);
    //   if (listaTurmas.length == 1 &&
    //       widget._selectController.selectedOptions.isEmpty) {
    //     widget._selectController.setSelectedOptions([listaTurmas.first]);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ValueItem<String>>>(
      future: _getTurmas(),
      builder: (context, d) {
        if (d.connectionState == ConnectionState.waiting) {
          const Column(
            children: [
              Expanded(
                  child: Center(
                child: CircularProgressIndicator(),
              ))
            ],
          );
        }
        if (!d.hasData) {
          return const Text(
              'Nenhuma turma cadastrada. Cadastre pelo menos uma turma antes de enviar um aviso');
        }
        return Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, top: 40),
          child: Form(
            key: widget._formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MultiSelectDropDown<String>(
                  focusNode: widget._nodeTurmas,
                  onOptionSelected: (List<ValueItem> selectedOptions) {},
                  controller: widget._selectController,
                  options: d.data!,
                  selectionType: SelectionType.multi,
                  dropdownHeight: 300,
                  optionTextStyle: TextStyle(
                      fontSize: 13, color: UtilStyle.instance.foreGroundColor),
                  selectedOptionIcon: const Icon(Icons.check_circle),
                  hint: 'Selecione a(s) turma(s)',
                  borderColor: turmaValida
                      ? UtilStyle.instance.corPrimaria
                      : UtilStyle.instance.corErro,
                  borderWidth: 1.5,
                  dropdownBackgroundColor: UtilStyle.instance.backGroundColor,
                  fieldBackgroundColor: Colors.transparent,
                  selectedOptionBackgroundColor:
                      UtilStyle.instance.corPrimaria.withOpacity(1),
                  optionsBackgroundColor: Colors.white12,
                ),
                turmaValida
                    ? const Text('')
                    : Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          'Selecione pelo menos uma turma',
                          style: TextStyle(
                              color: UtilStyle.instance.corErro, fontSize: 11),
                        ),
                      ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          focusNode: widget._nodeMsg,
                          controller: widget._controllerMsg,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                              color: UtilStyle.instance.foreGroundColor),
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
                              // widget._formKey.currentState?.validate();
                            }
                            if (widget
                                ._selectController.selectedOptions.isEmpty) {
                              // FocusScope.of(context).requestFocus(_nodeTurmas);
                            }
                          }),
                    ),
                    IconButton(
                        onPressed: () => uploadFile(context),
                        icon: const Icon(Icons.attach_file)),
                  ],
                ),
                if (arquivosSelecionados.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: arquivosSelecionados.map((arquivo) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            color: const WidgetStatePropertyAll(Colors.grey),
                            deleteIconColor: UtilStyle.instance.foreGroundColor,
                            labelStyle: TextStyle(
                                color: UtilStyle.instance.foreGroundColor),
                            label: Text(arquivo.nome),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              _removeFile(arquivo);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
    return OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: UtilStyle.instance.corPrimaria,
      ),
    );
  }
}

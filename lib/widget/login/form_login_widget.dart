import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

import '../../util/util_style.dart';

class FormLoginWidget extends StatefulWidget {
  final TextEditingController _controllerLogin;
  final TextEditingController _controllerPassword;
  final GlobalKey<FormState> _formKey;

  const FormLoginWidget(
      this._formKey, this._controllerLogin, this._controllerPassword,
      {key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FormLoginWidgetState();
}

class FormLoginWidgetState extends State<FormLoginWidget> {
  bool _obscureText = true;
  bool _showIconEye = false;
  FocusNode _nodePassword = FocusNode();
  FocusNode _nodeLogin = FocusNode();

  @override
  void initState() {
    super.initState();

    widget._controllerPassword.addListener(() {
      if (widget._controllerPassword.text.isEmpty) {
        setState(() {
          _showIconEye = false;
        });
      } else {
        setState(() {
          _showIconEye = true;
          _obscureText = true;
        });
      }
    });
  }

  void _changeObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Form(
        key: widget._formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              focusNode: _nodeLogin,
              controller: widget._controllerLogin,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                enabledBorder: _enabledBorder(),
                focusedBorder: _focusBorder(),
                labelText: 'Login',
                labelStyle: _labelTextStyle(),
                prefixIcon: Icon(
                  FontAwesomeIcons.userLarge,
                  color: UtilStyle.instance.colorLogin,
                  size: 16,
                ),
              ),
              style: const TextStyle(
                color: Colors.grey,
              ),
              validator: (text) {
                if (text!.isEmpty) {
                  return 'Informe o login';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (widget._controllerLogin.text.isEmpty) {
                  widget._formKey.currentState?.validate();
                } else {
                  if (widget._controllerPassword.text.isEmpty) {
                    FocusScope.of(context).requestFocus(_nodePassword);
                  }
                }
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: widget._controllerPassword,
              focusNode: _nodePassword,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: _showIconEye
                    ? InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _changeObscureText();
                  },
                  child: Icon(
                      _obscureText
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 16,
                      color: UtilStyle.instance.colorLogin),
                )
                    : null,
                enabledBorder: _enabledBorder(),
                focusedBorder: _focusBorder(),
                labelStyle: _labelTextStyle(),
                prefixIcon: Icon(
                  FontAwesomeIcons.lock,
                  color: UtilStyle.instance.colorLogin,
                  size: 16,
                ),
              ),
              style: _textFormStyle(),
              keyboardType: TextInputType.text,
              obscureText: _obscureText,
              validator: (text) {
                if (text!.isEmpty) {
                  return 'Informe a senha';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (widget._controllerPassword.text.isEmpty) {
                  widget._formKey.currentState?.validate();
                } else {
                  if (widget._controllerLogin.text.isEmpty) {
                    FocusScope.of(context).requestFocus(_nodeLogin);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelTextStyle() {
    return TextStyle(
      fontSize: 13,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle _textFormStyle() {
    return const TextStyle(
      color: Colors.grey,
    );
  }

  InputBorder _focusBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade500,
      ),
    );
  }

  InputBorder _enabledBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    );
  }
}

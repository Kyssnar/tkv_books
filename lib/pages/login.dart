import 'package:flutter/material.dart';
import 'package:tkv_books/dao/sesion.dart';
import 'package:tkv_books/dao/usuario_dao.dart';
import 'package:tkv_books/dialogs/simple_dialog.dart';
import 'package:tkv_books/util/screen.dart';
import 'package:tkv_books/widgets/inputPersonalizado.dart';
import 'package:tkv_books/widgets/labelPerzonalizado.dart';
import 'package:tkv_books/widgets/large_button.dart';
import 'package:tkv_books/widgets/page_background.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nickname = TextEditingController();
  final contrasenia = TextEditingController();
  void dispose() {
    //Limpia los controlodadores
    nickname.dispose();
    contrasenia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      header: Image.asset(
        "images/logo.jpg",
        fit: BoxFit.cover,
        height: Screen.height * 0.35, // Responsive
        width: double.infinity,
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            titulo1Label("Login"),
            inputPrincipal("Nickname", nickname),
            inputSecundario("Contraseña", contrasenia),
            LargeButton(
              nombre: "Ingresar",
              accion: _validarUsuario,
              primario: true,
            )
          ],
        ),
      ),
    );
  }

  _validarUsuario() {
    print("Validando");
    _validarDatos();
    try {
      UsuarioDao.existeUsuario(nickname.text, contrasenia.text, context)
          .then((existe) {
        if (existe) {
          _logearUsuario();
        } else {
          _usuarioIncorrectoDialog();
        }
      });
    } catch (e) {
      print(e);
      _sinInternetDialog();
    }
  }

  _validarDatos() {
    if (nickname.text.isEmpty || contrasenia.text.isEmpty) _noHayDatosDialog();
    if (nickname.text.isEmpty) _noHayNicknameDialog();
    if (contrasenia.text.isEmpty) _noHayContraseniaDialog();
  }

  _logearUsuario() {
    UsuarioDao.getUsuarioByNickname(nickname.text).then((user) {
      Sesion.usuarioLogeado = user;
      // ('/perfil/codUusario=1')
      Navigator.of(context).pushReplacementNamed('/perfil');
    });
  }

  _noHayDatosDialog() {
    return SimpleDialogTkv(
            title: "No hay datos",
            content: "Escriba el nickname y la contraseña",
            rightText: "Ok")
        .build(context);
  }

  _sinInternetDialog() {
    return SimpleDialogTkv(
            title: "Sin internet",
            content: "No esta conectado a internet.",
            rightText: "Ok")
        .build(context);
  }

  _noHayNicknameDialog() {
    return SimpleDialogTkv(
            title: "No hay datos",
            content: "Escriba un nickname",
            rightText: "Ok")
        .build(context);
  }

  _noHayContraseniaDialog() {
    return SimpleDialogTkv(
            title: "No hay datos",
            content: "Escriba una contraseña",
            rightText: "Ok")
        .build(context);
  }

  _usuarioIncorrectoDialog() async {
    return SimpleDialogTkv(
            title: "Usuario incorrecto",
            content: "Escribe bien los datos",
            rightText: "Ok")
        .build(context);
  }
}

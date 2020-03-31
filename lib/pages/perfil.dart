// si es su perfil le sale el floating button de aniadir curso
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tkv_books/dao/libro_dao.dart';
import 'package:tkv_books/dao/sesion.dart';
import 'package:tkv_books/dao/usuario_dao.dart';
import 'package:tkv_books/dialogs/agregar_libro_dialog.dart';
import 'package:tkv_books/dialogs/eliminar_libro_dialog.dart';
import 'package:tkv_books/model/libro.dart';
import 'package:tkv_books/model/usuario.dart';
import 'package:tkv_books/util/confirmAction.dart';
import 'package:tkv_books/util/screen.dart';
import 'package:tkv_books/util/temaPersonlizado.dart';
import 'package:tkv_books/util/utilFunctions.dart';
import 'package:tkv_books/widgets/botonPersonalizado.dart';
import 'package:tkv_books/widgets/labelPerzonalizado.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  Usuario usuarioPerfil;

  bool tieneLibros = false;
  @override
  void initState() {
    // traer datos
    _actualizarListaLibros();
    _getLibroLeyendose();
  }

  _getLibroLeyendose() {
    print(Sesion.usuarioLogeado.codLibroLeyendo);
    if (Sesion.usuarioLogeado.codLibroLeyendo != 0) {
      LibroDao.getLibroByCod(Sesion.usuarioLogeado.codLibroLeyendo)
          .then((libro) {
        Sesion.libroLeyendoPorUsuario = libro;
      });
    }
  }

  void _actualizarListaLibros() {
    print("actualizando...");

    LibroDao.getLibrosOfUsuario(Sesion.usuarioLogeado.codUsuario)
        .then((libros) {
      if (libros.lista.isNotEmpty) {
        tieneLibros = true;
        Sesion.librosDelUsuario = libros;
      }
      setState(() {});
    });
  }

  _irAhome() {
    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
  }

  Future<bool> _abrirCerrarSesionDialog() {
    alertaDialog(context, "Cerrar sesion", "Quieres salir de tu cuenta?", "No",
                "Si")
            .then(
          (value) {
            if (value == ConfirmAction.ACCEPT) {
              Sesion.usuarioLogeado = null;
              _irAhome();
              return true;
            }
            return false;
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _abrirCerrarSesionDialog,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.topLeft,
          children: <Widget>[
            Image.asset(
              "images/banner_nubes.jpg",
              fit: BoxFit.cover,
              height: Screen.height * 0.35, // Responsive
              width: double.infinity,
            ),
            botonTercero("Ver todos", _irAlistaTotal),
            _buildEncabezado(),
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32.0),
                  topLeft: Radius.circular(32.0),
                ),
                border: Border.all(
                  color: Colors.black,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 24.0,
                  ),
                ],
                color: Color(0xfffafafa),
              ),
              margin: EdgeInsets.only(
                top: Screen.height * 0.3, // Responsive 266
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                ),
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    titulo1Label("Biblioteca"),
                    tieneLibros
                        ? _buildListaLibros()
                        : Text("Aún no tienes libros agregados"),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:
            //usuarioPerfil.codUsuario == ApiDao.usuarioLogeado.codUsuario?
            FloatingActionButton(
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.black,
            ),
          ),
          backgroundColor: ColoresTkv.cyan,
          child: Icon(
            Icons.add,
          ),
          onPressed: () => _abrirAgregarLibroDialog(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
    //      : null);
  }

  Widget _buildEncabezado() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          titulo1Label(Sesion.usuarioLogeado.nickname),
          subTitulo1Label(Sesion.usuarioLogeado.nombres +
              " " +
              Sesion.usuarioLogeado.apellidos),
        ],
      ),
    );
  }

  Widget _buildListaLibros() {
    return Container(
      height: Screen.height * 0.50,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: Sesion.librosDelUsuario.lista.length,
        itemBuilder: (BuildContext content, int index) {
          return _buildLibroListItem(
            Sesion.librosDelUsuario.lista[index],
          );
        },
      ),
    );
  }

  Widget _buildLibroListItem(Libro libro) {
    String porcentajeTexto =
        porcentajeString(libro.paginasLeidas, libro.paginasTotales);
    double porcentaje =
        porcentajeDouble(libro.paginasLeidas, libro.paginasTotales);
    String paginas = "${libro.paginasLeidas} / ${libro.paginasTotales}";

    Color colorBarra = colorProgressBar(porcentaje);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 4.0,
      ),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(32.0),
          ),
          border: Border.all(
            color: Colors.black,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 16.0,
            ),
          ],
          color: Color(0xfffafafa),
        ),
        //titulo3Label(libro.nombre),
        //subTitulo3Label(libro.autor),
        //FlatButton(
        //    child: Icon(Icons.edit),
        //    onPressed: () => _abrirEditarLibroDialog(libro),
        //  ),
        //FlatButton(
        //  child: Icon(
        //    Icons.delete,
        //  ),
        //  onPressed: () =>
        //      _abrirEliminarLibroDialog(libro.codLibro),
        //)
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Screen.width * 0.05,
                  vertical: 8.0,
                ),
                child: LinearPercentIndicator(
                  backgroundColor: Color(0xFFB7B7B7),
                  width: Screen.width * 0.86,
                  animation: true,
                  lineHeight: 28.0,
                  animationDuration: 2000,
                  percent: porcentaje,
                  center: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(porcentajeTexto),
                      Text(paginas),
                    ],
                  ),
                  progressColor: colorBarra,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: <Widget>[
                    titulo3Label(libro.nombre),
                    subTitulo3Label(libro.autor),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: FlatButton(
                child: Icon(
                  Icons.delete,
                ),
                onPressed: () => _abrirEliminarLibroDialog(libro.codLibro),
              ),
            )
          ],
        ),
      ),
    );
  }

  _abrirEditarLibroDialog(Libro libro) {
    // mostrar dialog de alerta . then(){... if accept
    Sesion.libroLeyendoPorUsuario = libro;
    UsuarioDao.putUsuarioSetLibroLeyendo(
            Sesion.usuarioLogeado.codUsuario, libro.codLibro)
        .then((val) {
      Sesion.usuarioLogeado.codLibroLeyendo = libro.codLibro;
      LibroDao.getLibroByCod(Sesion.usuarioLogeado.codLibroLeyendo)
          .then((libro) {
        Sesion.libroLeyendoPorUsuario = libro;
      });
    });

    //editarLibroDialog(context).then(
    // (value) {
    //  if (value == ConfirmAction.ACCEPT) {
    //   LibroDao.deleteLibro(codLibro);
    //  _actualizarListaLibros();
    //}
    //},
    //);
  }

  _abrirEliminarLibroDialog(int codLibro) {
    // mostrar dialog de alerta . then(){... if accept
    alertaDialog(context, "Eliminar libro",
            "Quieres elimnarlo de tu biblioteca?", "No", "Si")
        .then(
      (value) {
        if (value == ConfirmAction.ACCEPT) {
          LibroDao.deleteLibro(codLibro);
          _actualizarListaLibros();
        }
      },
    );
  }

  _abrirAgregarLibroDialog() {
    agregarLibroDialog(context).then((value) {
      LibroDao.postLibro(Sesion.libroAgregado);
      print(Sesion.libroAgregado.autor);
      _actualizarListaLibros();
    });
  }

  _irAlistaTotal() {
    Navigator.of(context).pushNamed("/lista_total");
  }

  Widget testStream() {
    return StreamBuilder(
      initialData: [],
    );
  }
}

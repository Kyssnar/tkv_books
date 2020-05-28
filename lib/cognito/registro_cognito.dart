import 'package:flutter_aws_amplify_cognito/flutter_aws_amplify_cognito.dart';
import 'package:tkv_books/cognito/sesion_cognito.dart';
import 'package:tkv_books/dao/sesion.dart';
import 'package:tkv_books/dao/usuario_dao.dart';
import 'package:tkv_books/dialogs/error_dialogs.dart';
import 'package:tkv_books/dialogs/validar_codigo_dialog.dart';
import 'package:tkv_books/model/usuario.dart';

class RegistroCognito {
  static iniciar() {
    FlutterAwsAmplifyCognito.initialize().then((UserStatus status) {
      switch (status) {
        case UserStatus.GUEST:
          print(status);
          break;
        case UserStatus.SIGNED_IN:
          print(status);
          break;
        case UserStatus.SIGNED_OUT:
          print(status);
          break;
        case UserStatus.SIGNED_OUT_FEDERATED_TOKENS_INVALID:
          print(status);
          break;
        case UserStatus.SIGNED_OUT_USER_POOLS_TOKENS_INVALID:
          print(status);
          break;
        case UserStatus.UNKNOWN:
          print(status);
          break;
        case UserStatus.ERROR:
          print(status);
          break;
      }
    }).catchError((error) {
      print(error);
    });
  }

  static registrarUsuario() {
    FlutterAwsAmplifyCognito.signUp(Sesion.usuarioRegistro.nickname,
            Sesion.contraseniaUsuario, Sesion.atributosUsuarioRegistro)
        .then((SignUpResult result) {
      UsuarioDao.postUsuario(Sesion.usuarioRegistro);
      if (!result.confirmationState) {
        // Si aun no valida su codigo
        ValidarCodigoDialog(
          context: Sesion.contextActual,
        ).build();
      } else {
        SesionCognito.iniciarSesion();
      }
    }).catchError((error) {
      ErrorDialog(
        context: Sesion.contextActual,
        error: error,
      ).build();
    });
  }

  static validarCodigo() {
    FlutterAwsAmplifyCognito.confirmSignUp(
            Sesion.usuarioRegistro.nickname, Sesion.codigoValidacion)
        .then((SignUpResult result) {
      if (!result.confirmationState) {
        final UserCodeDeliveryDetails details = result.userCodeDeliveryDetails;
        print(details.destination);
      } else {
        RegistroCognito.registrarUsuario();
      }
    }).catchError((error) {
      print(error);
    });
  }

  static reenviarCodigo() {
    FlutterAwsAmplifyCognito.resendSignUp(Sesion.usuarioRegistro.nickname)
        .then((SignUpResult result) {
      print("codigo reenviado");
    }).catchError((error) {
      print(error);
    });
  }

  static cambiarContrasenia(String nickname) {
    FlutterAwsAmplifyCognito.forgotPassword(nickname)
        .then((ForgotPasswordResult result) {
      switch (result.state) {
        case ForgotPasswordState.CONFIRMATION_CODE:
          print("Confirmation code is sent to reset password");
          break;
        case ForgotPasswordState.DONE:
          // TODO: Handle this case.
          break;
        case ForgotPasswordState.UNKNOWN:
          // TODO: Handle this case.
          break;
        case ForgotPasswordState.ERROR:
          // TODO: Handle this case.
          break;
      }
    }).catchError((error) {
      print(error);
    });
  }

  static confirmarCodigoCambioContrasenia(
      String nickname, String nuevaContrasenia, String codigoConfirmacion) {
    FlutterAwsAmplifyCognito.confirmForgotPassword(
            nickname, nuevaContrasenia, codigoConfirmacion)
        .then((ForgotPasswordResult result) {
      switch (result.state) {
        case ForgotPasswordState.DONE:
          print("Password changed successfully");
          break;
        case ForgotPasswordState.UNKNOWN:
          // TODO: Handle this case.
          break;
        case ForgotPasswordState.ERROR:
          // TODO: Handle this case.
          break;
        case ForgotPasswordState.CONFIRMATION_CODE:
          // TODO: Handle this case.
          break;
      }
    }).catchError((error) {
      print(error);
    });
  }
}

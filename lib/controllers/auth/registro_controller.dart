import 'dart:io';

import 'package:ekeyless/models/usuario_model.dart';
import 'package:ekeyless/routes/app_routes.dart';
import 'package:ekeyless/services/auth/auth_service.dart';
import 'package:ekeyless/services/auth/supabase_storage_service.dart';
import 'package:ekeyless/utils/alertas.dart';
import 'package:ekeyless/utils/validator_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegistroController extends GetxController {
  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final formKeyEmail = GlobalKey<FormState>();
  final formKeyProfile = GlobalKey<FormState>();
  final formKeyPassword = GlobalKey<FormState>();

  final RxBool cargando = false.obs;
  final RxBool mostrarContrasena = false.obs;
  final RxBool mostrarConfirmacion = false.obs;
  final RxInt pasoActual = 0.obs;

  final Rxn<File> imagenPerfilFile = Rxn<File>();
  final Rxn<XFile> imagenPerfilXFile = Rxn<XFile>();
  final RxString imagenWebUrl = ''.obs;

  final Rx<PasswordStrength> fortalezaContrasena = PasswordStrength.vacia.obs;

  final RxString passwordText = ''.obs;
  final RxString confirmPasswordText = ''.obs;
  final RxBool imageSelected = false.obs;

  final AuthService _authService = AuthService();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  @override
  void onInit() {
    super.onInit();

    passwordCtrl.addListener(_evaluarFortalezaContrasena);
    passwordCtrl.addListener(_actualizarPasswordText);
    confirmPasswordCtrl.addListener(_actualizarConfirmPasswordText);
  }

  @override
  void onClose() {
    passwordCtrl.removeListener(_evaluarFortalezaContrasena);
    passwordCtrl.removeListener(_actualizarPasswordText);
    confirmPasswordCtrl.removeListener(_actualizarConfirmPasswordText);

    emailCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();

    super.onClose();
  }

  void _evaluarFortalezaContrasena() {
    fortalezaContrasena.value = ValidatorUtils.evaluarFortalezaContrasena(
      passwordCtrl.text,
    );
  }

  void _actualizarPasswordText() {
    passwordText.value = passwordCtrl.text;
  }

  void _actualizarConfirmPasswordText() {
    confirmPasswordText.value = confirmPasswordCtrl.text;
  }

  void alternarVisibilidadContrasena() =>
      mostrarContrasena.value = !mostrarContrasena.value;

  void alternarVisibilidadConfirmacion() =>
      mostrarConfirmacion.value = !mostrarConfirmacion.value;

  Future<void> verificarEmailDisponible() async {
    if (!formKeyEmail.currentState!.validate()) return;

    // No consultamos public.usuarios aquí porque el usuario
    // todavía no está autenticado.
    //
    // Supabase Auth comprobará realmente la existencia del email
    // cuando se ejecute signUp().
    pasoActual.value++;
  }

  String? validarEmail(String? valor) => ValidatorUtils.validarEmail(valor);

  String? validarUsername(String? valor) =>
      ValidatorUtils.validarUsername(valor);

  String? validarContrasena(String? valor) =>
      ValidatorUtils.validarContrasena(valor);

  String? validarConfirmacion(String? valor) =>
      ValidatorUtils.validarConfirmacionContrasena(valor, passwordCtrl.text);

  List<String> getSugerenciasContrasena() =>
      ValidatorUtils.getSugerenciasContrasena(passwordCtrl.text);

  bool validarTodosLosCampos() {
    final validaciones = ValidatorUtils.validarCamposRegistro(
      email: emailCtrl.text,
      username: usernameCtrl.text,
      password: passwordCtrl.text,
      confirmPassword: confirmPasswordCtrl.text,
    );

    return validaciones.values.every((error) => error == null);
  }

  Future<void> avanzarAContrasena() async {
    if (!formKeyProfile.currentState!.validate()) return;

    cargando.value = true;
    try {
      final disponible = await _authService.verificarNombreUsuarioDisponible(
        usernameCtrl.text.trim(),
      );
      if (disponible) {
        pasoActual.value++;
      } else {
        Alerta.mostrarError('Este nombre de usuario ya está en uso');
      }
    } catch (e) {
      Alerta.mostrarError(
        'Error al verificar el nombre de usuario: ${e.toString()}',
      );
    } finally {
      cargando.value = false;
    }
  }

  Future<void> seleccionarImagen() async {
    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (imagen != null) {
        imagenPerfilXFile.value = imagen;
        imageSelected.value = true;
        if (kIsWeb) {
          imagenWebUrl.value = imagen.path;
        } else {
          imagenPerfilFile.value = File(imagen.path);
        }
        update();
      }
    } catch (e) {
      Alerta.mostrarError('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  Future<void> tomarFoto() async {
    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (imagen != null) {
        imagenPerfilXFile.value = imagen;
        imageSelected.value = true;
        if (kIsWeb) {
          imagenWebUrl.value = imagen.path;
        } else {
          imagenPerfilFile.value = File(imagen.path);
        }
        update();
      }
    } catch (e) {
      Alerta.mostrarError('Error al tomar foto: ${e.toString()}');
    }
  }

  void eliminarImagen() {
    imagenPerfilXFile.value = null;
    imagenPerfilFile.value = null;
    imagenWebUrl.value = '';
    imageSelected.value = false;
    update();
  }

  bool hayImagenSeleccionada() => imageSelected.value;

  Future<void> registrarUsuario() async {
    if (!formKeyPassword.currentState!.validate()) return;

    if (!fortalezaContrasena.value.esValida) {
      Alerta.mostrarError('La contraseña no cumple con los requisitos mínimos');
      return;
    }

    cargando.value = true;
    try {
      const imageUrl = 'assets/default_avatar.png';

      final nuevoUsuario = UsuarioModel(
        id: '',
        imagenPerfil: imageUrl,
        nombreUsuario: usernameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        authGoogle: false,
        amigos: List.empty(),
        solicitudesEnviadas: List.empty(),
        solicitudesRecibidas: List.empty(),
      );

      await _authService.registrarUsuario(nuevoUsuario, passwordCtrl.text);

      // La subida se realiza después de crear la sesión para que Storage RLS
      // permita escribir en el bucket sin abrir uploads anónimos.
      if (hayImagenSeleccionada()) {
        try {
          final bytes =
              kIsWeb
                  ? await imagenPerfilXFile.value!.readAsBytes()
                  : await imagenPerfilFile.value!.readAsBytes();

          final imageUrl = await _storageService.subirImagen(
            bytes: bytes,
            nombreArchivo:
                '${usernameCtrl.text.trim()}_${DateTime.now().millisecondsSinceEpoch}',
            idPublico:
                'user_profile_${usernameCtrl.text.trim()}_${DateTime.now().millisecondsSinceEpoch}',
          );
          await _authService.actualizarImagenPerfil(imageUrl);
        } catch (e) {
          Alerta.mostrarAviso(
            'No se pudo subir la imagen. Se mantendrá la imagen por defecto.',
          );
        }
      }

      Alerta.mostrarExito('¡Registro completado exitosamente!');
      Get.offAllNamed(AppRoutes.candado);
    } catch (e) {
      String mensaje = 'Error durante el registro';

      if (e is AuthServiceException) {
        switch (e.code) {
          case 'weak-password':
            mensaje = 'La contraseña es muy débil';
            break;
          case 'email-already-in-use':
            mensaje = 'Este correo ya está registrado';
            break;
          case 'invalid-email':
            mensaje = 'Formato de email inválido';
            break;
          case 'operation-not-allowed':
            mensaje = 'Operación no permitida';
            break;
        }
      }

      Alerta.mostrarError(mensaje);
    } finally {
      cargando.value = false;
    }
  }

  void volverPasoAnterior() {
    if (pasoActual.value > 0) {
      pasoActual.value--;
    } else {
      Get.back();
    }
  }

  void irALogin() => Get.offNamed(AppRoutes.login);
}

import 'package:ekeyless/models/usuario_model.dart';
import 'package:get/get.dart';
import 'package:ekeyless/services/amigos/amigos_service.dart';

class AmigosController extends GetxController{

  final AmigosService _amigosService = AmigosService();

  var isLoading = false.obs;
  var currentUser = Rxn<UsuarioModel>();
  var usuarios = <UsuarioModel>[].obs;
  var usuariosBuscados = <UsuarioModel>[].obs;
  var usuariosFiltrados = <UsuarioModel>[].obs;
  var pestanaSeleccionada = 'Amigos'.obs; 

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser(); 
  }

  // Obtner usuario actual
  Future<void> loadCurrentUser() async {
    try {

      final user = await _amigosService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el usuario');
    }
  }

   Future<void> cargarUsuarios() async {
    try {
      isLoading.value = true;

      final listaUsuarios = await _amigosService.obtenerTodosLosUsuarios();
      final idActual = currentUser.value?.id;

      final filtrados = listaUsuarios.where((u) => u.id != idActual).toList();

      usuarios.assignAll(filtrados);
      filtrarUsuariosPorCategoria();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los usuarios: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<UsuarioModel> _usuariosDeCategoria() {
    final actual = currentUser.value;
    if (actual == null) return [];

    if (pestanaSeleccionada.value == 'Amigos') {
      return usuarios
          .where((u) => actual.amigos.contains(u.id))
          .toList();
    } else if (pestanaSeleccionada.value == 'Solicitudes') {
      return usuarios
          .where((u) => actual.solicitudesRecibidas.contains(u.id))
          .toList();
    } else if (pestanaSeleccionada.value == 'Agregar') {
      return usuarios
          .where((u) =>
              !actual.amigos.contains(u.id) &&
              !actual.solicitudesEnviadas.contains(u.id) &&
              !actual.solicitudesRecibidas.contains(u.id))
          .toList();
    }

    return [];
  }

  void filtrarUsuariosPorCategoria() {
    usuariosFiltrados.assignAll(_usuariosDeCategoria());
  }
  void cambiarPestana(String nueva) {
    pestanaSeleccionada.value = nueva;
    filtrarUsuariosPorCategoria();
  }

  
  /// Buscar usuarios
  Future<void> buscarUsuarios(String searchText) async {
    final actual = currentUser.value;
    if (actual == null) return;

    final query = searchText.toLowerCase();
    final baseFiltrada = _usuariosDeCategoria();

    final resultado = baseFiltrada.where((usuario) {
      return usuario.nombreUsuario.toLowerCase().contains(query);
    }).toList();

    usuariosBuscados.value = resultado;
  }


  Future<void> enviarSolicitudAmistad(String receptorId) async {
    try {
      isLoading.value = true;
      await _amigosService.enviarSolicitudAmistad(receptorId);
      
      currentUser.value = await _amigosService.getCurrentUser();
      Get.snackbar('Solicitud enviada', 'Tu solicitud fue enviada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar la solicitud: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> aceptarSolicitud(String emisorId) async {
    try {
      isLoading.value = true;
      await _amigosService.aceptarSolicitudAmistad(emisorId);
      currentUser.value = await _amigosService.getCurrentUser();
      Get.snackbar('Solicitud aceptada', 'Ahora son amigos');
      await cargarUsuarios(); 
    } catch (e) {
      Get.snackbar('Error', 'No se pudo aceptar la solicitud: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelarSolicitud(String receptorId) async {
    try {
      isLoading.value = true;
      await _amigosService.cancelarSolicitudAmistad(receptorId);
      currentUser.value = await _amigosService.getCurrentUser();
      Get.snackbar('Solicitud cancelada', 'La solicitud fue retirada');
      await cargarUsuarios(); 
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cancelar la solicitud: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

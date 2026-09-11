import 'package:ekeyless/widgets/estructura/bottom_nav_bar.dart';
import 'package:ekeyless/widgets/estructura/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/controllers/amigos/amigos_controller.dart';
import 'package:ekeyless/widgets/amigos/categorias_selector.dart';
import 'package:ekeyless/widgets/amigos/amigo_item.dart';
import 'package:ekeyless/widgets/amigos/buscar_widget.dart';

class VistaAmigos extends StatefulWidget{
  const VistaAmigos({super.key});

  @override
  State<VistaAmigos> createState() => _VistaAmigosState();

}
class _VistaAmigosState extends State<VistaAmigos> {
  String categoriaSeleccionada = 'Amigos';
  final TextEditingController _searchController = TextEditingController();
  final controller = Get.find<AmigosController>();

  final List<String> categorias = ['Amigos', 'Solicitudes', 'Agregar'];

  String _searchText = '';

   @override
  void initState() {
    super.initState();
    controller.cargarUsuarios();
    controller.cambiarPestana(categoriaSeleccionada);

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
      controller.buscarUsuarios(_searchText);
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Amigos'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          BuscarWidget(text: 'Buscar $categoriaSeleccionada', searchController: _searchController),
          const SizedBox(height: 16),
            CategoriasSelector(
              categorias: categorias,
              categoriaSeleccionada: categoriaSeleccionada,
              onCategoriaSeleccionada: (categoria) {
                setState(() {
                  categoriaSeleccionada = categoria;
                });
                controller.cambiarPestana(categoria);
              },

            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                controller.buscarUsuarios(_searchText);
                final List<dynamic> lista;
                if(_searchText.isNotEmpty){
                  lista = controller.usuariosBuscados;
                }else{
                  lista = controller.usuariosFiltrados;
                }
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (lista.isEmpty) {
                  return const Center(child: Text('No hay usuarios en esta categoría.'));
                }
                
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final usuario = lista[index];
                    
                    return AmigoItem(
                      nombreUsuario: usuario.nombreUsuario, 
                      usuarioId: usuario.id,
                      avatarUrl: usuario.imagenPerfil,
                      categoria: categoriaSeleccionada,
                      
                    );
                    
                  },
                );
              }),
            ),

          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

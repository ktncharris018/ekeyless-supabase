import 'package:flutter/material.dart';

class CategoriasSelector extends StatefulWidget {
  final List<String> categorias;
  final Function(String) onCategoriaSeleccionada;
  final String categoriaSeleccionada;

  const CategoriasSelector({
    super.key,
    required this.categorias,
    required this.onCategoriaSeleccionada,
    required this.categoriaSeleccionada,
  });

  @override
  State<CategoriasSelector> createState() => _CategoriasSelectorState();
}

class _CategoriasSelectorState extends State<CategoriasSelector> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8.0,
      children: widget.categorias.map((categoria) {
        final bool seleccionada = categoria == widget.categoriaSeleccionada;
        return GestureDetector(
          onTap: () => widget.onCategoriaSeleccionada(categoria),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: seleccionada
                  ? const Color(0xFF2BB8EE).withAlpha((0.4 * 255).toInt())
                  : const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              categoria,
              style: TextStyle(
                color: seleccionada ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

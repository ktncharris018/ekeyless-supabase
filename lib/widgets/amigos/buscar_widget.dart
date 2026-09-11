import 'package:flutter/material.dart';

class BuscarWidget extends StatelessWidget {
  final String text;
  final TextEditingController searchController;

  const BuscarWidget({super.key, required this.text, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: text,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
      ),
    );

    /*return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: Size(double.infinity, 60),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 22, color: AppColors.white)),
    );*/
  }
}

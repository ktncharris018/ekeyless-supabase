import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ekeyless/routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onTap(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.candado);
        break;
      case 1:
        Get.offNamed(AppRoutes.amigos);
        break;
      case 2:
        Get.offNamed(AppRoutes.notificaciones);
        break;
      case 3:
        Get.offNamed(AppRoutes.configuracion);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Candado'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Amigos'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notificaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}

import 'package:permission_handler/permission_handler.dart';

abstract class IPermissionService {
  Future<bool> solicitarPermisosBluetooth();
}

class PermissionService implements IPermissionService {
  static const List<Permission> _requiredPermissions = [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
    Permission.location,
    Permission.nearbyWifiDevices,
  ];

  @override
  Future<bool> solicitarPermisosBluetooth() async {
    for (final permiso in _requiredPermissions) {
      if (await permiso.isDenied || await permiso.isPermanentlyDenied) {
        final status = await permiso.request();
        if (!status.isGranted) return false;
      }
    }
    return true;
  }
}

import 'package:ekeyless/controllers/candado/editar_perfil_acceso_controller.dart';
import 'package:ekeyless/models/perfil_acceso_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VistaEditarPerfilAcceso extends StatelessWidget {
  const VistaEditarPerfilAcceso({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditarPerfilAccesoController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(controller.esEdicion ? 'Editar perfil' : 'Nuevo perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            _SeccionCard(
              titulo: 'Datos del perfil',
              icono: Icons.badge_outlined,
              children: [
                TextField(
                  controller: controller.nombreController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del perfil',
                    hintText: 'Ej. Personal de limpieza',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.cargandoAmigos.value)
                  const LinearProgressIndicator()
                else
                  DropdownButtonFormField<String>(
                    value: controller.usuarioSeleccionado.value?.id,
                    decoration: const InputDecoration(
                      labelText: 'Usuario autorizado',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: controller.amigos
                        .map(
                          (usuario) => DropdownMenuItem<String>(
                            value: usuario.id,
                            child: Text('${usuario.nombreUsuario} · ${usuario.email}'),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) {
                        controller.usuarioSeleccionado.value = null;
                        return;
                      }
                      controller.usuarioSeleccionado.value = controller.amigos.firstWhere((u) => u.id == id);
                    },
                    hint: const Text('Selecciona un amigo'),
                  ),
                if (controller.amigos.isEmpty && !controller.cargandoAmigos.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'No tienes amigos disponibles para asignar este perfil.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.dispositivoController,
                  decoration: const InputDecoration(
                    labelText: 'Dispositivo (opcional)',
                    hintText: 'ID/Remote ID del dispositivo BLE',
                    prefixIcon: Icon(Icons.bluetooth_connected),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Tipo de acceso',
              icono: Icons.security_outlined,
              children: [
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TipoAccesoPerfil.values
                        .map(
                          (tipo) => ChoiceChip(
                            label: Text(tipo.label),
                            selected: controller.tipoAcceso.value == tipo,
                            onSelected: (_) => controller.cambiarTipo(tipo),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Vigencia y reglas',
              icono: Icons.schedule_outlined,
              children: [
                Obx(() {
                  final tipo = controller.tipoAcceso.value;
                  return Column(
                    children: [
                      _DateButton(
                        label: 'Inicio',
                        date: controller.fechaInicio.value,
                        onTap: () => _seleccionarFecha(
                          context,
                          controller.fechaInicio.value,
                          controller.seleccionarFechaInicio,
                        ),
                      ),
                      if (tipo != TipoAccesoPerfil.permanente) ...[
                        const SizedBox(height: 10),
                        _DateButton(
                          label: 'Fin',
                          date: controller.fechaFin.value,
                          onTap: () => _seleccionarFechaFin(context, controller),
                        ),
                      ],
                      if (tipo == TipoAccesoPerfil.recurrente) ...[
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Días permitidos',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                            return FilterChip(
                              label: Text(labels[index]),
                              selected: controller.diasPermitidos.contains(day),
                              onSelected: (_) => controller.alternarDia(day),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _TimeButton(
                                label: 'Hora inicio',
                                value: controller.horaInicio,
                                onTap: () => _seleccionarHora(
                                  context,
                                  controller.horaInicio,
                                  controller.seleccionarHoraInicio,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TimeButton(
                                label: 'Hora fin',
                                value: controller.horaFin,
                                onTap: () => _seleccionarHora(
                                  context,
                                  controller.horaFin,
                                  controller.seleccionarHoraFin,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionCard(
              titulo: 'Mecanismo de comunicación',
              icono: Icons.settings_input_antenna,
              children: [
                Obx(
                  () => Column(
                    children: [
                      RadioListTile<CanalComunicacion>(
                        value: CanalComunicacion.bluetooth,
                        groupValue: controller.canalComunicacion.value,
                        onChanged: (value) {
                          if (value != null) controller.canalComunicacion.value = value;
                        },
                        title: const Text('Bluetooth'),
                        subtitle: const Text('Implementado y disponible en eKeyLess.'),
                      ),
                      RadioListTile<CanalComunicacion>(
                        value: CanalComunicacion.nfc,
                        groupValue: controller.canalComunicacion.value,
                        onChanged: (value) {
                          if (value != null) controller.canalComunicacion.value = value;
                        },
                        title: const Text('NFC'),
                        subtitle: const Text('Extensión arquitectónica propuesta; aún no implementada.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: controller.cargando.value ? null : controller.guardar,
                icon: controller.cargando.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(controller.cargando.value ? 'Guardando...' : 'Guardar perfil'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    DateTime actual,
    void Function(DateTime) onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _seleccionarFechaFin(
    BuildContext context,
    EditarPerfilAccesoController controller,
  ) async {
    final initial = controller.fechaFin.value ?? controller.fechaInicio.value.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: controller.fechaInicio.value,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) controller.seleccionarFechaFin(picked);
  }

  Future<void> _seleccionarHora(
    BuildContext context,
    TimeOfDay? actual,
    void Function(TimeOfDay) onSelected,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: actual ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) onSelected(picked);
  }
}

class _SeccionCard extends StatelessWidget {
  const _SeccionCard({required this.titulo, required this.icono, required this.children});

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 20),
                const SizedBox(width: 8),
                Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy').format(date!),
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.label, required this.value, required this.onTap});

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(value?.format(context) ?? 'Seleccionar'),
      ),
    );
  }
}

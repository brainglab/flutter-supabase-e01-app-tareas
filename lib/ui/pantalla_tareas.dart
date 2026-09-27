import 'package:flutter/material.dart';

import '../datos/repositorio_tareas.dart';
import '../datos/tarea.dart';
import '../diseno/componentes.dart';
import '../diseno/marca.dart';
import 'fila_tarea.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key});

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  final _repositorio = RepositorioTareas();
  final _campo = TextEditingController();
  final _foco = FocusNode();

  // Una sola vez: si lo creas en build(),
  // cada redibujado abre una suscripción nueva.
  late final Stream<List<Tarea>> _tareas = _repositorio
      .observar();

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final titulo = _campo.text.trim();
    if (titulo.isEmpty) return;
    _campo.clear();
    _foco.requestFocus(); // listo para la siguiente
    await _repositorio.crear(titulo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            children: [
              const Encabezado(
                titulo: 'Mis tareas',
                subtitulo: 'Flutter + Supabase · Brainglab',
              ),
              const SizedBox(height: Marca.e5),
              _nuevaTarea(),
              const SizedBox(height: Marca.e5),
              Expanded(child: _lista()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nuevaTarea() {
    return Tarjeta(
      padding: const EdgeInsets.all(Marca.e3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _campo,
              focusNode: _foco,
              decoration: const InputDecoration(
                hintText: 'Nueva tarea',
              ),
              onSubmitted: (_) => _crear(),
            ),
          ),
          const SizedBox(width: Marca.e3),
          FilledButton.icon(
            onPressed: _crear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Tarea>>(
      stream: _tareas,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _Error(snapshot.error);
        if (!snapshot.hasData) return const _Cargando();
        if (snapshot.data!.isEmpty) return const _SinTareas();
        return ListView(
          children: [
            _Resumen(tareas: snapshot.data!),
            for (final tarea in snapshot.data!)
              FilaTarea(
                tarea: tarea,
                onChanged: (_) => _repositorio.alternar(tarea),
              ),
          ],
        );
      },
    );
  }
}

/// Cabecera de la lista: cuántas tareas quedan pendientes.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.tareas});

  final List<Tarea> tareas;

  @override
  Widget build(BuildContext context) {
    final pendientes = tareas
        .where((t) => !t.completada)
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: Marca.e3),
      child: Row(
        children: [
          Text(
            'TAREAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Marca.al(Marca.secundario, .6),
            ),
          ),
          const Spacer(),
          Insignia(
            pendientes == 1
                ? '1 pendiente'
                : '$pendientes pendientes',
            icono: Icons.bolt_rounded,
          ),
        ],
      ),
    );
  }
}

class _SinTareas extends StatelessWidget {
  const _SinTareas();

  @override
  Widget build(BuildContext context) {
    return const EstadoVacio(
      icono: Icons.task_alt_rounded,
      titulo: 'Sin tareas todavía',
      texto: 'Escribe la primera y pulsa Agregar.',
    );
  }
}

/// Mientras llega la primera lista.
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Si el stream informa un error.
class _Error extends StatelessWidget {
  const _Error(this.error);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return EstadoVacio(
      icono: Icons.cloud_off_rounded,
      titulo: 'No se pudieron cargar las tareas',
      texto: '$error',
    );
  }
}

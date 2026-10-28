// Presentación: único dueño del estado compartido de las tres pestañas.
// Solo conoce el contrato del repositorio y las reglas del dominio.

import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  // Recibido por constructor: no sabe si es memoria, disco o nube.
  final ConsumoRepository _repositorio;

  // Estado compartido.
  List<Consumo> consumos = [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // Estado derivado: se calcula cada vez, nunca se guarda.
  double get total => consumos.fold(0.0, (suma, c) => suma + c.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  // Trae lo que ya tenía la fuente de verdad.
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  // Valida con el dominio, guarda y vuelve a leer. true si se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final litros = double.tryParse(litrosTexto.trim().replaceAll(',', '.'));
    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    // finally: si la fuente falla, el botón no se queda desactivado.
    try {
      await _repositorio.guardar(
        Consumo(laboratorio: laboratorio, litros: litros!),
      );
      consumos = await _repositorio.todos();
    } finally {
      guardando = false;
      notifyListeners();
    }
    return true;
  }

  // El mínimo lo decide ajustarMeta, no el ViewModel.
  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}

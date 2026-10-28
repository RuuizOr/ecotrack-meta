// Datos: implementación del contrato con una lista en memoria.

import '../dominio/consumo.dart';
import 'consumo_repository.dart';

class MemoriaConsumoRepository implements ConsumoRepository {
  // Fuente de verdad: solo esta clase la puede modificar.
  final List<Consumo> _consumos = [];

  // Es async aunque responda al instante: una fuente real tardaría.
  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  // Copia no modificable: quien la reciba no puede tocar la lista interna.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}

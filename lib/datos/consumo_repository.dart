// Datos: contrato de la fuente de consumos. Habla como el dominio,
// no dice si detrás hay una lista, un archivo o un servidor.

import '../dominio/consumo.dart';

abstract class ConsumoRepository {
  // Guarda un consumo en la fuente de verdad.
  Future<void> guardar(Consumo consumo);

  // Regresa todos los consumos guardados, en el orden en que llegaron.
  Future<List<Consumo>> todos();
}

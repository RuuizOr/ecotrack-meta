// Arranque de la variante B. Junto con main_change_notifier.dart, es el
// único lugar que elige la fuente de datos.

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/b_provider.dart';

void main() {
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}

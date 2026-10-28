// Dominio: entidad Consumo y regla de litros. Dart puro, sin Flutter.

// Laboratorios disponibles. Es un dato fijo, no estado: nunca cambia.
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

// Tope de litros que se acepta en un solo registro.
const topeLitros = 10000;

// Un registro de consumo de agua de un laboratorio.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

// Regresa el mensaje de error, o null si los litros son válidos.
// El orden importa: primero que sea número, luego positivo, luego el tope.
String? validarLitros(double? litros) {
  if (litros == null) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > topeLitros) return 'Los litros superan el tope de 10000';
  return null;
}

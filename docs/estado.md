# Gestión de estado — EcoTrack Meta

**Equipo:** Ventura Gil Astrid Valeria · Ruiz Santos Orlando
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa al marco de navegación y se cambia con `setState`. | Campo `_pestana` de `_PantallasEcoTrackState` en `lib/presentacion/vistas.dart`. |
| Texto del campo de litros | Efímero: es del formulario mientras se escribe; el ViewModel solo lo recibe al tocar Guardar. | `TextEditingController _litros` de `_FormularioRegistroState` en `lib/presentacion/vistas.dart`, liberado en su `dispose()`. |
| consumos y meta | Compartido: Registro, Historial y Meta leen el mismo dato y avisan con `notifyListeners()`. | Campos `consumos` y `meta` de `ConsumosViewModel` en `lib/presentacion/consumos_view_model.dart`. |
| total y metaSuperada | Derivado: se calculan desde `consumos` y `meta` cada vez que se piden, nunca se guardan. | Getters `total`, `avance` y `metaSuperada` de `ConsumosViewModel`; lo comprueba la prueba "total, avance y metaSuperada se derivan de consumos y meta" (`test/etapa3_viewmodel_test.dart`) y el punto 3 de `verificar_estado.sh`. |
| Lo que regresa todos() | Persistido: es la fuente de verdad; el ViewModel solo guarda la copia que recibe. | Lista privada `_consumos` de `MemoriaConsumoRepository` (`lib/datos/memoria_consumo_repository.dart`), entregada como `List.unmodifiable`; lo prueba "todos() no deja modificar la lista interna" (`test/etapa2_datos_test.dart`). |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Un solo `ConsumosViewModel` creado en `_AppChangeNotifierState` llega a las tres pestañas; lo prueba "Dato compartido: Registro guarda, Historial y Meta lo ven" en `test/etapa4_change_notifier_test.dart`. | El mismo `ConsumosViewModel` vive en `ChangeNotifierProvider` y las tres pestañas lo leen con `context.watch`; misma prueba en `test/etapa5_provider_test.dart`. |
| Capas | `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`; el error de `validarLitros` llega al campo sin guardar nada (prueba "Capas: el error del dominio aparece…" de la etapa 4, puntos 2–4 del script). | Idénticas: `b_provider.dart` reusa las mismas vistas y el mismo ViewModel sin tocarlos; prueba "Capas…" de la etapa 5 y punto 6 del script ("reusa ConsumosViewModel"). |
| Encaje con el diagrama | Encaja: vista tonta → adaptador `*CN` con `ListenableBuilder` → `ConsumosViewModel` → `ConsumoRepository`; el puente entre vista y ViewModel lo escribimos a mano. | Encaja igual, pero el puente lo da el paquete: vista tonta → adaptador `*Provider` con `watch`/`read` → mismo ViewModel → mismo contrato. |
| Constructores que reciben vm | 3: `RegistroCN`, `HistorialCN` y `MetaCN` (`required this.vm` en `lib/variantes/a_change_notifier.dart`); una subpantalla de Meta sumaría otro. | 0: los adaptadores son `const RegistroProvider()`, `HistorialProvider()` y `MetaProvider()`; lo prueba "Los adaptadores piden el ViewModel al árbol, no al constructor". |
| Quién libera el ViewModel | Nosotros: `_AppChangeNotifierState.dispose()` llama `_vm.dispose()`, porque es quien lo creó (punto 5 del script). | `ChangeNotifierProvider` lo libera solo al desmontarse; en `b_provider.dart` no escribimos ningún `dispose()`. |
| Costo de adoptarla ahora | Cero dependencias, pero cada pantalla nueva obliga a pasar `vm` a mano por constructores y envolverla en `ListenableBuilder`. | Una dependencia (`provider` en `pubspec.yaml`) y aprender la regla watch para mostrar, read para actuar (punto 7 del script); a cambio, pantallas nuevas sin cablear constructores. |
| Sustitución de la fuente de datos | `AppChangeNotifier(repositorio: RepositorioEspia(...))` funciona sin tocar pantallas; prueba "Sustitución…" de la etapa 4. | `AppProvider(repositorio: RepositorioEspia(...))` funciona igual; prueba "Sustitución…" de la etapa 5. En las dos solo `main*.dart` conoce `MemoriaConsumoRepository` (punto 8 del script). |

## Elección

Elegimos: **B · provider**, porque comparte el mismo `ConsumosViewModel` sin pasar `vm` por ningún constructor (0 contra 3) y el paquete se encarga de liberarlo, mientras que las 35 pruebas pasan igual en las dos variantes.

Se mantiene esta pieza del diagrama: **`ConsumosViewModel`** (`lib/presentacion/consumos_view_model.dart`) junto con las vistas tontas de `vistas.dart`; no cambió ni una línea entre el commit de la variante A y el de la variante B.

Esta pieza es la que podría sustituirse después: **la fuente de datos**, `MemoriaConsumoRepository`, por otra implementación de `ConsumoRepository` (disco o nube), cambiando solo `lib/main.dart`, como ya lo demuestra `RepositorioEspia` en `test/soporte/repositorio_espia.dart`.

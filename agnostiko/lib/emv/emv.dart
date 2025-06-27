/// Manejo de Kernel EMV (carga de parámetros y flujo financiero).
///
/// Al utilizar este módulo, se debe recurrir primero a la instancia única de
/// la clase [EmvModule] para realizar la inicialización del kernel EMV y la
/// carga de parámetros.
///
/// Posteriormente, se puede iniciar la transacción EMV con el método
/// [startEmvTransaction] el cual retorna un stream para poder recibir los
/// eventos del kernel.
///
/// Para más información, consulte la documentación de cada posible evento:
/// - [EmvCandidateListEvent]
/// - [EmvAppSelectedEvent]
/// - [EmvPinRequestedEvent]
/// - [EmvPinpadEntryEvent]
/// - [EmvOnlineRequestedEvent]
/// - [EmvFinishedEvent]
library emv;

import 'package:agnostiko/agnostiko.dart';

export 'src/capk.dart';
export 'src/emv_app.dart';
export 'src/emv_candidate_app.dart';
export 'src/emv_event.dart';
export 'src/emv_config_bitmap.dart';
export 'src/emv_module.dart';
export 'src/emv_transaction.dart';
export 'src/terminal_parameters.dart';

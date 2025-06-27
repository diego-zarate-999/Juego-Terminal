# 1.12.00
* Refactorizar AsymmetricKey y SymmetricKey para tener clase padre en común.
* Realizar cambio en flujo para tests de criptografía DES/AES.
* Implementar carga de TR31 en Linux.
* Realizar ajustes en encrypt\decrypt de Linux y Pinpad.
* Arreglar flujo de tests de PIN Online para Pinpad.
* Nivelar varias funcionalidades de encrypt\decrypt en Newpos.

# 1.11.00
* Implementar en módulo seguro Newland para llave aleatoria encriptada con RSA.
* Implementar flujo de prueba de carga de llave de PIN para Banorte.
* Quitar aumento automático de KSN tras ingreso de PIN Online con llave DUKPT.
* Agregar parámetro para determinar longitud de llave a derivar bajo AES DUKPT.
* Cambiar test de ticket extra largo para tener más sentido.
* Realizar mejoras a tests de AES para ser dinámicos.
* Arreglar bug con carga de TR31 en algunos modelos Newland.
* Arreglar funcionalidad de shutdown del dispositivo en N950 y otros modelos.
* Implementar utilidad para encodeo de bloque TR31 con llaves AES DUKPT.
* Ajustar PAX para pasar pruebas de criptografía AES.
* Ajustar algunas llaves criptográficas para pasar pruebas AES en PAX.
* Cambiar módulo de CapX para depender menos de criptografía legacy.
* Marcar múltiples funcionalidades criptográficas como deprecadas.
* Arreglar generación de documentación del SDK a la hora de publicar release.
* Refactorizar pruebas EMV y UL para separarlas de pantalla de flujo financiero.

# 1.10.00
* Agregar primeras implementaciones de PIN Online AES-128.
* Agregar pruebas en demo de PIN Online AES-128.
* Ajustar cargas de llave bajo TR31.
* Refactorizar pantalla de home de demo.
* Mejorar flujos de pantallas de prueba de PIN.
* Ajustar método de encriptado de data con AES.

# 1.9.00
* Crear métodos para carga y gestión de llaves de PIN Online (experimental).
* Implementar manejo de PIN Online 3DES en POS y Pinpad.
* Agregar pantallas de pruebas de PIN Online 3DES en POS.
* Parametrizar e incluir PIN Online 3DES en flujo financiero demo.
* Crear métodos para carga y gestión de llaves de datos (experimental).
* Crear nuevos métodos para encriptado/desencriptado de datos (experimental).
* Agregar pantallas de prueba de encriptado/desencriptado con nuevos métodos.
* Mapear funcionalidad de puerto serial en implementación 'newland_nsdk'.
* Marcar funcionalidad de puerto serial como experimental.
* Agregar parámetro para setear ancho de papel personalizable al imprimir.
* Cambiar prueba básica de impresión para considerar ancho de papel custom.
* Agregar método para hacer 'ping' al pinpad y probar la conexión.
* Agregar test de ping al pinpad.
* Mapear código de error en módulo 'Pinpad' para cuando se desconecta.
* Crear nueva pantalla mejorada de pruebas de módulo 'Device'.
* Realizar ajustes de navegación con teclado en ME60.
* Nivelar solicitudes de token V2 en todas las implementaciones.
* Agregar método para carga mediante TR31 (experimental).
* Centralizar repositorio de llaves en app demo.
* Agregar en demo utilidades criptográficas para bloques de PIN Online.
* Agregar en demo utilidades criptográficas para llaves derivadas DUKPT.

# 1.8.04
* Arreglar bug de bloqueo de interfaz al pasar tarjeta RF muy rápidamente.
* Arreglar bug con falta de mapeo de evento al cancelar el lector de tarjetas.

# 1.8.03
* Parchear cierres de transacción con tarjetas que solicitan PIN Online.
* Cambiar AIDs Visa en demo para desactivar PIN Online en Contactless.
* Actualizar script build_nld.bat para agnostiko_scripts 2.0

# 1.8.02
* Agregar parche para distinguir tamaño de papel por modelo en kioskos Telpo.

# 1.8.01
* Realizar parche de seguridad en Manifest de implementaciones Android.
* Actualizar NAPI para estabilidad en Linux.

# 1.8.00
* Arreglar bug con proceso de cancelación EMV en Newland Linux.
* Habilitar datos móviles en embedder de Newland Linux.

# 1.7.7
* Mejorar seguridad con manejo de permisos Android en PAX y Newland.

# 1.7.6
* Arreglar bugs con cancelación de procesos EMV y de ingreso de PIN en Linux.

# 1.7.4
* Arreglar bug con valores incorrectos de tags 9A y 9F21 para Newland Pinpad.

# 1.7.3
* Arreglar bug con detección de tarjetas en Newland Linux.
* Solucionar a nivel aplicativo foco de teclado físico en P300.
* Agregar conexiones a través de agnostiko_module.

# 1.7.2
* Desarrollar algoritmo para conversión de imagen en formato RGBA a RGB de 16 bits (true color). 

# 1.7.1
* Implementar carga en claro con llave de fábrica para Newland.
* Implementar ingreso de PIN para P300.
* Actualizar app demo a Material 3.
* Desarrollar método experimental para display de imagenes a color en Pinpad.
* Modificar estructura y manejo del CHANGELOG.

# 1.7.0
* Implementar scanner para Newland N750.
* Desarrollar método para el display de imágenes monocromáticas en Pinpad.
* Agregar caracteres especiales a keypad de embedder Linux (ME60).
* Ajustar test de info de dispositivo para funcionar con Pinpad.
* Ajustar test de descarga e instalación de NLD en Linux.

# 1.6.0
* Actualizar funcionamiento criptográfico para implementación Pinpad.
* Agregar uso de PAN enmascarado en pantalla.
* Actualizar a flutter 3.16.

# 1.5.0
* Mapear plugin shared_preferences en embedder Linux.
* Actualizar archivos de gradle para mayor compatibilidad con otros plugins.
* Modularizar scripts internos de compilación Linux.

# 1.4.1
* Ajustar impresión de ticket en kioskos.
* Arreglar impresión de feed en N950.
* Actualizar iconos de app demo.
* Agregar auto-init de WiFi y Ethernet en embedder Linux.
* Agregar configuración alternativa para tests con UL.
* Realizar justes menores en manejo de errores.
* Ajustar inicialización EMV de Pinpad para ocurrir solo al iniciar app.
* Arreglar bug con transacciones contactless seguidas en Linux.
* Arreglar bug con impresiones cortas.
* Actualizar método de obtención de token para mejor manejo de errores.
* Cambiar app demo para utilizar 2 URL a la hora de solicitar token.

# 1.4.0
* Desarrollar módulo Pinpad para control de pantalla de esta implementación.
* Desarrollar nuevos métodos del módulo CardReader para la implementación Pinpad.
* Desarrollar nuevos métodos del módulo Device para la implementación Pinpad.
* Desarrollar test de control de pantalla para Pinpad en la app demo.
* Actualizar aar de Newland para implementación Pinpad y manejo de múltiples Aids.
* Diseñar esquema de pruebas Emv con herramienta UL.
* Desarrollar flujo de pantallas para pruebas con UL dentro de la app demo.
* Adaptar mensajería ISO dentro del SDK para tipo de datos 'Z'.
* Desarrollar primer bosquejo para manejo de Bluetooth en implementación Pinpad para mPOS.

## 1.3.0
* Crear primera estructura para implementación Pinpad en SDK.
* Desarrollar manejo de conexión con módulo external de Newland.
* Desarrollar métodos iniciales del módulo Device para implementación Pinpad.
* Desarrollar métodos básicos del módulo CardReader para implementación Pinpad.
* Desarrollar métodos básicos del módulo Crypto para implementación Pinpad.
* Desarrollar métodos generales de EmvModule y EmvTransaction para implementación Pinpad.
* Desarrollar manejo de Pin para implementación Pinpad.
* Desarrollar métodos generales del módulo Printer para implementación Pinpad.
* Desarrollar nuevos flujos dentro de la app demo, asociados a la implementacióbn Pinpad.
* Implementar teclado virtual para ingreso de PIN en U1000.

## 1.2.0
* Desarrollar módulo MDB para Linux.
* Habilitar temporalmente versión 1 de token en el SDK.
* Ajustar método para descarga de app en Linux.

## 1.1.2
* Agregar nuevos casos contactless para test EMV.
* Ajustar métodos para envío de comandos IC, en módulo para conexión con proyecto nativo.
* Implementar nuevos métodos para solicitud de token versión 2.
* Ajustar detalles para correcto funcionamiento en Linux.
* Ajustar método para la obtención de booleano asociado al módulo Printer.

## 1.1.1
* Arreglar canal de comunicación con chip Contacto en PAX.
* Implementar canal de comunicación con chip Contacto en Linux.
* Actualizar versión de token.

## 1.1.0
* Implementar actualización de firmware de equipos Newland en modo productivo (sin probar).
* Limitar manejo de imágenes renderizadas para impresión.
* Agregar tag para manejo de APDU contactless en Newland.
* Desarrollar primer bosquejo de módulo MIFARE con comandos básicos.
* Implementar módulo Flutter para invocación de flujo de app Prosa en debug.
* Implementar método para obtener intensidad de señal móvil en dBm.
* Implementar canal de comunicación con chip Contacto en Android (IC/SAM).

## 1.0.0
Versión robusta del SDK, verificada mediante la utilización de matriz de pruebas para Newland NSDK
y PAX.

* Llenar set de pruebas EMV con nuevos casos para interaccion ICC.
* Implementar mejoras asociadas a la longitud de tickets para el módulo Printer.
* Desarrollar pruebas funcionales para tickets de gran longitud en la app demo.
* Modificar llave de KEK cargada para pruebas y transacciones.
* Agregar valor asociado a moneda en los terminal parameters.
* Actualizar Flutter 3.10.


## 0.29.1
* Nivelar ajuste de impresión en Linux.
* Implementar envío de APDU mediante Contactless en Linux.

## 0.29.0
* Incorporar manejo de feed a discreción, para impresión de tickets.
* Ajustar seteo de gray para módulo Printer e incoporar test a la app demo.
* Ajustar flujo contactless para lectura de tarjetas AMEX en Newland NSDK.
* Implementar lectura de tarjetas AMEX para kernel de PAX en contactless.
* Incorporar nuevos sets de pruebas para test de EMV y optimizar flujo en la app demo.
* Optimizar manejo del kernel type dentro del SDK.

## 0.28.4
* Desarrollar modo debug, funciones y flujo inicial para test de logs EMV.
* Desarrollar primer bosquejo de pantallas en la app demo para pruebas de EMV.
* Desarrollar test para seteo de gray en pruebas de módulo de impresión.
* Ajustar feed de impresión y agregarlo como parámetro opcional.
* Actualizar dependencias para implementación PAX.
* Realizar ajustes internos en flujo EMV de Newpos.

## 0.28.3
* Desarrollar estructura general para manejo de errores en Agnostiko.
* Incorporar posibilidad de uso de KCV para la carga de llaves.
* Implementar manejo de errores de módulo Crypto en Linux y Android PAX, Newpos y Newland NSDK.
* Desarrollar módulo Scanner para conexión con proyecto nativo.
* Agregar método de envío de comandos RF para conexión con proyecto nativo.
* Nivelar códigos de error EMV en implementaciones faltantes.

## 0.28.2
* Actualizar a NSDK 2.3.2 y EMVL3 4.3.7.
* Ajustar manejo de permisos bluetooth para últimas versiones de Android.
* Implementar métodos para obtener marca y modelo en móviles Android (generic).

## 0.28.1
* Implementar método para envío de comandos RF e interacción con tarjetas en el SDK.
* Desarrollar test inicial en app demo, para pruebas asociadas a MIFARE.

## 0.28.0
* Desarollar módulo de scanner y métodos para escaneo laser de código de barras.
* Desarrollar implementación PAX para scanner de hardware.
* Desarrollar pantallas para test de scanner.
* Agregar validación de disponibilidad de scanner de hardware para las distintas marcas.
* Desarrollar primer bosquejo, con método privado, para envió de comandos RF a tarjetas.
* Realizar primeras pruebas para interacción con tarjetas MIFARE en Newpos, PAX y Newland NSDK.
* Desarrollar métodos para incorporación de múltiples columnas a ticket.
* Desarrollar métodos y pantallas para previsualización de ticket a imprimir.
* Optimizar detección de tarjeta contacto para marca Newpos.
* Agregar método experimental para seteo de tags en kernel.
* Agregar nuevos códigos de error para flujo EMV.
* Implementar nuevos códigos de error en PAX, Newpos y Newland NSDK.

## 0.27.2
* Actualizar Flutter a 3.7.
* Ajustar credenciales de Pharos.

## 0.27.1
* Desarrollar métodos para manejo de TLV en Dart.
* Desarrollar pruebas unitarias para métodos de TLvPackage.
* Desarrollar métodos para menaejo de TLV en Kotlin.


## 0.27.0
* Desarrollar método para inyección de KEK de prueba.
* Modificar test de encriptado de la app demo, para selección de opción con o sin KEK.
* Optimizar scripts de uso interno asociados a proyecto nativo.
* Agregar método para inyección de KEK de prueba en interfaz AAR.

## 0.26.0
* Modificar URLs de la app demo por migración del servidor.
* Optimizar pantallas y manejo de teclado numérico para dispositivos Linux.
* Actualizar proceso de compilación para Flutter 3.3.
* Eliminar dependencia deprecada de jcenter del proyecto.

## 0.25.2
* Habilitar uso de KEK en módulo nativo.
* Implementar validación de token vencido de forma local para POS y mPOS.
* Mejorar aplicación para configuración WiFi en terminales Linux.
* Modificar mensajería de ISO a módulo nativo con uso de HashMap.

## 0.25.1
* Agregar parche para tener llave KEK fija en PAX y Newland MESDK.
* Deshabilitar validaciones harcodeadas de terminales Newland y PAX.
* Arreglar Manifest para habilitar terminal de PAX 'A920'.

## 0.25.0
* Habilitar carga de IPEK encriptada con KEK en implementaciones Newland y PAX.
* Agregar flujo de carga y validación de token con mPOS.
* Agregar validaciones y optimizar flujo de tokens para POS.
* Mejorar utilidad para conexión WiFi en Linux.

## 0.24.2
* Realizar ajustes internos en flujo de token.

## 0.24.1
* Arreglar bug con certificado duplicado.

## 0.24.0
* Mejorar ofuscamiento de código de seguridad en AAR generado.
* Refactorizar proceso interno de inicialización para optimizar para token.
* Implementar validación y flujo de token en Linux.
* Implementar validación interna de token en mPOS (falta flujo de app demo).
* Desarrollar flujo de 'Splash Screen' para inicialización de la app demo.
* Agregar interacción para inicialización de la librería.
* Agregar interacción asociada a inicialización de tokens.
* Actualizar certificado de servidor Heroku.

## 0.23.2
* Realizar cambios internos para validación de token.
* Agregar validación de seguridad en implementación Newland NSDK.
* Agregar control de beep y LEDs al módulo device en interfaz AAR.
* Agregar borrado de llave individual y obtención de KSN en interfaz AAR.

## 0.23.1
* Agregar validación de seguridad en implementación PAX.
* Agregar parámetro de token para autorizar inicialización.

## 0.23.0
* Agregar nuevas funciones para obtener data sensitiva encriptada.
* Implementar uso de beeper en terminales y agregar prueba de funcionamiento.
* Implementar control y prueba de LEDs indicadores del terminal.
* Agregar método para borrado individual de llaves DUKPT.
* Agregar método para obtener KSN manualmente a partir del índice de llave.
* Habilitar método para esperar retiro de tarjeta IC.
* Completar módulo AAR para nuevas funcionalidades de data sensitiva.

## 0.22.1
* Agregar métodos para obtener tracks de banda magnética encriptados.
* Ajustar flujo interno de mensajería con encriptado de banda.
* Ajustar módulo crypto para conexión con proyecto nativo.

## 0.22.0
* Agregar método para obtener tags EMV encriptados desde el MPOS.
* Mejorar métodos de capítulo X para funcionamiento seguro con MPOS.
* Refactorizar módulos internos para manejo más seguro de data sensitiva.
* Agregar módulo asociado al MPOS Controller para interfaz AAR.


## 0.21.1
* Arreglar módulo Crypto de Newpos con encriptado CBC.
* Arreglar incremento de KSN en módulo Crypto de MPOS.
* Ajustar flujo de transacción Refund en Newpos.
* Realizar ajustes internos en módulo para AAR.

## 0.21.0
* Completar flujo EMV en MPOS ME30SU con ingreso de PIN Offline.
* Mostrar lista de dispositivos bluetooth emparejados en demo.
* Desarrollar flujo de conexión de MPOS en demo.
* Habilitar interfaz para control programático de canal MPOS.
* Agregar flag para diferenciar tipo de dispositivo (POS, MPOS, Móvil, etc).
* Optimizar carga de parámetros EMV para MPOS.
* Actualizar README y convertir en QRG del SDK.
* Crear canal para control remoto de MPOS(set de hora, display de texto, etc).
* Completar flujo para reembolso.
* Desarollar flujo y llamados para reverso.
* Refactorizar y mejorar pantalla principal de la app demo.
* Desarrollar pantallas y mejorar aspectos visuales de los nuevos flujos.
* Ajustar módulos asociados a Card reader y EMV para conexión con proyecto AAR.


## 0.20.1
* Actualizar a Flutter 3.0.
* Habilitar ingreso manual de MAC de MPOS a conectar.
* Implementar primera versión de módulo Crypto en MPOS.
* Mejorar compilación de app para Linux y documentar.
* Mejorar scripts para compilación y release de librería.

## 0.20.0
* Completar menú de emparejamiento y conexión del MPOS ME30SU.
* Refactorizar mensajería interna de módulo EMV y transacción.
* Implementar carga de parámetros EMV en MPOS.
* Optimizar codecs nativos de implementación Linux para MPOS.
* Agregar prueba de transacción EMV en MPOS (aún por completar).

## 0.19.0
* Desarrollar mensajería de venta e inicialización de llaves con host Pharos.
* Optimizar funcionamiento interno de módulo 'CardReader'.
* Implementar módulos 'Device' y 'CardReader' en MPOS ME30SU.
* Crear primera pantalla básica para emparejado y conexión de MPOS ME30SU.

## 0.18.0
* Actualizar a Flutter 2.10.4.
* Actualizar logo y etiquetas de app demo.
* Renombrar proyecto para reflejar nombre de marca 'Agnostiko'.
* Implementar funcionalidades básicas de módulo Bluetooth.
* Desarrollar codec Agnostiko para intercambio de Platform Channel.
* Agregar prueba de Platform Channel híbrido mediante socket Bluetooth.
* Implementar módulo básico de MPOS Agnostiko.
* Agregar scripts para desarrollo Linux.
* Arreglar bugs en módulo de encriptado y pruebas de integración.

## 0.17.0
* Actualizar a Flutter 2.10.3.
* Arreglar bug con fileprovider bajo NSDK.
* Optimizar métodos existentes de info del dispositivo.
* Agregar métodos adicionales de info del dispositivo.
* Implementar nuevo método para actualización de firmware en PAX y Newpos.
* Implementar primera versión de módulo para puerto MDB en Android y Linux.
* Agregar estructuras para futuro flujo MDB Nivel 1.
* Ajustar funcionalidades de impresora Sunmi para acercar más al flujo Agnostiko.

## 0.16.0
* Actualizar a Flutter 2.10.1.
* Refactorizar embedder para ajustarse más al proceso del Flutter Engine.
* Agregar nuevos métodos de módulo 'device' para el TMS.
* Implementar transacción EMV Contactless y Contacto para Sunmi.
* Implementar ingreso de PIN Sunmi.
* Implementar módulo de criptografía Sunmi.
* Arreglar instalación/desinstalación de app bajo NSDK.

## 0.15.4
* Arreglar crash tras cancelación de PIN y reintento con NSDK.
* Implementar primera versión de impresión bajo SDK Sunmi.
* Actualización interna de Gradle y plugins de compilación Android.


## 0.15.3
* Implementar inicialización de SDK para marca Sunmi.
* Implementar detección de tarjetas en marca Sunmi.
* Arreglar crash por ofuscamiento de actividad para ingreso de PIN NSDK.
* Agregar callback previo a cierre de app (para liberar recursos de SDK).
* Ajuste interno de dependencia para compilación en Release.

## 0.15.2
* Completar implementación de varios módulos para NSDK.

## 0.15.1
* Agregar opción de selección manual de tarjetas a detectar en app demo.
* Agregar opción de reinicio manual en app demo.
* Parchear funcionamiento de MESDK Newland para Android 7 y 10.
* Reorganizar opciones de configuración en app demo.

## 0.15.0
* Implementar contraseña para opciones sensitivas del terminal.
* Habilitar selector manual de idioma de aplicación.
* Habilitar prueba de WebSocket para control remoto de terminal.
* Mejorar rendimiento de implementación Linux con deshabilitado de animaciones.
* Reorganizar llamados a módulo 'Device'.
* Mejorar intercambio interno de datos de la librería.

## 0.14.0
* Agregar implementación (sin probar) de NSDK para Newland.
* Optimizar generación de APKs de la app demo para reducir tamaño de las mismas.
* Realizar migración interna de paquete ofuscado de código de implementación.
* Agregar descarga en demo de aplicación instalable en el dispositivo.

## 0.13.2
* Agregar scripts para release precompilado de librería.
* Habilitar ofuscamiento selectivo de código Android de la librería.

## 0.13.1
* Arreglar bug con pantalla de configuración.
* Agregar y ajustar scripts.
* Mejoras internas de código y documentación.

## 0.13.0
* Habilitar multilenguaje y localización automática de aplicación Demo
  (inglés y español).
* Agregar módulo para administración de dispositivo.
* Agregar funcionalidad de reinicio de dispositivo.
* Agregar funcionalidad para instalar/desinstalar aplicaciones del dispositivo.

## 0.12.2
* Agregar mejoras de versión 'generic' y funcionamiento reflexivo de app Demo.
* Agregar scripts de desarrollo.

## 0.12.1
* Ajustes internos al módulo de impresión.


## 0.12.0
* Agregar posibilidad de imprimir bitmap mediante impresora térmica del terminal.
* Mejorar módulo de impresión con renderizado agnóstico de ticket.
* Agregar sub-módulo para criptografía DUKPT con 3DES bajo hardware seguro.
* Implementar funcionalidad de "Capítulo X" para criptografía de México.
* Desarrollar pantalla para inicialización y borrado de llaves en app Demo.
* Solucionar bug CTLSS en NEWPOS.

## 0.11.0
* Implementar posibilidad de seleccionar AID en tarjeta con múltiple opción.
* Agregar algoritmos para manejo de imágenes y futuras mejoras de impresión.
* Habilitar impresión de bitmap básica (a mejorar en futuras versiones).
* Agregar prueba de integración de módulo de impresora.

## 0.10.2
* Extender datos dinámicos en ticket de ejemplo de transacción EMV.
* Ajustar implementaciones de Printer para esperar cierre de proceso.
* Agregar chequeo reflexivo de Printer y PED.
* Mejoras del código interno de la librería y arreglo de bugs menores.

## 0.10.1
* Habilitar 'wrap' automático de líneas a imprimir.
* Agregar impresión de ticket en demo de transacción EMV Contactless.
* Resolver bug con impresión de líneas vacías en Newpos.

## 0.10.0
* Crear nuevo módulo de impresión.
* Implementar impresión de texto en todos los terminales soportados.
* Agregar impresión de ticket en demo de transacción EMV Contacto.

## 0.9.0
* Habilitar transacción EMV Contacto y Contactless en Newland Linux.
* Habilitar ingreso de PIN nativo en Newland Linux.

## 0.8.1
* Habilitar PIN Offline Cifrado con PED nativo.
* Habilitar configuración de longitudes permitidas de PIN.
* Refactorizar manejo de eventos EMV y de PIN.

## 0.8.0
* Cambiar a PIN Offline en claro con módulo PED nativo de cada SDK.

## 0.7.2
* Solucionar bug con bloqueo de transacción en NEWPOS.

## 0.7.1
* Implementar ingreso alfanúmerico desde Keypad embebido en Newland Linux.

## 0.7.0
* Implementar módulo de detección de tarjetas en Newland Linux.
* Implementar carga de parámetros EMV en Newland Linux.

## 0.6.0
* Agregar primera implementación de prueba con embedder Linux para Newland
  SP830.
* Implementar chequeo reflexivo de Keypad físico.
* Implementar chequeo reflexivo de tipos de tarjeta soportadas.
* Ajustar interfaz demo para soportar entrada de Keypad físico.
* Ajustar interfaz demo para mejorar el renderizado 'responsive' de la
  aplicación.
* Agregar fuentes de texto 'custom' para correcto renderizado en Linux embebido.
* Arreglar espera de retiro de tarjeta Contactless en demo con transacción
  offline.

## 0.5.1
* Arreglar bug con EMV Contacto en Newpos.
* Solucionar falla de proceso CDA bajo transacción Contactless en Newpos.

## 0.5.0
* Agregar funcionalidad para esperar retiro de tarjeta Contactless.
* Ajustar el flujo de Venta para esperar retiro de tarjeta Contactless.
* Arreglar flujo EMV Contactless en Newpos con nuevo código para kernels L2
  PayPass y PayWave.
* Habilitar funciones para chequeo reflexivo de módulos EMV y 'CardReader'.

## 0.4.4
* Implementar EMV Contactless bajo kernel PayWave en PAX.

## 0.4.3
* Implementar EMV Contactless bajo kernel PayPass en PAX.

## 0.4.2
* Refactorizar código nativo para facilitar mantenimiento y futuro desarrollo.
* Implementar flujo de transacción EMV Contactless en Newland.
* Implementar parcialmente flujo EMV Contactless Newpos.

## 0.4.1
* Agregada primera implementación de PIN Offline Cifrado.
* Arreglar bugs a la hora de cancelar ingreso de PIN.
* Arreglar detección Contactless en terminal Newpos.
* Mejoras en código nativo de transacción EMV.

## 0.4.0
* Desarrollado método "start" para iniciar una transacción EMV a nivel Kernel.
* Implementado intercambio de eventos EMV entre capa de abstracción y Kernel.
* Agregado código de soporte para marcas PAX y Newpos a partir de sus demos.
* Agregadas estructuras de datos para intercambio de tags con el Kernel.
* Agregado llamado para obtener tags desde el Kernel.
* Implementado flujo completo de transacción EMV Contacto Online y Offline.
* Implementado CVM de PIN Offline **en claro**.
* Agregada pantalla en demo para ingreso de PIN.
* Agregada pantalla de log final de tags EMV como resumen de transacción.

## 0.3.0
* Desarrollado método 'init' para inicialización del Kernel EMV.
* Agregado algoritmo básico para empacado de formato TLV.
* Agregadas clases e interfaces de parámetros EMV.
* Implementada carga de paramétros EMV al Kernel nativo.
* Implementada carga desde JSON de los parámetros EMV.
* Agregadas en demo pantallas para configuración manual de algunos parámetros.
* Agregados valores por defecto en app demo para pruebas de parámetros.

# 0.2.2
* Mostrar en demo de Venta solicitud de tarjeta de chip contacto (aún sin
  procesar).
* Agregar implementación de marca "NEWPOS" para módulo de detección y lectura
  de tarjetas.
* Actualizar código de botones.
* Ajustes internos de código nativo.

## 0.2.1
* Arreglado problema de interacción con Test de *CardReader*.
* Mejorada interacción con ventanas de log e info.

## 0.2.0
* Agregada interfaz *listener* para recibir eventos de detección de tarjetas
  (Banda magnética, Chip Contacto y *Contactless*).
* Implementada la lectura de Tracks de la banda magnética.
* Mejorado algoritmo de Track 2 para manejar BCD y ASCII.
* Agregado en app demo flujo básico de venta con tarjeta de banda.
* Agregada en app demo pantalla para *Tests* de módulo de banda y futuros
  módulos.
* Habilitada interfaz AAR para uso de la detección de tarjetas y lectura de
  banda en apps nativas.
* Mejorados flujos de venta en app demo con ventana para confirmar cancelación.

## 0.1.0
* Desarrollo de estructuras para manejo de mensaje ISO8583.
* Agregada la codificación y decodificación de mensaje ISO en formato texto.
* Agregados algoritmos y habilitada parametrización para permitir manejo de
  mensaje ISO en BCD o cualquier otro formato binario.
* Agregado widget "NumericKeyboard" para teclado númerico simple.
* Desarrollo de pantallas demo de "Venta Digitada".
* Implementado algoritmo para armado de Track2 "dummy".
* Agregadas pruebas unitarias para los sub-módulos desarrollados.
* Habilitada interfaz AAR para manejo básico de mensaje ISO (sin parametrización
  de algoritmos) desde app Android nativa.
* Mostrar temporalmente log de mensaje ISO8583 al final del flujo de venta para
  verificación.

## 0.0.1
* Commit inicial.
* Ajuste de documentos "README".
* Ajuste de archivos de configuración.

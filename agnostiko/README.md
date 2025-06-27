![Logo de Agnostiko](img/agnostiko-logo.png)

La Librería Universal de Pagos *Agnostiko* es un plugin agnóstico (sin dependencias sobre la plataforma) implementado en el Framework Flutter con su respectivo lenguaje Dart, que permite acelerar la desarrollo de aplicaciones financieras para dispositivos móviles de pago (TPVs, por ejemplo).

## Ambiente recomendado

Para desarrollar con el SDK Agnostiko se recomienda utilizar sistema Windows 10 o Windows 11.

La versión de Flutter instalada debe corresponderse con la versión de release de Agnostiko a utilizar. Los releases de Agnostiko se nombran con el formato 'agnostiko-X-flutter-Y.zip' donde 'Y' indica la versión de Flutter soportada por la versión 'X' del SDK.

## Instalación

El SDK Agnostiko se distribuye en formato ZIP. El archivo comprimido de cada release contiene todo lo necesario para utilizar la librería en una aplicación de Flutter.

Dicho archivo, deberá ser descomprimido en una ruta del sistema donde se desarrollará la app. Preferiblemente, la ruta donde se descomprima Agnostiko debería estar en el mismo directorio que la aplicación a desarrollar de manera que sea fácil de vincular a través de una ruta relativa.

![Ruta de Agnostiko](img/agnostiko-path.PNG)

Se puede comprobar que la librería y su instalación de Flutter están funcionando correctamente ingresando a la ruta './agnostiko/example/' y corriendo el script 'build_apks.bat'. Si su entorno está bien configurado para compilar apps Android de Flutter, dicho script debería generar varias APKs en el mismo directorio con un mensaje de éxito para cada versión correctamente compilada.

![Compilación exitosa en build_apks.bat](img/build-apk-success.PNG)

Por otro lado, para que su propia aplicación a desarrollar pueda utilizar el SDK, deberá agregar la ruta de Agnostiko como dependencia en el archivo 'pubspec.yaml' de dicha app. La ruta preferiblemente debe ser relativa, similar a como se observa en la siguiente imagen:

![Dependencia de Agnostiko en App](img/dependencies.PNG)

## Configuración y uso para sistema Android

### Versión mínima 

La versión mínima para compilar una app para Android es la 5.1 (Lollipop - API 22).

### Configuración de build.gradle

Para configurar una app Android a compilar con el SDK, se debe setear a *true* el parámetro **minifyEnabled** de Gradle para lograr un correcto ofuscamiento del código. Esto se debe hacer en el archivo './android/app/build.gradle' relativo a la ruta de su aplicación.

Sin embargo, para evitar que el ofuscamiento de R8 elimine código necesario para el correcto funcionamiento de la librería es necesario configurar correctamente también el archivo Proguard.

De acuerdo con lo anterior, este repositorio contiene el archivo Proguard configurado para lograr ese objetivo en './example/android/app/proguard-rules.pro'. Dicho archivo deberá ser copiado a la ruta './android/app/' en cualquier aplicación para plataforma Android que se desarrolle con el SDK Agnostiko.

```
buildTypes {
  release {
    signingConfig signingConfigs.debug

    minifyEnabled true
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
  }
}
```

Nótese que esta sección está configurada con 'signingConfig signingConfigs.debug' para firmar con llaves por defecto incluidas con Flutter. Para una aplicación que vaya a producción, se debe configurar correctamente el firmado del APK de acuerdo a sus requerimientos.

### Habilitación de permisos

Es necesario tener en cuenta los permisos necesarios para ciertas funcionalidades. Dichos permisos no dependen del SDK sino del sistema operativo Android.

En la ruta './example/android/app/src/main/AndroidManifest.xml' se encuentran los distintos permisos que pudieran ser necesarios para una aplicación que utilice el SDK dependiendo de sus requerimientos.

Adicionalmente, dependiendo de la versión de Android puede ser necesario que la aplicación solicita al usuario confirmar los permisos a la hora de ejecutar una funcionalidad. Por ejemplo, para dar acceso al almacenamiento, al Bluetooth o al NFC.

Para esto último, se recomienda utilizar el paquete 'permission_handler' de Flutter que fácilmente permite validar si un permiso está habilitado o de ser necesario le solicita al usuario su confirmación. En la app example se pueden observar ejemplos de su uso.

### Acceso a almacenamiento interno

Por otro lado, si la aplicación necesita acceder al almacenamiento interno, aparte de ser necesario el permiso de acceso, en las últimas versiones de Android puede ser necesario habilitar un 'FileProvider' para poder acceder a los archivos en ciertas rutas.

En la ruta './example/android/app/src/main/AndroidManifest.xml' se puede observar un ejemplo de como configurar dicho 'FileProvider'.

### Compilación Condicional 

Las aplicaciones Android que utilicen la librería, deben seleccionar mediante un argumento de compilación la implementación nativa que se va a empaquetar en el APK.

El comando correcto para correr la aplicación Flutter que utilice Agnostiko sería el siguiente:

```shell
flutter run --dart-define=IMPLEMENTATION=X
```

Donde 'X' debe ser el ID de la plataforma para la que se desea compilar. La lista de plataformas Android soportadas actualmente es la siguiente:

- newland_nsdk (POS de marca Newland)
- newland_pinpad (Pinpad de marca Newland)
- pax (POS de marca PAX)

Por ejemplo, para correr en modo debug una aplicación que utilice la Librería Universal en un terminal Android de marca Newland:

```shell
flutter run --dart-define=IMPLEMENTATION=newland
```

Nótese el argumento **--dart-define=IMPLEMENTATION=newland** que se utiliza para definir una 'variable de entorno' de Dart para que el script de compilación de la librería seleccione los componentes adecuados para la implementación de determinado tipo de terminal.

Igualmente, para generar una APK 'Release' para un terminal Android de PAX el comando sería:

```shell
flutter build apk --dart-define=IMPLEMENTATION=pax
```

## Linux - Newland

### Requerimientos

Para poder compilar y empaquetar la aplicación para la implementación Linux de Newland (única soportada actualmente), es necesario cumplir con los siguientes requerimientos:

1. Estar en Windows 10/11 y tener instalado WSL 2, preferiblemente bajo Ubuntu 20.04.
2. Tener instalado el paquete 'Common' del NPT_SDK de Newland para poder acceder a la app "Package Generator" la cual es necesaria para generar el instalador de extensión '.NLD'.
3. Instalar la versión exacta de Flutter requerida para esta versión de Agnostiko.
4. Setear la variable de entorno 'FLUTTER_ROOT' a la ruta raíz de su instalación de Flutter.

Una vez cumplidos dichos requerimientos, puede avanzar a la compilación de la app.

### Compilación y generación de instalador para Newland Linux

Para compilar y empaquetar la aplicación para instalar en un terminal Linux de Newland, se debe utilizar el script 'build_newland.bat' localizado en el directorio 'embedders/scripts/' de este SDK.

Dicho script debe ser invocado desde el directorio raíz de la app que se desea compilar. Para lograr esto, se puede utilizar la ruta absoluta o relativa del mismo. Por otro lado, se puede agregar el directorio de los scripts del embedder a la variable PATH del sistema para poder invocar dichos scripts desde cualquier directorio sin necesidad de colocar la ruta.

```shell
..\embedders\scripts\build_newland.bat Agnostiko 1.0.0 APPS2GO
```

El script requiere de 3 argumentos en el siguiente orden:

1. El nombre de aplicación
2. La versión
3. El nombre de empresa (este se coloca por requisito del empaquetador de Newland)

Una vez invocado, el script se encargará de compilar el código Dart de la aplicación y posteriormente empaquetarla en un instalador '.NLD' para poder ser instalada en terminales Linux de la marca Newland.


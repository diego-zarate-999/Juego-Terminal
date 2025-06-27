rem una vez compilado, borramos el gen_snapshot
@del gen_snapshot

rem creamos la carpeta con los 'assets' de la aplicación
@CALL flutter build bundle --release --no-tree-shake-icons

rem borramos archivos innecesarios para el empaquetado de la app
@del .\build\app.dill
@del .\build\gen_snapshot
@del .\build\kernel_snapshot.d
@del .\build\snapshot_blob.bin.d

ECHO *** Listo!

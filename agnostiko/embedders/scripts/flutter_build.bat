@CALL %~dp0\compile_dart_code.bat

ECHO *** Generando snapshot...
@CALL wsl.exe ./gen_snapshot --snapshot_kind=app-aot-elf --elf=./build/app.so --deterministic --obfuscate --strip --no-sim-use-hardfp --no-use-integer-division --no-use-neon --no-enable-simd-inline ./build/app.dill

@CALL %~dp0\build_app_bundle.bat

# App de tareas · Flutter + Supabase

## Stack
- Flutter 3.47.5 vía FVM · supabase_flutter ^2.17
- Supabase: Postgres, Auth anónima y Realtime

## Reglas
- Inicializa con `publishableKey`: `anonKey` está obsoleto.
- La secret key nunca entra en la app.
- Configuración solo con `--dart-define-from-file=.env`.
- Cada tabla: RLS activo, grants mínimos
  y una política por operación.
- La UI no llama a Supabase: todo pasa por `lib/datos/`.

## Forma de trabajar
- Antes de editar, propón un plan y espera mi OK.
- Al terminar: `fvm flutter analyze` sin avisos.

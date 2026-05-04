# ShotPlay

Aplicación móvil multijugador para jugar juegos de mesa y sociales con amigos. Los jugadores pueden crear o unirse a salas de juego en tiempo real.

> **JUEGA. COMPITE. CONQUISTA.**

---

## Tecnologías utilizadas

- **Flutter** `^3.7.0` — framework de desarrollo móvil
- **Supabase** — backend, autenticación y streams en tiempo real
- **flutter_bloc** — manejo de estado para autenticación y perfil
- **Provider / ChangeNotifier** — manejo de estado para catálogo, sala y sala de espera

---

## Configuración del entorno

### Prerrequisitos

- Flutter SDK `>=3.7.0`
- Dart SDK
- Android Studio o Xcode (según plataforma destino)
- Cuenta en [Supabase](https://supabase.com)

### Instalación

1. Clonar el repositorio:

```bash
git clone https://github.com/isabelaocampos/ShotPlay.git
cd ShotPlay/shotplay_app
```

2. Crear el archivo `.env` en `shotplay_app/` con las credenciales de Supabase:

```env
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
```

3. Instalar dependencias:

```bash
flutter pub get
```

4. Ejecutar la aplicación:

```bash
flutter run
```

---

## Flujos de navegación

### Flujo 1 — Autenticación

Este flujo permite al usuario acceder a la aplicación por primera vez o iniciar sesión en una cuenta existente.

```
Pantalla de Bienvenida
        │
        ├──► [Botón "Iniciar sesión"] ──► Pantalla de Login
        │                                        │
        │                                        └──► [Ingresar email y contraseña]
        │                                             [Botón "Ingresar"] ──► Pantalla Principal
        │
        └──► [Botón "Registrarse"] ──► Pantalla de Registro
                                              │
                                              └──► [Completar datos de usuario]
                                                   [Botón "Crear cuenta"] ──► Pantalla Principal
```

**Instrucciones paso a paso:**

1. Al abrir la app, aparece la **Pantalla de Bienvenida** con el logo de ShotPlay.
2. Para iniciar sesión con una cuenta existente, toca **"Iniciar sesión"**, ingresa tu correo y contraseña, y toca **"Ingresar"**.
3. Para crear una cuenta nueva, toca **"Registrarse"**, completa el formulario con tus datos y toca **"Crear cuenta"**.
4. Tras autenticarte correctamente, la app redirige automáticamente a la **Pantalla Principal**.

---

### Flujo 2 — Navegación principal (barra inferior)

Una vez autenticado, la **Pantalla Principal** tiene una barra de navegación inferior con cuatro pestañas:

| Pestaña | Ícono | Descripción |
|---------|-------|-------------|
| Inicio | Casa | Pantalla de inicio (próximamente) |
| Juegos | Joystick | Catálogo de juegos disponibles |
| Social | Personas | Red social (próximamente) |
| Perfil | Usuario | Información del perfil y opciones de sesión |

**Instrucciones:**

- Toca cualquier ícono de la barra inferior para cambiar de sección.
- La pestaña **Juegos** es el punto de partida para crear o unirse a una sala.
- La pestaña **Perfil** permite cerrar sesión.

---

### Flujo 3 — Explorar el catálogo de juegos

Este flujo permite al usuario ver los juegos disponibles y acceder a sus detalles.

```
Pantalla Principal (pestaña "Juegos")
        │
        └──► Catálogo de Juegos (cuadrícula 2 columnas)
                    │
                    ├──► [Tarjeta "Escaleras y Serpientes"] ──► Detalles del Juego
                    │
                    └──► [Tarjeta "El Impostor"] ──► Detalles del Juego
```

**Instrucciones paso a paso:**

1. En la barra inferior, toca la pestaña **Juegos**.
2. Aparece el catálogo con los juegos disponibles en una cuadrícula.
3. Toca la tarjeta de cualquier juego para ver sus **Detalles**: descripción, número de jugadores requeridos y duración estimada.
4. Desde la pantalla de detalles puedes elegir **Crear sala** o **Unirse a sala**.

**Juegos disponibles:**

- **Escaleras y Serpientes** — 2 a 6 jugadores, ~20 min. Juego de tablero clásico.
- **El Impostor** — 5 a 10 jugadores, ~15 min. Juego social de deducción.

---

### Flujo 4 — Crear una sala

Este flujo permite al anfitrión configurar y crear una nueva sala de juego.

```
Detalles del Juego
        │
        └──► [Botón "Crear sala"] ──► Configurar Sala
                                            │
                                            ├── Ingresar nombre de la sala
                                            ├── Ajustar número máximo de jugadores (+/-)
                                            ├── Activar/desactivar "Modo rápido"
                                            ├── Activar/desactivar "Sala privada"
                                            │
                                            └──► [Botón "Crear"] ──► Sala de Espera
```

**Instrucciones paso a paso:**

1. En la pantalla de **Detalles del Juego**, toca **"Crear sala"**.
2. En la pantalla de **Configurar Sala**:
   - Escribe un nombre para la sala en el campo de texto.
   - Usa los botones **+** y **−** para ajustar el número máximo de jugadores permitidos.
   - Activa **"Modo rápido"** si deseas partidas con tiempo reducido.
   - Activa **"Sala privada"** para que solo quienes tengan el código puedan unirse.
3. Toca **"Crear"** para generar la sala. Se crea un **código único** de sala automáticamente.
4. La app navega a la **Sala de Espera** donde eres el anfitrión.

---

### Flujo 5 — Sala de espera

Este flujo muestra el lobby antes de iniciar el juego, donde los jugadores se reúnen usando el código de sala.

```
Sala de Espera
        │
        ├──► Código de sala visible (copiable / compartible)
        ├──► Lista de jugadores conectados en tiempo real
        ├──► Espacios vacíos para los jugadores pendientes
        │
        ├──► [Solo anfitrión] Botón "Iniciar partida"
        │         └── Habilitado cuando hay ≥ 2 jugadores conectados
        │
        └──► Tarjeta de consejos con instrucciones del juego
```

**Instrucciones paso a paso:**

1. Al entrar a la **Sala de Espera**, verás el **código de la sala** en la parte superior.
2. Comparte ese código con tus amigos para que puedan unirse.
   - Toca el ícono de copiar junto al código para copiarlo al portapapeles.
3. La lista de jugadores se actualiza **en tiempo real** a medida que otros se unen.
4. Los espacios vacíos muestran cuántos jugadores faltan para completar la sala.
5. Cuando hay al menos **2 jugadores** conectados, el anfitrión puede tocar **"Iniciar partida"** para comenzar.

---

### Flujo 6 — Perfil y cierre de sesión

```
Pantalla Principal (pestaña "Perfil")
        │
        ├──► Ver información del usuario y estadísticas
        │
        └──► [Botón "Cerrar sesión"] ──► Pantalla de Bienvenida
```

**Instrucciones:**

1. Toca la pestaña **Perfil** en la barra inferior.
2. Aquí puedes ver tu información de usuario y estadísticas.
3. Para cerrar sesión, toca **"Cerrar sesión"**. La app regresa a la **Pantalla de Bienvenida**.

---

## Resumen de flujos

```
Bienvenida ──► Login / Registro
                    │
                    ▼
            Pantalla Principal
            ┌───────┬───────┬───────┐
          Inicio  Juegos  Social  Perfil
                    │               │
                    ▼               ▼
            Catálogo de        Cerrar sesión
              Juegos
                    │
                    ▼
            Detalles del Juego
            ┌──────┴──────┐
            ▼             ▼
       Crear sala    Unirse a sala
            │
            ▼
       Configurar Sala
            │
            ▼
       Sala de Espera ──► Iniciar partida
```

---

## Estructura del proyecto

```
shotplay_app/
└── lib/
    └── src/
        ├── common_widgets/     # Componentes reutilizables
        ├── core/               # Configuración, rutas, tema
        ├── data/               # Implementaciones de repositorios (Supabase / local)
        ├── domain/             # Entidades y contratos de repositorios
        └── features/
            ├── auth/           # Pantalla de bienvenida
            ├── login/          # Pantalla de inicio de sesión
            ├── signup/         # Pantalla de registro
            ├── game_catalog/   # Catálogo de juegos
            ├── game_details/   # Detalles del juego
            ├── create_room/    # Configuración de sala
            ├── waiting_room/   # Sala de espera
            └── profile/        # Perfil de usuario
```

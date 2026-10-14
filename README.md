# Stream Deck MVP para macOS

Una aplicación macOS en SwiftUI que sustituye las automatizaciones básicas del software de Elgato, sin dependencias de terceros.

## Qué incluye

- Detecta dispositivos USB HID de Elgato (vendor ID `0x0FD9`).
- Perfil local de 15 teclas, guardado en `~/Library/Application Support/StreamDeckMVP/profile.json`.
- Ejecuta atajos de teclado, abre URLs y hace solicitudes `POST` a webhooks.
- Interfaz para editar el título, símbolo SF, color y acción de cada botón.
- Un tablero visual que permite probar las acciones sin conectar el hardware.

## Ejecutar

Requiere macOS 14 o posterior y Xcode o Command Line Tools con Swift 6:

```sh
swift run
```

Al usar atajos, macOS solicitará permiso en **Configuración del Sistema → Privacidad y seguridad → Accesibilidad**. La app solo usa ese permiso para enviar el atajo configurado tras una pulsación.

## Alcance del MVP

Los modelos Stream Deck comparten el fabricante USB, pero el formato de las imágenes de las teclas cambia entre modelos. Esta versión detecta entradas HID y ejecuta acciones; todavía no transmite los mosaicos de imagen a las pantallas físicas. El punto de extensión está en `StreamDeckHID.swift`: al conocer el modelo exacto, se añade su descriptor y protocolo de informes de salida ahí, manteniendo intactos los perfiles y acciones.

No intenta eludir controles MDM, Gatekeeper ni permisos corporativos: la organización debe aprobar la aplicación y sus permisos según corresponda.

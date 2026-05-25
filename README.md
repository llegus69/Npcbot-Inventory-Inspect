## 🚀 Características

* **Panel Lateral Organizador:** Lista de todos los bots detectados ordenados alfabéticamente.
* **Botón Flotante Arrastrable:** Abre y cierra el panel de manera rápida. Recuerda su posición exacta en la pantalla entre sesiones de juego.
* **Paperdoll Interactivo:** Cuenta con 19 slots de equipo en sus posiciones exactas (cabeza, hombros, pecho, armas, etc.) emulando la interfaz nativa.
* **Calidad de Objetos Visual:** Bordes de los slots coloreados según la calidad del ítem (Gris, Verde, Azul, Morado, Naranja).
* **Tooltips Completos:** Información detallada del ítem al pasar el ratón sobre cualquier slot.
* **Visualización 3D:** Modelo interactivo en 3D del bot en el centro del paperdoll cuando este se encuentra en tu grupo (`party1`-`party4`).
* **Cálculo de Gear Score:** Muestra el GS estimado del bot en el centro de la ventana.
* **Estadísticas Calculadas:** Suma automáticamente los stats base de todos los ítems equipados (Fuerza, Aguante, Crítico, etc.).
* **Persistencia de Datos:** Los inventarios y estadísticas se guardan por jugador entre sesiones.
* **Gestión Limpia:** Borrado completo de datos integrando un diálogo de confirmación para evitar pérdidas accidentales.

---

## 🛠️ Requisitos

* **Cliente:** World of Warcraft 3.3.5a (Interface `30300`).
* **Servidor:** Emulador basado en **AzerothCore** con el módulo (https://github.com/trickerer/AzerothCore-wotlk-with-NPCBots) instalado.
* **Script de Servidor (Opcional):** Módulo Lua `mod-ale` en el servidor para el script de recolección.
* **Mecanismo:** Los NPCBots deben estar configurados para enviar su equipo e ítems vía `CHAT_MSG_MONSTER_WHISPER`.

---

## 💾 Instalación

1. Descarga o clona este repositorio.
2. Copia la carpeta `NPCBotInventory` en el directorio de addons de tu juego:
   ```text
   World of Warcraft/Interface/AddOns/
Asegúrate de que la estructura de archivos quede exactamente de la siguiente manera:

Plaintext
Interface/
└── AddOns/
    └── NPCBotInventory/
        ├── NPCBotInventory.toc
        ├── Core.lua
        ├── UI.lua
        └── BotInspect.lua
Inicia el juego, asegúrate de activar el addon en la pantalla de selección de personaje y haz que tus bots reporten su inventario. ¡El addon lo capturará automáticamente!

## 🖥️ Interfaz Gráfica
Botón Flotante
Al cargar el juego, aparecerá el botón "Bot Inventory" en la esquina superior derecha. Puedes arrastrarlo libremente; el addon recordará la posición en tu próxima sesión.

Panel Lateral (Lista de Bots)
Al pulsar el botón flotante se despliega la lista de bots detectados. Cada fila contiene:

🟢 Punto verde indicador de estado.

Nombre del bot.

Número de ítems detectados entre paréntesis.

📜 Icono de pergamino para abrir el paperdoll.

Nota: Las filas son informativas, para abrir el detalle debes pulsar el icono del pergamino.

En la parte inferior se ubica el botón "Borrar todo" para limpiar la base de datos (requiere confirmación).

Paperdoll (Ventana de Inspección)
Es la ventana principal del addon y se divide en tres zonas:

Slots de Equipo (Izquierda y Derecha): 19 slots distribuidos de forma idéntica al CharacterFrame nativo de WoW.

Columna Izquierda: Cabeza, Cuello, Hombros, Espalda, Pecho, Camisa, Tabardo, Muñecas, Mano Principal.

Columna Derecha: Manos, Cintura, Piernas, Pies, Anillo 1, Anillo 2, Amuleto 1, Amuleto 2, Mano Secundaria.

Centro Inferior: A distancia.

Centro Visual:

Nombre del bot destacado en dorado.

Gear Score (GS) resaltado en verde.

Modelo 3D del bot con su equipamiento (muestra "Not in party" si no está en el grupo).

Panel de Estadísticas (Derecha):
Muestra la suma total de los atributos de todos los ítems equipados (solo se muestran las estadísticas que el bot realmente posea):

Primarias (Dorado): Fuerza, Agilidad, Aguante, Intelecto, Espíritu.

Ofensivas (Color respectivo): Attack Power, Spell Power, Crítico, Golpe, Celeridad, Pericia, Penetración de armadura.

Defensivas (Azul): Esquiva, Parada, Bloqueo, Resiliencia.

Regeneración: MP5, HP5.

⌨️ Comandos del ChatPuedes utilizar los siguientes comandos en el chat del juego:ComandoDescripción/botinvAbre o cierra el panel lateral de bots./botinv <NombreBot>Abre directamente el paperdoll del bot especificado./npcbotinvAlias alternativo para el comando principal.



<img width="3840" height="2160" alt="Wow 2026-05-24 00-37-49" src="https://github.com/user-attachments/assets/88596b81-d1b1-4f41-aa6e-98a1e04199aa" />

##⌨️ Comandos del Chat


Puedes utilizar los siguientes comandos en el chat del juego:

ComandoDescripción/botinvAbre o cierra el panel lateral de bots.

/botinv <NombreBot>Abre directamente el paperdoll del bot especificado.

/npcbotinvAlias alternativo para el comando principal.

📁 Estructura del Proyecto y Arquitectura

NPCBotInventory.toc: Descriptor del addon (versión, autor, SavedVariables).

Core.lua: Núcleo lógico. Escucha el evento CHAT_MSG_MONSTER_WHISPER, distingue entre los enlaces de ítems (item links) y mensajes de estadísticas, procesa los datos y los almacena en las SavedVariables. Notifica a la interfaz mediante callbacks.

UI.lua: Construye el botón flotante arrastrable y el panel lateral con la lista de bots. Está desacoplado de la lógica de datos.

BotInspect.lua: Gestiona el Paperdoll. Genera los slots dinámicamente con detección automática de tipo mediante GetItemInfo, renderiza el modelo 3D usando PlayerModel:SetUnit y procesa las estadísticas vía GetItemStats.

Variables Guardadas (SavedVariables)
BotInventoryDB: Almacena los inventarios de cada bot indexados por el nombre del jugador.

NBIStatsDB: Almacena las estadísticas y el GS de cada bot.

NBIButtonPos: Guarda la posición en pantalla del botón flotante.

⚠️ Notas Técnicas

Retrocompatibilidad estricta: Diseñado específicamente para WotLK 3.3.5a. No utiliza APIs introducidas en expansiones o parches posteriores (como SetColorTexture o SetPortraitZoom).

Codificación: Todos los archivos de código están guardados en ASCII puro para evitar conflictos de codificación de caracteres con el cliente de WoW antiguo.

Limitación del Modelo 3D: El cliente del juego solo puede renderizar el modelo 3D si el bot está formalmente en tu grupo (party1 a party4).

Cálculo de Stats: La función nativa GetItemStats devuelve los atributos base del objeto. No incluye los bonus otorgados por gemas ni por encantamientos.

Caché de Ítems: Si un ítem se consulta por primera vez en el servidor, puede que no muestre el icono de inmediato debido a que no está en la caché del cliente. Volver a abrir la ventana solucionará el problema una vez el cliente reciba la información del servidor.

🤝 Contribuir

Si encuentras algún error, bug o tienes sugerencias para mejorar el diseño o las funcionalidades del addon:

Abre un Issue explicando el problema o propuesta.

Si tienes el fix o mejora lista, ¡un Pull Request es más que bienvenido!


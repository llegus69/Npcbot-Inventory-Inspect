NPCBotInventory

Addon para World of Warcraft WotLK 3.3.5 que muestra el equipo de tus NPCBots con una interfaz limpia y mejorada, incluyendo un paperdoll interactivo con modelo 3D.

Creado por Lleguito - compatible con servidores AzerothCore + mod-npcbots.

Caracteristicas

Panel lateral con la lista de todos tus bots detectados
Ventana de equipo en grid con iconos coloreados segun calidad del item
Tooltip al pasar el raton sobre cualquier item
Paperdoll interactivo con los slots en su posicion correcta (cabeza, pecho, armas...)
Modelo 3D del bot en el centro del paperdoll cuando esta en tu grupo
GS (Gear Score) del bot mostrado en la ventana de inspect
Boton flotante arrastrable, siempre visible en pantalla
El boton recuerda su posicion entre sesiones
Inventarios y GS guardados por jugador entre sesiones
Scroll si el bot tiene muchos items
Borrado de inventarios con confirmacion


Requisitos

World of Warcraft 3.3.5a (cliente WotLK)
Servidor con AzerothCore y el modulo mod-npcbots instalado


Instalacion

Descarga o clona este repositorio
Copia la carpeta NPCBotInventory dentro de:

   World of Warcraft/Interface/AddOns/

La estructura debe quedar exactamente asi:

   Interface/
   └── AddOns/
       └── NPCBotInventory/
           ├── NPCBotInventory.toc
           ├── Core.lua
           ├── UI.lua
           └── BotInspect.lua

Inicia el juego y activa el addon en la pantalla de seleccion de personaje


Uso
ComandoDescripcion/botinvAbre o cierra el panel de bots/botinv inspect NombreBotAbre directamente el paperdoll de ese bot/npcbotinvAlias del comando anterior
El boton flotante "Bot Inventory" aparece en la esquina superior derecha. Puedes arrastrarlo y recuerda su posicion entre sesiones.
Panel de bots
Muestra la lista de todos los bots de los que se ha recibido inventario. Cada fila tiene:

Nombre del bot y numero de items
Boton [i] para abrir el paperdoll directamente

Paperdoll (Bot Inspect)
Ventana estilo CharacterFrame con tres zonas:
Slots de equipo - 19 slots en las posiciones exactas del paperdoll de WoW. El borde de cada slot se colorea segun la calidad del item (gris, verde, azul, morado, naranja). Tooltip al pasar el raton.
Centro - Nombre del bot, GS y modelo 3D del bot si esta en tu grupo. El modelo muestra al bot con todo su equipo puesto en tiempo real.
Panel de stats - Estadisticas enviadas por el bot (GS y cualquier otra que el servidor envie).

Nota: El modelo 3D solo aparece cuando el bot esta en tu grupo (party1-party4). Si no esta en el grupo el centro muestra "Not in party".


Estructura del proyecto
NPCBotInventory/
├── NPCBotInventory.toc   -- Descriptor del addon
├── Core.lua              -- Logica: captura whispers, guarda inventarios y stats
├── UI.lua                -- Panel lateral de bots y boton flotante
└── BotInspect.lua        -- Ventana paperdoll con modelo 3D y slots de equipo

SavedVariables
VariableContenidoBotInventoryDBInventarios de cada bot por nombre de jugadorNBIStatsDBStats (GS) de cada bot por nombre de jugadorNBIButtonPosPosicion guardada del boton flotante

Compatibilidad
SoftwareVersionWoW Client3.3.5a (Interface 30300)AzerothCoreCualquier version recientemod-npcbotsCompatible

Contribuir
Si encuentras un bug o quieres proponer una mejora, abre un Issue o un Pull Request.

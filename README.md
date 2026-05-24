Descripcion

NPCBotInventory captura automaticamente los mensajes que los NPCBots envian por susurro cuando reportan su inventario, y los presenta en una interfaz visual completa. El addon ofrece dos vistas: un panel lateral con la lista de todos los bots detectados, y un paperdoll detallado por bot con sus slots de equipo, modelo 3D, estadisticas calculadas y Gear Score.

Caracteristicas

Panel lateral con la lista de todos los bots detectados, ordenados alfabeticamente
Boton flotante arrastrable que abre y cierra el panel, recuerda su posicion entre sesiones
Paperdoll interactivo con 19 slots de equipo en sus posiciones exactas (cabeza, hombros, pecho, armas...)
Bordes de slot coloreados segun la calidad del item (gris, verde, azul, morado, naranja)
Tooltip completo al pasar el raton sobre cualquier slot
Modelo 3D del bot en el centro del paperdoll cuando el bot esta en tu grupo (party1-party4)
GS (Gear Score) mostrado en el centro de la ventana
Estadisticas calculadas sumando los stats base de todos los items equipados (Fuerza, Aguante, Critico...)
Inventarios y stats guardados por jugador entre sesiones
Borrado de datos con dialogo de confirmacion


Requisitos

World of Warcraft 3.3.5a (cliente WotLK, Interface 30300)
Servidor con AzerothCore y el modulo mod-npcbots instalado
Modulo Lua mod-ale en el servidor (para el script de recoleccion, opcional)
Los NPCBots deben enviar su equipo e items via CHAT_MSG_MONSTER_WHISPER


Instalacion

Descarga o clona este repositorio
Copia la carpeta NPCBotInventory a:

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
Haz que tus bots reporten su inventario — el addon lo capturara automaticamente


Interfaz grafica
Boton flotante
Al cargar el addon aparece el boton "Bot Inventory" en la esquina superior derecha de la pantalla. Puedes arrastrarlo a cualquier posicion — el addon recuerda donde lo dejaste entre sesiones.
Panel lateral (lista de bots)
Al pulsar el boton flotante se abre el panel lateral con todos los bots detectados. Cada fila muestra:

Punto verde indicador
Nombre del bot
Numero de items entre parentesis
Icono de pergamino para abrir el paperdoll

Las filas son solo informativas — para acceder al detalle usa el icono de pergamino.
En la parte inferior del panel hay un boton "Borrar todo" que elimina todos los inventarios guardados (con confirmacion).
Paperdoll (ventana de inspect)
La ventana principal del addon. Se abre al pulsar el icono de pergamino de cualquier bot. Tiene tres zonas:
Slots de equipo (izquierda y derecha)
19 slots distribuidos igual que el CharacterFrame nativo de WoW:

Columna izquierda: Cabeza, Cuello, Hombros, Espalda, Pecho, Camisa, Tabardo, Munecas, Mano principal
Columna derecha: Manos, Cintura, Piernas, Pies, Anillo 1, Anillo 2, Amuleto 1, Amuleto 2, Mano secundaria
Centro inferior: A distancia

Cada slot muestra el icono del item con el borde coloreado segun su calidad. Al pasar el raton aparece el tooltip completo del item.
Centro

Nombre del bot en dorado
GS en verde
Modelo 3D del bot con su equipo si esta en el grupo, o "Not in party" si no lo esta

Panel de estadisticas (derecha)
Muestra la suma total de cada stat de todos los items equipados:

Stats primarias (Fuerza, Agilidad, Aguante, Intelecto, Espiritu) en dorado
Stats ofensivas (Attack Power, Spell Power, Critico, Golpe, Celeridad, Pericia, Penetracion de armadura) en sus colores respectivos
Stats defensivas (Esquiva, Parada, Bloqueo, Resiliencia) en azul
Regeneracion (MP5, HP5)

Solo aparecen las stats que el bot realmente tiene en su equipo.
En la parte inferior de la ventana: "Creado por Lleguito".

Comandos
ComandoDescripcion/botinvAbre o cierra el panel de bots/botinv NombreBotAbre directamente el paperdoll de ese bot/npcbotinvAlias del comando anterior

Estructura del proyecto
NPCBotInventory/
├── NPCBotInventory.toc   -- Descriptor del addon (version, autor, SavedVariables)
├── Core.lua              -- Logica: captura whispers, parsea items y stats, SavedVariables
├── UI.lua                -- Panel lateral de bots y boton flotante arrastrable
└── BotInspect.lua        -- Paperdoll: slots de equipo, modelo 3D, stats calculadas
Core.lua escucha CHAT_MSG_MONSTER_WHISPER, distingue entre item links y mensajes de stat, y los guarda en SavedVariables. Notifica a la UI mediante callbacks cuando hay datos nuevos.
UI.lua construye el panel lateral y el boton flotante. No contiene logica de datos.
BotInspect.lua construye el paperdoll completo: slots con deteccion automatica de tipo via GetItemInfo, modelo 3D via PlayerModel:SetUnit, y calculo de stats via GetItemStats.

SavedVariables
VariableContenidoBotInventoryDBInventarios de cada bot, indexados por nombre de jugadorNBIStatsDBStats (GS y otros) de cada bot, indexados por nombre de jugadorNBIButtonPosPosicion guardada del boton flotante

Notas tecnicas

Compatible con WotLK 3.3.5a (Interface 30300). No usa APIs introducidas en parches posteriores (SetColorTexture, SetPortraitZoom, etc.)
Todos los archivos estan en ASCII puro para evitar problemas de codificacion con el cliente
El modelo 3D del bot requiere que el bot este en el grupo (party1-party4). Fuera del grupo el centro muestra "Not in party"
GetItemStats devuelve stats base sin gemas ni encantamientos
Si un item no esta en cache la primera vez que se abre el paperdoll puede aparecer sin icono. La segunda vez ya estara cacheado


Compatibilidad
SoftwareVersionWoW Client3.3.5a (Interface 30300)AzerothCoreCualquier version recientemod-npcbotsCompatiblemod-ale (Eluna)Compatible (script de recoleccion)

Contribuir
Si encuentras un bug o quieres proponer una mejora, abre un Issue o un Pull Request.


<img width="3840" height="2160" alt="Wow 2026-05-24 00-37-49" src="https://github.com/user-attachments/assets/88596b81-d1b1-4f41-aa6e-98a1e04199aa" />







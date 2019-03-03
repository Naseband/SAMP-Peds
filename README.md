# SAMP-Peds

Adds Peds in all SA using FCNPC.
Peds will roam the streets and react to different events, eg. gunshots, dead players/NPCs, vehicles and rival Peds/Players.
Peds of certain groups will behave accordingly, Cops hunt criminals, whores will enter the vehicles of players, gangs fight each other and hang around in groups, etc.

The Ped Node Net is made from scratch and much more detailed and complete than the original one.
It consists of different types of Nodes, eg regular Nodes, Road Cross Nodes, Flee Nodes (for fleeing Peds), Hiker Trails and attractors.
Different towns are connected where possible. Attractors can be (fake) Interior Enter/Exits, Benches/places to sit, Slot Machines in Casinos and auto-generated locations for various animations (leaning against a wall, laying on the beach or swimming in a pool).

Custom attractors and functions to disable certain areas are available.

The Editor can be implemented into the script as well, allowing for ingame Node Editing/customizing
the Node Net for custom maps and the server.


# TODO

PEDS

- Extend Ped Node Net (30%)
- Peds Enter/Exit fake Interiors [DONE]
- Peds Enter/Exit actual Interiors
- Ped GRP spawns and stats [DONE]
- Spawn Cops around criminal players [DONE]
- Flee from threats - vehicles, players, objects or locations (explosions) [DONE]
- Aggro/FOF respecting PEDGRPs
- Ped vs Player Fighting
- Ped vs Ped Fighting
- Free Roam/return to node when attacking and find position for clear LoS using CA/FCNPC Pathfinding once finished
- Bench, Gamble, Smoking special Attractors
- Finding places for random animations
- Custom Gangs/Factions (useful for GW and maybe RP related servers) [DONE]
- Respawn FCNPC instead of reconnecting (to avoid constant console spam) [DONE]
- Implement info from popcycle.dat
- Add Accessories that drop when a Ped is shot/interacted with (like GTA V)
- Improve Spawn Node finding (current implementation is too slow)

NODE EDITOR

- Feature to move the whole Node Net (useful for custom Maps)
- Disable/enable certain nodes
- Adjacent Tele Node list to build Spawn Node data more efficiently
- Export function for GPS.dat (so it can be used for Road Nodes as well)

# Thanks to

- ziggi, OrMisicL (FCNPC)
- Crayder (skintags)
- Kris Toisberg (map-zones.inc)
- Incognito (streamer)
- Crayder, Pottus (ColAndreas)
- Zeex (zcmd)
- Y_Less (foreach and YSI)
- Macronix (testing)
- Weed (helping with nodes, testing)

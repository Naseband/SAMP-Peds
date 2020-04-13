# SAMP-Peds

Adds Peds in all SA using FCNPC.
Peds will roam the streets and react to different events, eg. gunshots, dead players/NPCs, vehicles and rival Peds/Players.
Peds of certain groups will behave accordingly, Cops hunt criminals, gangs fight each other and hang around in groups, etc.

The Ped Node Net is made from scratch and much more detailed than the original one and cities are intended to be connected, but not yet fully completed.
It consists of different types of Nodes, eg regular Nodes, Road Cross Nodes, Flee Nodes (for fleeing Peds using shortcuts), Hiker Trails and attractors.
Different towns are connected where possible. Attractors can be (fake) Interior Enter/Exits, Benches/places to sit, Slot Machines in Casinos and auto-generated locations for various animations (leaning against a wall, laying on the beach or swimming in a pool).

Custom attractors and functions to disable certain areas are available.

The Editor can be implemented into the script as well, allowing for ingame Node Editing and customizing
the Node Net for custom maps and the server.

# Editor

- Currently an ingame editor, you can edit nodes by shooting
- Desert Eagle selects the closest node from the shot destination
- Mp5 is used for the action you selected, eg. add new nodes
- Holding the Walk key while using the Mp5 will not create a new node, instead it will connect the selected node with the target node
- Node widths can be edited to make peds walk in lanes

# Nodes

- The nodes are currently stored by the script, this will become a problem later on so I will switch to the GPS or memory plugin at some point

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

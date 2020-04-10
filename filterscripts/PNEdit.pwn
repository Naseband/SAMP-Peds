/*

SAMP Peds

This script adds Peds in all SA using FCNPC.
Peds will roam the streets and react to different events, eg. gunshots, dead players/NPCs,
vehicles and rival Peds/Players.
Peds of certain groups will behave accordingly, Cops hunt criminals, whores will enter the vehicles of players,
gangs fight each other and hang around in groups, etc.

The Ped Node Net is made from scratch and much more detailed and complete than the original one.
It consists of different types of Nodes, eg regular Nodes, Road Cross Nodes, Flee Nodes (for fleeing Peds),
Hiker Trails and attractors.
Different towns are connected where possible.
Attractors can be (fake) Interior Enter/Exits, Benches/places to sit, Slot Machines in Casinos
and auto-generated locations for various animations (leaning against a wall, laying on the beach or swimming in a pool).

Custom attractors and functions to disable certain areas are available.

The Editor can be implemented into the script as well, allowing for ingame Node Editing/customizing
the Node Net for custom maps and the server.


TODO

- Extend Ped Node Net (30%)
- Peds Enter/Exist (fake) Interiors [DONE]
- Ped GRP spawns and stats
- Spawn Cops around criminal players [DONE]
- Flee from threats - vehicles, players, objects or locations (explosions) [DONE]
- Aggro/FOF respecting PEDGRPs
- Ped vs Ped Fighting
- Free Roam/return to node when attacking
- Bench, Gamble, Smoking Attractors
- Finding places for random animations
- Custom Gangs/Factions (useful for GW and maybe RP related servers)

Thanks to

- ziggi, OrMisicL (FCNPC)
- Crayder (skintags)
- Incognito (streamer)
- Crayder, Pottus (ColAndreas)
- Zeex (zcmd)
- Y_Less (foreach and YSI)
- [AMB]Macronix (testing)
- Weed (helping with nodes, testing)

Useful GTA SA Files:

popcycle.dat
ped.dat

*/

#if 0
#pragma option -r
#pragma option -d3
#endif

#include <a_samp>
#include <streamer>
#include <ColAndreas>
#include <sscanf2>
#include <zcmd>
#include <FCNPC>
#define _FOREACH_NO_TEST
#include <foreach_sa>
#include <skintags>
#include <map-zones>
//#include <a_mysql>

// Visible Nodes

#define PNODE_OBJECT_MODEL			19135
#define PNODE_OBJECT_OFF_Z			0.25
#define PNODE_OBJECT_SD 			100.0
#define PNODE_OBJECT_DD 			100.0
#define PNODE_CONN_SD				40.0
#define PNODE_CONN_DD				40.0

#define PNE_EDITOR					true

// General

new bool:gInitialized = false, bool:gPlayerInit[MAX_PLAYERS];

forward OnScriptInit();
forward OnScriptExit();

#include "pne/pne_limits_h.pwn"

#include "pne/pne_util_h.pwn" // Ped Base
#include "pne/pne_nodes_h.pwn"
#include "pne/pne_zones_h.pwn"
#include "pne/pne_gangs_h.pwn"
#include "pne/pne_pedgrp_h.pwn"
#include "pne/pne_ped_h.pwn"
#include "pne/pne_player_h.pwn" // Editor
#include "pne/pne_dialogs_h.pwn"
#include "pne/pne_textdraws_h.pwn"

#include "pne/pne_util.pwn" // Ped Base
#include "pne/pne_nodes.pwn"
#include "pne/pne_zones.pwn"
#include "pne/pne_gangs.pwn"
#include "pne/pne_pedgrp.pwn"
#include "pne/pne_ped.pwn"
#include "pne/pne_player.pwn" // Editor
#include "pne/pne_dialogs.pwn"
#include "pne/pne_textdraws.pwn"
#include "pne/pne_cmds.pwn"
#include "pne/pne_dump.pwn"

public OnScriptInit()
{
	if(gInitialized) return 1;

	ResetAllTeleZoneCounts();
	ApplyDefaultPedMapZones();
	LoadPedNodes(PNODE_FILE);
	TogglePedNodesAutoSave(0, PNODE_FILE);
	SetPedestrianAutoSpawn(0);

	PrintTeleZoneCounts();

	for(new i = 0; i < MAX_PLAYERS; i ++) if(IsPlayerConnected(i))
	{
		CallLocalFunction("OnPlayerConnect", "d", i);
	}

	/*new MySQL:mysql_connection = mysql_connect("localhost", "samp", "visuallizeit420&&/", "samp");

	DumpPedNodesToDB(mysql_connection, "pednodes");

	mysql_close(mysql_connection);*/

	gInitialized = true;

	return 1;
}

public OnScriptExit()
{
	if(!gInitialized) return 1;

	for(new i = 0; i < MAX_PLAYERS; i ++) if(IsPlayerConnected(i)) CallLocalFunction("OnPlayerDisconnect", "dd", i, 0);
	
	gInitialized = false;

	return 1;
}

public OnFilterScriptInit()
{
	if(!gInitialized)
	{
		CallLocalFunction("OnScriptInit", "");
		gInitialized = true;
	}

	return 1;
}

public OnFilterScriptExit()
{
	if(gInitialized)
	{
		CallLocalFunction("OnScriptExit", "");
		gInitialized = false;
	}

	return 1;
}

public OnGameModeInit()
{
	if(!gInitialized)
	{
		CallLocalFunction("OnScriptInit", "");
		gInitialized = true;
	}

	return 1;
}

public OnGameModeExit()
{
	if(gInitialized)
	{
		CallLocalFunction("OnScriptExit", "");
		gInitialized = false;
	}

	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerConnect(playerid)
{
	if(gPlayerInit[playerid]) return 1;

	CreatePlayerTextDraws(playerid);

	SetPlayerEditState(playerid, PLAYER_EDIT_NONE);
	SetPlayerEditSelection(playerid, -1);

	//ShowTestGZs(playerid);

	gPlayerInit[playerid] = true;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(!gPlayerInit[playerid]) return 1;

	DestroyPlayerTextDraws(playerid);

	gPlayerInit[playerid] = false;

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerEditState(playerid) == PLAYER_EDIT_NONE) return 1;

	if(newkeys & KEY_LOOK_BEHIND)
	{
		if(newkeys & KEY_YES && !(oldkeys & KEY_YES))
		{
			new sel = FindNextValidPedNode(GetPlayerEditSelection(playerid), 1);

			if(sel != -1)
			{
				SetPlayerEditSelection(playerid, sel);

				new Float:x, Float:y, Float:z;
				GetPedNodePos(sel, x, y, z);

				SetPlayerPos(playerid, x, y, z + 1.0);
				SetPlayerInterior(playerid, GetPedNodeInterior(sel));
			}

			return 1;
		}

		if(newkeys & KEY_NO && !(oldkeys & KEY_NO))
		{
			new sel = FindNextValidPedNode(GetPlayerEditSelection(playerid), -1);

			if(sel != -1)
			{
				SetPlayerEditSelection(playerid, sel);

				new Float:x, Float:y, Float:z;
				GetPedNodePos(sel, x, y, z);

				SetPlayerPos(playerid, x, y, z + 1.0);
				SetPlayerInterior(playerid, GetPedNodeInterior(sel));
			}

			return 1;
		}
	}

	if(newkeys & KEY_YES && !(oldkeys & KEY_YES))
	{
		if(GetPlayerEditSelection(playerid) != -1) ShowDialog(playerid, DID_PN_NODE_OPT);

		return 1;
	}

	if(newkeys & KEY_NO && !(oldkeys & KEY_NO))
	{
		if(GetPlayerEditSelection(playerid) != -1) SetPlayerEditSelection(playerid, -1);

		return 1;
	}

	if(newkeys & KEY_ACTION && !(oldkeys & KEY_ACTION))
	{
		ShowDialog(playerid, DID_PN_MAIN);

		return 1;
	}

	return 1;
}

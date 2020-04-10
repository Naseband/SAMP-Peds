// Commands

CMD:pnedit(playerid, params[])
{
	ShowDialog(playerid, DID_PN_MAIN);

	return 1;
}

CMD:pntest(playerid, params[])
{
	new num;
	sscanf(params, "i", num);

	CreatePedestrians(num);

	return 1;
}

CMD:pntestn(playerid, params[])
{
	new num, avoid;
	sscanf(params, "iI(1)", num, avoid);

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	new nodeid = GetClosestPedNodeFromPoint(x, y, z, GetPlayerInterior(playerid));

	CreatePedestrians(num, nodeid, bool:avoid);

	return 1;
}

CMD:pnsave(playerid, params[])
{
	if(SavePedNodes(PNODE_FILE)) PNE_SendSuccess(playerid, "Ped Nodes successfully saved as \""PNODE_FILE"\".");
	else PNE_SendError(playerid, "Failed to save Ped Nodes as \""PNODE_FILE"\".");

	return 1;
}

CMD:aped(playerid, params[])
{
	new num, interval, peds_p_i;
	sscanf(params, "I(200)I(700)I(1)", num, interval, peds_p_i);

	if(interval < 100) interval = 100;
	else if(interval > 10000) interval = 10000;

	if(peds_p_i < 1) peds_p_i = 1;
	else if(peds_p_i > MAX_PEDS) peds_p_i = MAX_PEDS;

	SetPedestrianAutoSpawn(num, interval, peds_p_i);

	PNE_SendSuccess(playerid, "Ped Auto Spawn disabled.");

	return 1;
}

CMD:adjustsn(playerid, params[])
{
	for(new id = 0; id < MAX_PNODES; id ++) if(GetPedNodeType(id) == PNODE_TYPE_TELE)
	{
		if(CountPedNodeRemoteConnections(id) == 1)
		{
			SetPedNodeWidth(id, 0.0);
		}
	}

	return 1;
}

CMD:gohome(playerid, params[])
{
	for(new id = 0; id < MAX_PEDS; id ++) SetPedestrianState(id, PED_STATE_FIND_TELE);

	PNE_SendSuccess(playerid, "Sent all Peds home.");

	return 1;
}

CMD:pnzonet(playerid, params[])
{
	new text[120];

	for(new i = 0; i < NUM_PED_ZONES_X; i ++) for(new j = 0; j < NUM_PED_ZONES_Y; j ++)
	{
		new c = GetTeleZoneCount(i, j);

		if(c)
		{
			format(text, sizeof(text), "Zone: %d,%d count: %d", i, j, c);
			PNE_SendSuccess(playerid, text);
		}
	}
	new zx, zy;

	if(!GetRandomTeleZone(zx, zy)) return PNE_SendError(playerid, "No zone found");

	new c = GetTeleZoneCount(zx, zy);

	format(text, sizeof(text), "Rand Zone: %d,%d count: %d", zx, zy, c);
	PNE_SendSuccess(playerid, text);

	return 1;
}

CMD:pnmapzone(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	new MapZone:id = GetMapZoneAtPoint3D(x, y, z);

	if(id == INVALID_MAP_ZONE_ID) return PNE_SendError(playerid, "No Zone found");

	new text[100];
	GetMapZoneName(id, text);

	format(text, sizeof(text), "Map Zone: %d \"%s\"", _:id, text);

	PNE_SendSuccess(playerid, text);

	return 1;
}

CMD:pnupdzones(playerid, params[])
{
	UpdateAllPedNodeZones(true);

	return 1;
}

CMD:pnwanted(playerid, params[])
{
	SetPlayerWantedLevel(playerid, 0);

	return 1;
}

CMD:pncmds(playerid, params[])
{
	PNE_SendInfo(playerid, "Ped Node Editor by NaS - COMMANDS");

	PNE_SendInfo(playerid, " /pnedit - Open the Editor Main Menu to start editing");
	PNE_SendInfo(playerid, " /pnsave [filename (opt)] - Save Ped Node Net as [filename] or backup");
	PNE_SendInfo(playerid, " /pnupdzones - Updates all Zone Counts.");
	PNE_SendInfo(playerid, " /aped [total] [interval] [per interval] - Toggle Ped Auto Spawn.");
	PNE_SendInfo(playerid, " /gohome - Send all Peds home.");
	PNE_SendInfo(playerid, " /pntest [num] - Spawn [num] Test Peds anywhere");
	PNE_SendInfo(playerid, " /pntestn [num] - Spawn [num] Test Peds on the closest Ped Node");
	PNE_SendInfo(playerid, " /pnzonet - Tele Zone Debug info");
	PNE_SendInfo(playerid, " /pnmapzone - Shows current Map Zone ID");

	return 1;
}
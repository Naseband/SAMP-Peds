// Callback Hooks

public OnScriptInit()
{
	ResetPedMapZones();

	#if defined PGNG_OnScriptInit
	CallLocalFunction("PGNG_OnScriptInit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptInit
	#undef OnScriptInit
#else
	#define _ALS_OnScriptInit
#endif
#define OnScriptInit PGNG_OnScriptInit
forward OnScriptInit();


public OnScriptExit()
{
	#if PEDS_CREATE_GANG_ZONES == true

	DestroyTestGZs();

	#endif
	
	#if defined PGNG_OnScriptExit
	CallLocalFunction("PGNG_OnScriptExit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptExit
	#undef OnScriptExit
#else
	#define _ALS_OnScriptExit
#endif
#define OnScriptExit PGNG_OnScriptExit
forward OnScriptExit();



// Functions (Ped Map Zones)

stock SetPedMapZoneGang(zoneid, gangid)
{
	if(zoneid < 0 || zoneid >= GetMapZoneCount()) return 0;

	gPedMapZones[zoneid] = gangid;

	return 1;
}

stock GetPedMapZoneGang(zoneid)
{
	if(zoneid < 0 || zoneid >= sizeof(gPedMapZones)) return -1;

	return gPedMapZones[zoneid];
}

stock ResetPedMapZones()
{
	for(new i = 0; i < sizeof(gPedMapZones); i ++)
	{
		gPedMapZones[i] = -1;
	}

	return 1;
}

stock ApplyDefaultPedMapZones()
{
	for(new i = 0; i + 1 < sizeof(gDefaultPedMapZones); i += 2)
	{
		SetPedMapZoneGang(gDefaultPedMapZones[i], gDefaultPedMapZones[i + 1]);
	}

	#if PEDS_CREATE_GANG_ZONES == true

	CreateTestGZs();

	#endif

	return 1;
}

#if PEDS_CREATE_GANG_ZONES == true

stock CreateTestGZs()
{
	new Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz, gang, color;

	for(new i = 0; i < MAX_MAP_ZONES; i ++) if((gang = GetPedMapZoneGang(i)) != -1)
	{
		GetPedGangColor(gang, color);

		new start;

		while((start = GetMapZoneAreaPos(MapZone:i, minx, miny, minz, maxx, maxy, maxz, start)) != -1)
		{
			for(new gz = 0; gz < sizeof(gTestGZID); gz ++) if(gTestGZID[gz] == -1)
			{
				gTestGZID[gz] = GangZoneCreate(minx, miny, maxx, maxy);
				gTestGZColor[gz] = color;

				break;
			}

			start ++;
		}
	}
}

stock ShowTestGZs(playerid)
{
	for(new gz = 0; gz < sizeof(gTestGZID); gz ++) if(gTestGZID[gz] != -1)
	{
		GangZoneShowForPlayer(playerid, gTestGZID[gz], gTestGZColor[gz] - 0x70);
	}

	return 1;
}

stock DestroyTestGZs()
{
	for(new g = 0; g < sizeof(gTestGZID); g ++) if(gTestGZID[g] != -1)
	{
		GangZoneDestroy(gTestGZID[g]);
		gTestGZID[g] = -1;
	}
}

#endif

// Functions (Ped Gangs)

static stock _FindPedGangInternalID(gangid)
{
	for(new id = 0; id < MAX_PGANGS; id ++) if(gPedGangs[id][pgID] == gangid) return id;

	return -1;
}

stock GetPedGangName(id, name[], size = sizeof(name))
{
	new id_i = _FindPedGangInternalID(id);

	if(id_i == -1) return 0;

	format(name, size, gPedGangs[id_i][pgName]);

	return 1;
}

stock GetPedGangColor(id, &color)
{
	new id_i = _FindPedGangInternalID(id);

	if(id_i == -1) return 0;

	color = gPedGangs[id_i][pgColor];

	return 1;
}
// Callback Hooks

public OnScriptInit()
{
	Iter_Clear(Pedestrian);

	gCopRadarTimerID = SetTimer("CopTimer", 500, 1);

	for(new i = 0; i < MAX_PLAYERS; i ++) gNPCToPedID[i] = -1;

	#if defined PPED_OnScriptInit
	CallLocalFunction("PPED_OnScriptInit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptInit
	#undef OnScriptInit
#else
	#define _ALS_OnScriptInit
#endif
#define OnScriptInit PPED_OnScriptInit
forward OnScriptInit();


public OnScriptExit()
{
	DestroyAllPedestrians(true);
	SetPedestrianAutoSpawn(0);

	if(gCopRadarTimerID != -1) KillTimer(gCopRadarTimerID);
	gCopRadarTimerID = -1;
	
	#if defined PPED_OnScriptExit
	CallLocalFunction("PPED_OnScriptExit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptExit
	#undef OnScriptExit
#else
	#define _ALS_OnScriptExit
#endif
#define OnScriptExit PPED_OnScriptExit
forward OnScriptExit();


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	//SetPedestrianFleeIDNear(50.0, GetPlayerInterior(playerid), PED_FLEE_PLAYER, playerid, x, y, z);

	new interior = GetPlayerInterior(playerid);

	foreach(new id : Pedestrian) if(GetPedestrianState(id) != PED_STATE_NONE && GetPedestrianInterior(id) == interior)
	{
		switch(GetPedestrianGroupID(id))
		{
			case SKIN_GROUP_GANG:
			{
				// TDB: Aggro enemy gangs
			}
			case SKIN_GROUP_CRIMINAL:
			{
				// TBD: Aggro if tough and has weapon
			}
			case SKIN_GROUP_COP:
			{
				if(IsPlayerInRangeOfPoint(gPedestrians[id][pedID], 60.0, x, y, z)) RaisePlayerWantedLevel(playerid, 1);
			}
			default:
			{
				if(IsPlayerInRangeOfPoint(gPedestrians[id][pedID], 75.0, x, y, z)) SetPedestrianFleeID(id, PED_FLEE_PLAYER, playerid, .dist = 60.0);
			}
		}
	}

	#if defined PPED_OnPlayerWeaponShot
	CallLocalFunction("PPED_OnPlayerWeaponShot", "iiiifff", playerid, weaponid, hittype, hitid, fX, fY, fZ);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot PPED_OnPlayerWeaponShot
forward OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);


public FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart)
{
	new pedid = GetPedestrianIDFromNPC(npcid);

	if(pedid != -1 && IsPlayerConnected(issuerid) && !IsPlayerNPC(issuerid))
	{
		new weapon_type = GetWeaponType(weaponid);

		switch(GetPedestrianGroupID(pedid))
		{
			case SKIN_GROUP_COP:
			{
				switch(weapon_type)
				{
					case WEAPON_TYPE_MELEE: RaisePlayerWantedLevel(issuerid, 1);
					default: RaisePlayerWantedLevel(issuerid, 2);
				}
			}
			case SKIN_GROUP_GANG:
			{
				// TBD: Aggro all nearby gang members with whatever guns they have >:D
			}
			default:
			{
				switch(weapon_type)
				{
					case WEAPON_TYPE_MELEE:
					{
						if(GetSkinFOF(GetPedestrianSkinID(pedid)) == SKIN_FOF_TOUGH)
						{
							// TDB: Aggro
						}
						else
						{
							SetPedestrianFleeID(pedid, PED_FLEE_PLAYER, issuerid);
						}
					}
					default:
					{
						SetPedestrianFleeID(pedid, PED_FLEE_PLAYER, issuerid);
					}
				}
			}
		}
	}

	#if defined PPED_FCNPC_OnTakeDamage
	CallLocalFunction("PPED_FCNPC_OnTakeDamage", "iifii", npcid, issuerid, amount, weaponid, bodypart);
	#endif

	return 1;
}

#if defined _ALS_FCNPC_OnTakeDamage
	#undef FCNPC_OnTakeDamage
#else
	#define _ALS_FCNPC_OnTakeDamage
#endif
#define FCNPC_OnTakeDamage PPED_FCNPC_OnTakeDamage
forward FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart);


public FCNPC_OnReachDestination(npcid)
{
	new pedid = GetPedestrianIDFromNPC(npcid);

	if(pedid != -1) MovePedestrian(pedid);

	#if defined PPED_FCNPC_OnReachDestination
	CallLocalFunction("PPED_FCNPC_OnReachDestination", "i", npcid);
	#endif

	return 1;
}

#if defined _ALS_FCNPC_OnReachDestination
	#undef FCNPC_OnReachDestination
#else
	#define _ALS_FCNPC_OnReachDestination
#endif
#define FCNPC_OnReachDestination PPED_FCNPC_OnReachDestination
forward FCNPC_OnReachDestination(npcid);


public FCNPC_OnDeath(npcid, killerid, reason)
{
	new pedid = GetPedestrianIDFromNPC(npcid);

	if(pedid != -1)
	{
		SetPedestrianState(pedid, PED_STATE_DEAD);
		gPedestrians[pedid][pedTick] = gettime();

		if(Iter_Count(Pedestrian) > GetPedestrianAutoSpawnCount())
		{
			if(IsPedestrianStreamedInForAnyone(pedid))
			{
				DestroyPedestrian(pedid, 15000);
			}
			else
			{
				DestroyPedestrian(pedid);	
			}
		}
		else
		{
			ResetPedestrian(pedid, 15000, true);
		}

		if(IsPlayerConnected(killerid) && !IsPlayerNPC(killerid))
		{
			switch(GetPedestrianGroupID(pedid))
			{
				case SKIN_GROUP_COP:
				{
					RaisePlayerWantedLevel(killerid, 3);
				}
				case SKIN_GROUP_GANG:
				{
					// TBD: Aggro all nearby gang members with whatever guns they have >:D
				}
			}
		}
	}

	#if defined PPED_FCNPC_OnDeath
	CallLocalFunction("PPED_FCNPC_OnDeath", "iii", npcid, killerid, reason);
	#endif

	return 1;
}

#if defined _ALS_FCNPC_OnDeath
	#undef FCNPC_OnDeath
#else
	#define _ALS_FCNPC_OnDeath
#endif
#define FCNPC_OnDeath PPED_FCNPC_OnDeath
forward FCNPC_OnDeath(npcid, killerid, reason);

// Functions

stock CreatePedestrians(num, curnode = -1, bool:avoid_players = false)
{
	for(new n = 0; n < num; n ++)
	{
		new id = Iter_Free(Pedestrian);

		if(id == ITER_NONE) break;

		if(curnode == -1)
		{
			do
			{
				curnode = FindSpawnNode();
			}
			while(curnode == -1 || (avoid_players && IsAnyPlayerNearPedNode(30.0, curnode)));
		}

		if(curnode == -1) continue;

		new name[MAX_PLAYER_NAME];
		format(name, sizeof(name), POOL_NPC_NAME_FORMAT, gPedestrianNPCID ++);

		new npcid = FCNPC_Create(name);

		if(!FCNPC_IsValid(npcid)) continue;

		gPedestrians[id][pedID] = npcid;
		gNPCToPedID[npcid] = id;
		gPedestrians[id][pedExists] = true;
		gPedestrians[id][pedDestroy] = false;

		Iter_Add(Pedestrian, id);

		ResetPedestrian(id, 10);
	}
}

stock DestroyPedestrian(id, delay = 0, bool:force = false)
{
	if(!IsValidPedestrian(id)) return 0;

	if(delay)
	{
		if(!force && gPedestrians[id][pedDestroy]) return 0;

		gPedestrians[id][pedDestroy] = true;
		SetTimerEx("@DestroyPedestrian", delay, 0, "i", id);

		return 1;
	}

	gPedestrians[id][pedExists] = false;

	if(FCNPC_IsValid(gPedestrians[id][pedID]))
	{
		FCNPC_Stop(gPedestrians[id][pedID]);
		FCNPC_Destroy(gPedestrians[id][pedID]);
		gNPCToPedID[gPedestrians[id][pedID]] = -1;
		gPedestrians[id][pedDestroy] = false;
	}
	gPedestrians[id][pedID] = -1;

	Iter_Remove(Pedestrian, id);

	return 1;
}

stock ResetPedestrian(id, delay = 0, avoid_players = true)
{
	if(!IsValidPedestrian(id)) return 0;

	if(delay)
	{
		SetTimerEx("@ResetPedestrian", delay, 0, "i", id);

		return 1;
	}

	new curnode = -1;

	do
	{
		curnode = FindSpawnNode();
	}
	while(curnode == -1 || (avoid_players && IsAnyPlayerNearPedNode(30.0, curnode)));

	new Float:x, Float:y, Float:z, interior = GetPedNodeInterior(curnode);
	GetPedNodePos(curnode, x, y, z);

	new skinid = GetPedSkinForPoint2D(x, y, interior),
		blipcolor = GetSkinBlipColor(skinid),
		npcid = gPedestrians[id][pedID];

	SetPlayerColor(npcid, blipcolor != 0 ? blipcolor - 0x77 : blipcolor);

	gPedestrians[id][pedState] = PED_STATE_ROAM;
	gPedestrians[id][pedInterior] = interior;
	gPedestrians[id][pedTick] = gettime();
	gPedestrians[id][pedTTL] = PNE_random2(300, 900);

	gPedestrians[id][pedSkinID] = skinid;
	gPedestrians[id][pedGroupID] = GetSkinGroup(skinid);
	gPedestrians[id][pedGangID] = GetSkinGang(skinid);
	gPedestrians[id][pedServiceID] = GetSkinService(skinid);
	gPedestrians[id][pedSpeedMul] = PNE_frandom2(0.8, 1.05);

	gPedestrians[id][pedCurNode] = curnode;
	gPedestrians[id][pedLastNode] = curnode;

	if(FCNPC_IsSpawned(npcid)) FCNPC_Respawn(npcid);
	else FCNPC_Spawn(npcid, skinid, x, y, z + 1.0);
	FCNPC_SetSkin(npcid, skinid);
	FCNPC_SetPosition(npcid, x, y, z + 1.0);
	FCNPC_SetInterior(npcid, interior);

	FCNPC_SetHealth(npcid, MAX_PED_BASE_HEALTH * GetSkinStrength(skinid));
	FCNPC_SetArmour(npcid, 0);

	switch(gPedestrians[id][pedGroupID])
	{
		case SKIN_GROUP_COP:	SetPedestrianWeaponData(id, {WEAPON_NITESTICK, WEAPON_COLT45});
		case SKIN_GROUP_GANG:	SetPedestrianWeaponData(id, {WEAPON_KNIFE, WEAPON_COLT45, WEAPON_UZI}, true);
		default: 				SetPedestrianWeaponData(id, {0});
	}

	MovePedestrian(id);

	return 1;
}

stock DestroyAllPedestrians(bool:force = false)
{
	for(new id = 0; id < MAX_PEDS; id ++) DestroyPedestrian(id, 0, force);

	return 1;
}

stock IsValidPedestrian(id)
{
	if(id < 0 || id >= MAX_PEDS) return 0;

	return _:gPedestrians[id][pedExists];
}

stock GetPedestrianIDFromNPC(npcid)
{
	if(!FCNPC_IsValid(npcid)) return -1;

	if(gNPCToPedID[npcid] != -1) return gNPCToPedID[npcid];
	else
	{
		foreach(new id : Pedestrian)
		{
			if(gPedestrians[id][pedID] == npcid) return id;
		}
	}

	return -1;
}

stock GetPedestrianState(id)
{
	if(!IsValidPedestrian(id)) return PED_STATE_NONE;

	return gPedestrians[id][pedState];
}

stock SetPedestrianState(id, pedstate)
{
	if(!IsValidPedestrian(id)) return 0;

	gPedestrians[id][pedState] = pedstate;

	return 1;
}

stock GetPedestrianInterior(id)
{
	if(!IsValidPedestrian(id)) return 0;

	return gPedestrians[id][pedInterior];
}

stock GetPedestrianSkinID(id)
{
	if(!IsValidPedestrian(id)) return -1;

	return gPedestrians[id][pedSkinID];
}

stock GetPedestrianGroupID(id)
{
	if(!IsValidPedestrian(id)) return -1;

	return gPedestrians[id][pedGroupID];
}

stock GetPedestrianGangID(id)
{
	if(!IsValidPedestrian(id)) return -1;

	return gPedestrians[id][pedGangID];
}

stock GetPedestrianPos(id, &Float:x, &Float:y, &Float:z)
{
	if(!IsValidPedestrian(id)) return 0;

	return FCNPC_GetPosition(gPedestrians[id][pedID], x, y, z);
}

stock GetPedestrianSpeedMul(id, &Float:speed_mul)
{
	if(!IsValidPedestrian(id)) return 0;

	speed_mul = gPedestrians[id][pedSpeedMul];

	return 1;
}

stock SetPedestrianSpeedMul(id, Float:speed_mul)
{
	if(!IsValidPedestrian(id)) return 0;

	gPedestrians[id][pedSpeedMul] = speed_mul;

	return 1;
}

stock ApplyAnimationToPedestrian(id, const animation[], Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1)
{
	if(!IsValidPedestrian(id)) return 0;

	new npcid = gPedestrians[id][pedID];

	if(FCNPC_IsMoving(npcid)) FCNPC_Stop(npcid);

	new animlib[32], animname[32];

	if(sscanf(animation, "p<:>s[32]s[32]", animlib, animname) || !strlen(animlib) || !strlen(animname)) return 0;

	ApplyAnimation(npcid, animlib, animname, fDelta, loop, lockx, locky, freeze, time, 1);

	return 1;
}

stock GetPedestrianFleeID(id)
{
	if(!IsValidPedestrian(id)) return 0;

	return gPedestrians[id][pedFleeID];
}

stock SetPedestrianFleeID(id, fleetype, fleeid = -1, Float:flee_x = 0.0, Float:flee_y = 0.0, Float:flee_z = 0.0, Float:dist = 70.0)
{
	if(!IsValidPedestrian(id)) return 0;

	new oldstate = GetPedestrianState(id);

	if(oldstate == PED_STATE_NONE) return 0;

	gPedestrians[id][pedFleeType] = fleetype;
	gPedestrians[id][pedFleeID] = fleeid;
	gPedestrians[id][pedFleeX] = flee_x;
	gPedestrians[id][pedFleeY] = flee_y;
	gPedestrians[id][pedFleeZ] = flee_z;
	gPedestrians[id][pedFleeDistance] = dist;
	gPedestrians[id][pedFleeTick] = gettime();

	SetPedestrianState(id, PED_STATE_FLEE);

	if(oldstate != PED_STATE_FLEE) MovePedestrian(id, false);

	return 1;
}

stock SetPedestrianFleeIDNear(Float:range, interior, fleetype, fleeid = -1, Float:flee_x = 0.0, Float:flee_y = 0.0, Float:flee_z = 0.0, Float:dist = 70.0)
{
	foreach(new id : Pedestrian) if(GetPedestrianState(id) != PED_STATE_NONE && GetPedestrianInterior(id) == interior)
	{
		if(IsPlayerInRangeOfPoint(gPedestrians[id][pedID], range, flee_x, flee_y, flee_z))
		{
			SetPedestrianFleeID(id, fleetype, fleeid, flee_x, flee_y, flee_z, dist);
		}
	}

	return 1;
}

stock SetPedestrianFleeType(id, fleetype)
{
	if(!IsValidPedestrian(id)) return 0;

	gPedestrians[id][pedFleeType] = fleetype;

	if(fleetype == PED_FLEE_PANIC) ApplyAnimationToPedestrian(id, "PED:cower", 4.1, 1, 1, 1, .freeze = 1, .time = 1); // Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1

	return 1;
}

stock GetPedestrianFleeType(id)
{
	if(!IsValidPedestrian(id)) return -1;

	return gPedestrians[id][pedFleeType];
}

stock SetPedestrianTarget(id, targettype, targetid, bool:prefermelee = false)
{
	if(!IsValidPedestrian(id)) return 0;

	gPedestrians[id][pedTargetType] = targettype;
	gPedestrians[id][pedTargetID] = targetid;
	gPedestrians[id][pedPreferMelee] = prefermelee;

	gPedestrians[id][pedTargetTick] = gettime();

	gPedestrians[id][pedAttackState] = PED_ATT_STATE_FIND_LOS;

	SetPedestrianState(id, PED_STATE_ATTACK);

	new weapons[MAX_PED_WEAPONS], count;

	for(new i = 0; i < MAX_PED_WEAPONS; i ++) if(gPedestrians[id][pedWeapons][i] != -1)
	{
		weapons[count ++] = gPedestrians[id][pedWeapons][i];
	}

	if(count)
	{
		if(prefermelee)
		{
			new bool:found;

			for(new i = 0; i < count; i ++)
			{
				if(GetWeaponType(weapons[i]) == WEAPON_TYPE_MELEE)
				{
					gPedestrians[id][pedAttackWeapon] = weapons[i];
					found = true;
					break;
				}
			}

			if(!found) gPedestrians[id][pedAttackWeapon] = 0;
		}
		else
		{
			new bool:found;

			for(new i = 0; i < count; i ++)
			{
				if(GetWeaponType(weapons[i]) != WEAPON_TYPE_MELEE)
				{
					gPedestrians[id][pedAttackWeapon] = weapons[i];
					found = true;
					break;
				}
			}

			if(!found)
			{
				gPedestrians[id][pedAttackWeapon] = 0;
				gPedestrians[id][pedPreferMelee] = true;
			}
		}

		FCNPC_SetWeapon(gPedestrians[id][pedID], gPedestrians[id][pedAttackWeapon]);
	}
	else
	{
		gPedestrians[id][pedPreferMelee] = true;
		gPedestrians[id][pedAttackWeapon] = 0;

		FCNPC_SetWeapon(gPedestrians[id][pedID], 0);
	}

	return 1;
}

stock SetPedestrianWeaponData(id, const data[], bool:apply = false, size = sizeof(data))
{
	new c = 0;

	for(new i = 0; i < MAX_PED_WEAPONS; i ++)
	{
		if(i < size)
		{
			gPedestrians[id][pedWeapons][i] = data[i];

			c ++;
		}
		else
		{
			gPedestrians[id][pedWeapons][i] = -1;
		}
	}

	if(c && apply) FCNPC_SetWeapon(gPedestrians[id][pedID], data[random(c)]);
	else FCNPC_SetWeapon(gPedestrians[id][pedID], 0);

	return 1;
}

stock IsPlayerInRangeOfPedestrian(playerid, Float:range, id)
{
	new Float:x, Float:y, Float:z;
	GetPedestrianPos(id, x, y, z);

	return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}

stock IsFCNPCInRangeOfPedestrian(npcid, Float:range, id)
{
	new Float:x, Float:y, Float:z;
	FCNPC_GetPosition(npcid, x, y, z);

	return IsPedestrianInRangeOfPoint(id, range, x, y, z);
}

stock IsVehicleInRangeOfPedestrian(vehicleid, Float:range, id)
{
	new Float:x, Float:y, Float:z;
	GetVehiclePos(vehicleid, x, y, z);

	return IsPedestrianInRangeOfPoint(id, range, x, y, z);
}

stock IsObjectInRangeOfPedestrian(objectid, Float:range, id)
{
	new Float:x, Float:y, Float:z;
	GetObjectPos(objectid, x, y, z);

	return IsPedestrianInRangeOfPoint(id, range, x, y, z);
}

stock IsDynObjectInRangeOfPedestrian(objectid, Float:range, id)
{
	new Float:x, Float:y, Float:z;
	GetDynamicObjectPos(objectid, x, y, z);

	return IsPedestrianInRangeOfPoint(id, range, x, y, z);
}

stock IsPedestrianInRangeOfPoint(id, Float:range, Float:x, Float:y, Float:z)
{
	new Float:pedx, Float:pedy, Float:pedz;
	GetPedestrianPos(id, pedx, pedy, pedz);

	return (VectorSize(pedx - x, pedy - y, pedz - z) < range);
}

stock IsPedestrianStreamedInForAnyone(id)
{
	if(!IsValidPedestrian(id)) return 0;

	return _:FCNPC_IsStreamedInForAnyone(gPedestrians[id][pedID]);
}

stock MovePedestrian(id, bool:progress = true)
{
	if(!IsValidPedestrian(id)) return 0;

	new curnode = gPedestrians[id][pedCurNode], pedstate = GetPedestrianState(id), oldnode = gPedestrians[id][pedLastNode];

	if(pedstate == PED_STATE_FIND_TELE)
	{
		if(GetPedNodeType(curnode) == PNODE_TYPE_TELE && CountPedNodeConnections(curnode) == 1)
		{
			if(Iter_Count(Pedestrian) > GetPedestrianAutoSpawnCount())
			{
				if(IsPedestrianStreamedInForAnyone(id))
				{
					ApplyAnimationToPedestrian(id, "CRIB:CRIB_Use_Switch", 4.1, 0, 1, 1, 1, 1400); // Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1

					DestroyPedestrian(id, 1400);
				}
				else
				{
					DestroyPedestrian(id);	
				}
			}
			else
			{
				ResetPedestrian(id, 1400, true);
			}

			return 1;
		}
	}
	else if(pedstate == PED_STATE_FLEE)
	{
		new fleeid = gPedestrians[id][pedFleeID];

		switch(gPedestrians[id][pedFleeType])
		{
			case PED_FLEE_NPC, PED_FLEE_PLAYER:
			{
				if(IsPlayerConnected(fleeid))
				{
					if(FCNPC_IsValid(fleeid))
					{
						if(IsFCNPCInRangeOfPedestrian(fleeid, gPedestrians[id][pedFleeDistance], id) && FCNPC_GetInterior(fleeid) == GetPedestrianInterior(id))
						{
							FCNPC_GetPosition(fleeid, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ]);
							gPedestrians[id][pedFleeTick] = gettime();
						}
					}
					else
					{
						if(IsPlayerInRangeOfPedestrian(fleeid, gPedestrians[id][pedFleeDistance], id) && GetPlayerInterior(fleeid) == GetPedestrianInterior(id))
						{
							GetPlayerPos(fleeid, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ]);
							gPedestrians[id][pedFleeTick] = gettime();
						}
					}
				}
				else gPedestrians[id][pedFleeID] = -1;
			}
			case PED_FLEE_VEHICLE:
			{
				if(IsValidVehicle(fleeid))
				{
					if(IsVehicleInRangeOfPedestrian(fleeid, gPedestrians[id][pedFleeDistance], id))
					{
						GetVehiclePos(fleeid, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ]);
						gPedestrians[id][pedFleeTick] = gettime();
					}
				}
				else gPedestrians[id][pedFleeID] = -1;
			}
			case PED_FLEE_OBJECT:
			{
				if(IsValidObject(fleeid))
				{
					if(IsObjectInRangeOfPedestrian(fleeid, gPedestrians[id][pedFleeDistance], id))
					{
						GetObjectPos(fleeid, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ]);
						gPedestrians[id][pedFleeTick] = gettime();
					}
				}
				else gPedestrians[id][pedFleeID] = -1;
			}
			case PED_FLEE_DYN_OBJECT:
			{
				if(IsValidDynamicObject(fleeid))
				{
					if(IsDynObjectInRangeOfPedestrian(fleeid, gPedestrians[id][pedFleeDistance], id) && Streamer_IsInArrayData(STREAMER_TYPE_OBJECT, fleeid, E_STREAMER_INTERIOR_ID, GetPedestrianInterior(id)))
					{
						GetDynamicObjectPos(fleeid, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ]);
						gPedestrians[id][pedFleeTick] = gettime();
					}
				}
				else gPedestrians[id][pedFleeID] = -1;
			}
			case PED_FLEE_PANIC:
			{
				return 1;
			}
		}

		if(gettime() - gPedestrians[id][pedFleeTick] > 45) SetPedestrianState(id, PED_STATE_ROAM);
	}

	new bool:panic;

	new nodeid = FindNextNode(curnode, gPedestrians[id][pedLastNode], pedstate, gPedestrians[id][pedFleeX], gPedestrians[id][pedFleeY], gPedestrians[id][pedFleeZ], panic);

	if(panic)
	{
		SetPedestrianFleeType(id, PED_FLEE_PANIC);

		return 1;
	}

	if(nodeid == -1) return 0;

	if(progress || nodeid == oldnode)
	{
		gPedestrians[id][pedLastNode] = gPedestrians[id][pedCurNode];
		gPedestrians[id][pedCurNode] = nodeid;

		curnode = nodeid;
	}

	if(curnode != -1)
	{
		new Float:x, Float:y, Float:z, Float:angle;
		GetPedNodePos(curnode, x, y, z);

		if(GetWorldAngleBetween2PedNodes(gPedestrians[id][pedLastNode], curnode, angle))
		{
			new Float:w;
			GetPedNodeWidth(curnode, w);

			x += w/2.0 * floatsin(-angle + 90.0, degrees);
			y += w/2.0 * floatcos(-angle + 90.0, degrees);
		}

		new Float:speed_mul;
		GetPedestrianSpeedMul(id, speed_mul);

		switch(GetPedestrianState(id))
		{
			case PED_STATE_ROAM, PED_STATE_FIND_TELE: FCNPC_GoTo(gPedestrians[id][pedID], x, y, z + 1.0, FCNPC_MOVE_TYPE_WALK, speed_mul * FCNPC_MOVE_SPEED_WALK, FCNPC_MOVE_MODE_NONE, FCNPC_MOVE_PATHFINDING_NONE, 0.0, true, 0.0, 0);
			case PED_STATE_FLEE: FCNPC_GoTo(gPedestrians[id][pedID], x, y, z + 1.0, FCNPC_MOVE_TYPE_SPRINT, speed_mul * FCNPC_MOVE_SPEED_SPRINT, FCNPC_MOVE_MODE_NONE, FCNPC_MOVE_PATHFINDING_NONE, 0.0, true, 0.0, 0);
		}
	}

	if(pedstate == PED_STATE_ROAM && gettime() - gPedestrians[id][pedTick] > gPedestrians[id][pedTTL])
	{
		SetPedestrianState(id, PED_STATE_FIND_TELE);
		pedstate = PED_STATE_FIND_TELE;
	}

	#if PED_DEBUG_BUBBLES == true

	new text[34];
	format(text, sizeof(text), "S=%d FT=%d FID=%d GRP=%d GNG=%d", pedstate, GetPedestrianFleeType(id), GetPedestrianFleeID(id), GetPedestrianGroupID(id), GetPedestrianGangID(id));
	SetPlayerChatBubble(gPedestrians[id][pedID], text, 0xFFFFFFFE, 30.0, 5000);

	#endif

	return 1;
}

stock FindNextNode(nodeid, lastnode = -1, pedstate = PED_STATE_ROAM, Float:flee_x = 0.0, Float:flee_y = 0.0, Float:flee_z = 0.0, &bool:panic = false)
{
	if(!IsValidPedNode(nodeid)) return -1;

	new options[MAX_PNODE_CONNECTIONS], count, tmpnode, curtype = GetPedNodeType(nodeid);

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) if((tmpnode = GetPedNodeConnectionAt(nodeid, i)) != -1)
	{
		switch(GetPedNodeType(tmpnode))
		{
			case PNODE_TYPE_WALK:
			{
				options[count ++] = tmpnode;
			}
			case PNODE_TYPE_CROSS:
			{
				options[count ++] = tmpnode;
			}
			case PNODE_TYPE_FLEE:
			{
				if(curtype == PNODE_TYPE_FLEE || pedstate == PED_STATE_FLEE)
				{
					options[count ++] = tmpnode;
				}

				// Only if scared
			}
			case PNODE_TYPE_JUMP:
			{
				// TBD
			}
			case PNODE_TYPE_TELE:
			{
				if(curtype == PNODE_TYPE_TELE || pedstate == PED_STATE_FIND_TELE) options[count ++] = tmpnode;

				// TBD
			}
		}
	}

	if(count == 0) return lastnode;
	else if(count == 1) return options[0];

	new nextnode = -1;

	switch(pedstate)
	{
		case PED_STATE_ROAM:
		{
			do
			{
				nextnode = options[random(count)];
			}
			while(lastnode == nextnode);
		}
		case PED_STATE_FIND_TELE:
		{
			for(new i = 0; i < count; i ++) if(options[i] != lastnode && GetPedNodeType(options[i]) == PNODE_TYPE_TELE)
			{
				nextnode = options[i];
				break;
			}

			if(nextnode == -1)
			{
				do
				{
					nextnode = options[random(count)];
				}
				while(lastnode == nextnode);
			}
		}
		case PED_STATE_FLEE:
		{
			new Float:threatangle, Float:targetangle, Float:tmpangle, Float:angledif, Float:threatdist,
				Float:x1, Float:y1, Float:z1,
				Float:x2, Float:y2, Float:z2,
				Float:vx1, Float:vy1, Float:vx2, Float:vy2;

			GetPedNodePos(nodeid, x1, y1, z1);

			vx1 = x1 - flee_x;
			vy1 = y1 - flee_y;

			PNE_GetRZFromVectorXY(vx1, vy1, threatangle);

			for(new i = 0; i < count; i ++)
			{
				GetPedNodePos(options[i], x2, y2, z2);

				vx2 = x2 - x1;
				vy2 = y2 - y1;

				PNE_GetRZFromVectorXY(vx2, vy2, targetangle);

				tmpangle = floatabs(GetAngleDif(threatangle, targetangle));

				if(nextnode == -1 || tmpangle < angledif)
				{
					nextnode = options[i];
					angledif = tmpangle;
					threatdist = VectorSize(x1 - flee_x, y1 - flee_y, z1 -  flee_z);
				}
			}

			if(nextnode == -1 || (angledif > 110.0 && threatdist < 35.0))
			{
				panic = true;
			}

			if(nextnode == -1)
			{
				nextnode = options[random(count)];
			}
		}
		case PED_STATE_ATTACK:
		{
			// TBD
		}
	}

	return nextnode;
}

stock SetPedestrianAutoSpawn(count, interval = 1000, peds_per_interval = 1)
{
	if(count < 0) return 0;

	if(count > MAX_PEDS) count = MAX_PEDS;

	if(count)
	{
		gAutoSpawnPeds = count;
		gAutoSpawnPedsAmount = peds_per_interval;

		if(gPedSpawnTimerID != -1) KillTimer(gPedSpawnTimerID);

		gPedSpawnTimerID = SetTimer("PedestrianSpawnTimer", interval, 1);
	}
	else
	{
		gAutoSpawnPeds = false;

		if(gPedSpawnTimerID != -1) KillTimer(gPedSpawnTimerID);
		gPedSpawnTimerID = -1;
	}

	return 1;
}

stock GetPedestrianAutoSpawnCount()
{
	return gAutoSpawnPeds;
}

public PedestrianSpawnTimer()
{
	if(!gAutoSpawnPeds) return 0;

	new count = Iter_Count(Pedestrian);

	if(count < gAutoSpawnPeds)
	{
		/*new num = 1 + ((MAX_AUTO_PEDS - count) / 50);

		if(count + num > MAX_AUTO_PEDS) num = MAX_AUTO_PEDS - count;*/

		CreatePedestrians(gAutoSpawnPedsAmount, -1, true);

		//printf("Connected %d", num);
	}

	return 1;
}

public CopTimer()
{
	gCopRadarState = !gCopRadarState;

	foreach(new playerid : Player)
	{
		new count;

		foreach(new pedid : Pedestrian)
		{
			if(GetPedestrianState(pedid) != PED_STATE_DEAD && GetPedestrianGroupID(pedid) == SKIN_GROUP_COP && GetPlayerInterior(playerid) == GetPedestrianInterior(pedid) && IsPlayerStreamedIn(gPedestrians[pedid][pedID], playerid))
			{
				if(GetPlayerWantedLevel(playerid) > 0)
				{
					new bool:radarstate = gCopRadarState;

					if(count ++ % 2 == 0) radarstate = !radarstate;

					SetPlayerMarkerForPlayer(playerid, gPedestrians[pedid][pedID], radarstate ? COP_COLOR_A : COP_COLOR_B);
				}
				else SetPlayerMarkerForPlayer(playerid, gPedestrians[pedid][pedID], 0x00000000);
			}
		}
	}
}
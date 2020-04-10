stock CA_GetClosestZ(Float:x, Float:y, Float:z, Float:min_dist, Float:max_dist, &Float:ret_z)
{
	new Float:waste, r1, r2, Float:z_up, Float:z_down;

	r1 = CA_RayCastLine(x, y, z + min_dist, x, y, z + max_dist, waste, waste, z_up);
	r2 = CA_RayCastLine(x, y, z - min_dist, x, y, z - max_dist, waste, waste, z_down);

	if(r1 == 0 && r2 == 0)
	{
		ret_z = z;
		return 1;
	}

	if(floatabs(z_up - z) < floatabs(z_down - z)) ret_z = z_up;
	else ret_z = z_down;

	return 1;
}

stock PNE_GetRZFromVectorXY(Float:vx, Float:vy, &Float:rz)
{
	if(vx == 0.0 && vy == 0.0) return 0;

	rz = atan2(vy, vx) - 90.0;

	return 1;
}

stock PNE_GetRXFromVectorZ(Float:vz, &Float:rx)
{
	rx = -(acos(vz) - 90.0);

	return 1;
}

stock Float:GetAngleDif(Float:firstAngle, Float:secondAngle) // Ranging from -180 to 180 (directional)
{
	new Float:difference = secondAngle - firstAngle;
	while(difference < -180.0) difference += 360.0;
	while(difference > 180.0) difference -= 360.0;
	return difference;
}

stock PNE_SendSuccess(playerid, const msg[], ret = 1)
{
	SendClientMessage(playerid, 0x33FF00FF, msg);

	return ret;
}

stock PNE_SendError(playerid, const msg[], ret = 1)
{
	SendClientMessage(playerid, 0xFF5511FF, msg);

	return ret;
}

stock PNE_SendInfo(playerid, const msg[], ret = 1)
{
	SendClientMessage(playerid, 0xDDFF99FF, msg);

	return ret;
}

stock IsValidVehicle(id) return (GetVehicleModel(id) != 0);

PNE_random2(min, max)
{
	return (min + random(max - min));
}

Float:PNE_frandom(Float:max)
{
	new r = random(floatround(max * 20.0));

	return (float(r) / 20.0);
}

Float:PNE_frandom2(Float:min, Float:max)
{
	return (min + PNE_frandom(max - min));
}

stock CountPlayersNearPoint(Float:range, Float:x, Float:y, Float:z, interior = 0)
{
	new count;

	foreach(new playerid : Player)
	{
		if(GetPlayerInterior(playerid) != interior) continue;
		new pstate = GetPlayerState(playerid);

		if(pstate != PLAYER_STATE_ONFOOT && pstate != PLAYER_STATE_PASSENGER && pstate != PLAYER_STATE_DRIVER) continue;
		
		if(IsPlayerInRangeOfPoint(playerid, range, x, y, z)) count ++;
	}

	return count;
}

stock IsAnyPlayerNearPoint(Float:range, Float:x, Float:y, Float:z, interior = 0)
{
	foreach(new playerid : Player)
	{
		if(GetPlayerInterior(playerid) != interior) continue;

		new pstate = GetPlayerState(playerid);

		if(pstate != PLAYER_STATE_ONFOOT && pstate != PLAYER_STATE_PASSENGER && pstate != PLAYER_STATE_DRIVER) continue;
		
		if(IsPlayerInRangeOfPoint(playerid, range, x, y, z)) return 1;
	}

	return 0;
}

stock GetWeaponType(weaponid)
{
	switch(weaponid)
	{
		case 0, WEAPON_BRASSKNUCKLE, WEAPON_NITESTICK, WEAPON_KNIFE, WEAPON_BAT, WEAPON_SHOVEL, WEAPON_POOLSTICK, WEAPON_KATANA,
			 WEAPON_CHAINSAW, WEAPON_DILDO, WEAPON_DILDO2, WEAPON_VIBRATOR, WEAPON_VIBRATOR2,
			 WEAPON_FLOWER, WEAPON_CANE:
			{
				return WEAPON_TYPE_MELEE;
			}
	}

	return WEAPON_TYPE_OTHER;
}

stock RaisePlayerWantedLevel(playerid, level)
{
	if(GetPlayerWantedLevel(playerid) < level) SetPlayerWantedLevel(playerid, level);

	return 1;
}
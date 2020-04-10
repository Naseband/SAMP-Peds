stock IsValidZone(x, y)
{
	return (x >= 0 && y >= 0 && x < NUM_PED_ZONES_X && y < NUM_PED_ZONES_Y);
}

stock GetZoneForPoint2D(Float:pos_x, Float:pos_y, &x, &y)
{
	new ret_x = floatround(NUM_PED_ZONES_X * ((pos_x - PEDS_MAP_MIN_X) / PEDS_MAP_SIZE_X), floatround_floor),
		ret_y = floatround(NUM_PED_ZONES_Y * ((pos_y - PEDS_MAP_MIN_Y) / PEDS_MAP_SIZE_Y), floatround_floor);

	if(!IsValidZone(ret_x, ret_y)) return 0;

	x = ret_x;
	y = ret_y;

	return 1;
}

// TELE

stock AddTeleZone(x, y)
{
	if(!IsValidZone(x, y)) return 0;

	gZoneCount_Tele[x][y] ++;

	return 1;
}

stock RemoveTeleZone(x, y)
{
	if(!IsValidZone(x, y)) return 0;

	gZoneCount_Tele[x][y] --;

	return 1;
}

stock GetTeleZoneCount(x, y)
{
	if(!IsValidZone(x, y)) return 0;

	return gZoneCount_Tele[x][y];
}

stock ResetAllTeleZoneCounts()
{
	for(new x = 0; x < NUM_PED_ZONES_X; x ++) for(new y = 0; y < NUM_PED_ZONES_Y; y ++) ResetTeleZoneCount(x, y);
}

stock ResetTeleZoneCount(x, y)
{
	if(!IsValidZone(x, y)) return 0;

	gZoneCount_Tele[x][y] = 0;

	return 1;
}

stock GetRandomTeleZone(&zone_x, &zone_y)
{
	new list[NUM_PED_ZONES_X * NUM_PED_ZONES_Y], count;

	for(new x = 0; x < NUM_PED_ZONES_X; x ++) for(new y = 0; y < NUM_PED_ZONES_Y; y ++)
	{
		if(GetTeleZoneCount(x, y) == 0) continue;
	
		list[count ++] = x * NUM_PED_ZONES_X + y;
	}

	if(count == 0) return 0;

	new id = list[random(count)];

	zone_x = id / NUM_PED_ZONES_X;
	zone_y = id % NUM_PED_ZONES_Y;

	return 1;
}

stock PrintTeleZoneCounts()
{
	new text[500];

	for(new y = NUM_PED_ZONES_Y - 1; y >= 0; y --)
	{
		text[0] = EOS;

		for(new x = 0; x < NUM_PED_ZONES_X; x ++)
		{
			if(x == 0) format(text, sizeof(text), "%d,%d:%d", x, y, GetTeleZoneCount(x, y));
			else format(text, sizeof(text), "%s\t%d,%d:%d", text, x, y, GetTeleZoneCount(x, y));
		}

		print(text);
	}
}
// Callback Hooks

public OnScriptInit()
{
	// Test

	#if 0

	GetRandomGangSkin(SKIN_GANG_GROVE);
	GetRandomGangSkin(SKIN_GANG_BALLA);
	GetRandomGangSkin(SKIN_GANG_AZTECA);
	GetRandomGangSkin(SKIN_GANG_VAGO);
	GetRandomGangSkin(SKIN_GANG_DANANG);
	GetRandomGangSkin(SKIN_GANG_RIFA);
	GetRandomGangSkin(SKIN_GANG_TRIAD);
	GetRandomGangSkin(SKIN_GANG_BIKER);
	GetRandomGangSkin(SKIN_GANG_RUSSIAN);
	GetRandomGangSkin(SKIN_GANG_ITALIAN);

	GetRandomServiceSkin(SKIN_SERVICE_LAW);
	GetRandomServiceSkin(SKIN_SERVICE_POLICE);
	GetRandomServiceSkin(SKIN_SERVICE_MIB);
	GetRandomServiceSkin(SKIN_SERVICE_SHERIFF);
	GetRandomServiceSkin(SKIN_SERVICE_SWAT);
	GetRandomServiceSkin(SKIN_SERVICE_FBI);
	GetRandomServiceSkin(SKIN_SERVICE_ARMY);
	GetRandomServiceSkin(SKIN_SERVICE_FIRE);
	GetRandomServiceSkin(SKIN_SERVICE_MEDIC);

	GetRandomGroupSkin(SKIN_GROUP_PLAYER        );
	GetRandomGroupSkin(SKIN_GROUP_COP           );
	GetRandomGroupSkin(SKIN_GROUP_MEDIC         );
	GetRandomGroupSkin(SKIN_GROUP_FIREMAN       );
	GetRandomGroupSkin(SKIN_GROUP_GANG          );
	GetRandomGroupSkin(SKIN_GROUP_STREET_GUY    );
	GetRandomGroupSkin(SKIN_GROUP_SUIT_GUY      );
	GetRandomGroupSkin(SKIN_GROUP_SENSIBLE_GUY  );
	GetRandomGroupSkin(SKIN_GROUP_GEEK_GUY      );
	GetRandomGroupSkin(SKIN_GROUP_OLD_GUY       );
	GetRandomGroupSkin(SKIN_GROUP_TOUGH_GUY     );
	GetRandomGroupSkin(SKIN_GROUP_STREET_GIRL   );
	GetRandomGroupSkin(SKIN_GROUP_SUIT_GIRL     );
	GetRandomGroupSkin(SKIN_GROUP_SENSIBLE_GIRL );
	GetRandomGroupSkin(SKIN_GROUP_GEEK_GIRL     );
	GetRandomGroupSkin(SKIN_GROUP_OLD_GIRL      );
	GetRandomGroupSkin(SKIN_GROUP_TOUGH_GIRL    );
	GetRandomGroupSkin(SKIN_GROUP_TRAMP_MALE    );
	GetRandomGroupSkin(SKIN_GROUP_TRAMP_FEMALE  );
	GetRandomGroupSkin(SKIN_GROUP_TOURIST       );
	GetRandomGroupSkin(SKIN_GROUP_PROSTITUTE    );
	GetRandomGroupSkin(SKIN_GROUP_CRIMINAL      );
	GetRandomGroupSkin(SKIN_GROUP_BUSKER        );
	GetRandomGroupSkin(SKIN_GROUP_TAXI_DRIVER   );
	GetRandomGroupSkin(SKIN_GROUP_PSYCHO        );
	GetRandomGroupSkin(SKIN_GROUP_STEWARD       );
	GetRandomGroupSkin(SKIN_GROUP_SPORTS_FAN    );
	GetRandomGroupSkin(SKIN_GROUP_SHOPPER       );
	GetRandomGroupSkin(SKIN_GROUP_OLD_SHOPPER   );
	GetRandomGroupSkin(SKIN_GROUP_BEACH_GUY     );
	GetRandomGroupSkin(SKIN_GROUP_BEACH_GIRL    );
	GetRandomGroupSkin(SKIN_GROUP_SKATER        );
	GetRandomGroupSkin(SKIN_GROUP_MISSION       );
	GetRandomGroupSkin(SKIN_GROUP_COWARD        );

	#endif

	#if defined PPEDGRP_OnScriptInit
		CallLocalFunction("PPEDGRP_OnScriptInit", "");
	#endif

	return 1;	
}

#if defined _ALS_OnScriptInit
	#undef OnScriptInit
#else
	#define _ALS_OnScriptInit
#endif
#define OnScriptInit PPEDGRP_OnScriptInit
forward OnScriptInit();

// Gang Functions

stock GetGangSkins(gang, results[], size = sizeof results)
{
	new count = 0;

	for(new i = 0; i <= MAX_SKIN_ID; i ++)
	{
		new tmpgang = GetSkinGang(i);

		if(tmpgang == gang)
		{
			if(count < size) results[count] = i;

			count ++;
		}
	}

	return count;
}

stock GetRandomGangSkin(gang)
{
	new results[4], count = GetGangSkins(gang, results);

	if(!count || count > sizeof(results))
	{
		printf("[Warning] Num Gang Skins: %d (gang: %b, size: %d)", count, gang, sizeof(results));

		return -1;
	}

	return results[random(count)];
}

// Service Functions

stock GetServiceSkins(service, results[], size = sizeof results)
{
	new count = 0;

	for(new i = 0; i <= MAX_SKIN_ID; i ++)
	{
		new tmpservice = GetSkinService(i);

		if(tmpservice == service)
		{
			if(count < size) results[count] = i;

			count ++;
		}
	}

	return count;
}

stock GetRandomServiceSkin(service)
{
	new results[4], count = GetServiceSkins(service, results);

	if(!count || count > sizeof(results))
	{
		printf("[Warning] Num Service Skins: %d (service: %b, size: %d)", count, service, sizeof(results));

		return -1;
	}

	return results[random(count)];
}

// Group Functions

stock GetGroupSkins(group, results[], size = sizeof results)
{
	new count = 0;

	for(new i = 0; i <= MAX_SKIN_ID; i ++)
	{
		new tmpgroup = GetSkinGroup(i);

		if(tmpgroup == group)
		{
			if(count < size) results[count] = i;

			count ++;
		}
	}

	return count;
}

stock GetRandomGroupSkin(group)
{
	new results[33], count = GetGroupSkins(group, results);

	if(!count || count > sizeof(results))
	{
		printf("[Warning] Num Group Skins: %d (group: %d, size: %d)", count, group, sizeof(results));

		return -1;
	}

	return results[random(count)];
}

// 

stock GetPedSkinForPoint2D(Float:x, Float:y, interior = 0)
{
	if(interior == 0)
	{
		new MapZone:mapzone = GetMapZoneAtPoint2D(x, y);

		switch(random(100))
		{
			case 0..19: // Cops
			{
				return GetRandomServiceSkin(SKIN_SERVICE_POLICE);
			}
			case 20..39: // Criminals
			{
				new gangid = GetPedMapZoneGang(_:mapzone);

				if(mapzone != INVALID_MAP_ZONE_ID && gangid == -1) return GetRandomGroupSkin(SKIN_GROUP_CRIMINAL);
				else return GetRandomGangSkin(gangid);
			}
		}
	}

	return GetCivilianPed();
}

stock GetCivilianPed()
{
	return GetRandomGroupSkin(gCivPedGroups[random(sizeof(gCivPedGroups))]);
}

stock GetSkinBlipColor(skinid)
{
	new color, gangid = GetSkinGang(skinid);

	if(GetPedGangColor(gangid, color)) return color;

	/*switch(GetSkinGroup(skinid))
	{
		case SKIN_GROUP_COP: return 0xFF0000FF;
	}*/

	return 0x00000000;
}
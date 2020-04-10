// Callback Hooks

public OnScriptInit()
{
	Iter_Clear(PedNode);

	gPedNodesAutoSave = false;

	#if defined PNODES_OnScriptInit
	CallLocalFunction("PNODES_OnScriptInit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptInit
	#undef OnScriptInit
#else
	#define _ALS_OnScriptInit
#endif
#define OnScriptInit PNODES_OnScriptInit
forward OnScriptInit();


public OnScriptExit()
{
	if(gPedNodesAutoSave && gPedNodesAutoSaveFile[0] != EOS) SavePedNodes(gPedNodesAutoSaveFile);

	for(new i = 0; i < MAX_PNODES; i ++) DestroyPedNode(i, false, false);

	#if defined PNODES_OnScriptExit
	CallLocalFunction("PNODES_OnScriptExit", "");
	#endif

	return 1;
}

#if defined _ALS_OnScriptExit
	#undef OnScriptExit
#else
	#define _ALS_OnScriptExit
#endif
#define OnScriptExit PNODES_OnScriptExit
forward OnScriptExit();

// Functions

stock IsValidPedNode(id)
{
	if(id < 0 || id >= MAX_PNODES) return 0;

	return _:gPedNodes[id][pnExists];
}

stock CreatePedNode(type, Float:x, Float:y, Float:z, interior, Float:width = PNODE_DEFAULT_WIDTH, Float:height = PNODE_DEFAULT_HEIGHT, bool:snap = false, bool:render = false, id = -1)
{
	if(id == -1)
	{
		id = Iter_Free(PedNode);

		if(id == ITER_NONE) return -1;
	}
	else
	{
		if(IsValidPedNode(id)) return -1;
	}

	if(snap)
	{
		new Float:nz;
		CA_GetClosestZ(x, y, z, -0.1, 1.5, nz);
		z = nz;
	}

	gPedNodes[id][pnExists] = true;
	gPedNodes[id][pnType] = type;

	gPedNodes[id][pnInterior] = interior;

	gPedNodes[id][pnX] = x;
	gPedNodes[id][pnY] = y;
	gPedNodes[id][pnZ] = z;
	gPedNodes[id][pnW] = width;
	gPedNodes[id][pnH] = height;

	gPedNodes[id][pnZoneX] = -1;
	gPedNodes[id][pnZoneY] = -1;

	Iter_Add(PedNode, id);

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) gPedNodes[id][pnConnections][i] = -1;

	#if PNE_EDITOR == true
	gPedNodes[id][pnRendered] = false;
	gPedNodes[id][pnObjectID] = -1;
	#endif

	if(render) RenderPedNode(id);

	return id;
}

stock DestroyPedNode(id, bool:disconnect = true, bool:derender = true)
{
	if(!IsValidPedNode(id)) return 0;

	if(disconnect)
	{
		DisconnectAllPedNodes(id);
	}

	if(derender)
	{
		DeRenderPedNode(id);
	}

	RemoveTeleZone(gPedNodes[id][pnZoneX], gPedNodes[id][pnZoneY]);

	#if PNE_EDITOR
	foreach(new i : Player) if(GetPlayerEditSelection(i) == id) SetPlayerEditSelection(i, -1);
	#endif

	Iter_Remove(PedNode, id);

	gPedNodes[id][pnExists] = false;

	return 1;
}

stock GetPedNodeType(id)
{
	if(!IsValidPedNode(id)) return -1;

	return gPedNodes[id][pnType];
}

stock SetPedNodeType(id, type, bool:render = true)
{
	if(!IsValidPedNode(id) || type < 0 || type >= PNODE_TYPE_MAX) return 0;

	gPedNodes[id][pnType] = type;

	if(render) RenderPedNode(id);

	return 1;
}

stock GetPedNodeTypeName(type, result[], size = sizeof result)
{
	switch(type)
	{
		case PNODE_TYPE_WALK:
		{
			format(result, size, "Walk");
			return 1;
		}
		case PNODE_TYPE_CROSS:
		{
			format(result, size, "Cross");
			return 1;
		}
		case PNODE_TYPE_FLEE:
		{
			format(result, size, "Flee");
			return 1;
		}
		case PNODE_TYPE_JUMP:
		{
			format(result, size, "Jump");
			return 1;
		}
		case PNODE_TYPE_TELE:
		{
			format(result, size, "Tele");
			return 1;
		}
	}

	return 0;
}

stock UpdatePedNodeZone(id)
{
	if(!IsValidPedNode(id)) return 0;

	new Float:x, Float:y, Float:z;
	GetPedNodePos(id, x, y, z);

	new zone_x = gPedNodes[id][pnZoneX], zone_y = gPedNodes[id][pnZoneY];

	if(IsValidZone(zone_x, zone_y))
	{
		RemoveTeleZone(zone_x, zone_y);
	}

	if(GetZoneForPoint2D(x, y, zone_x, zone_y) && GetPedNodeType(id) == PNODE_TYPE_TELE && CountPedNodeConnections(id) == 1)
	{
		gPedNodes[id][pnZoneX] = zone_x;
		gPedNodes[id][pnZoneY] = zone_y;

		AddTeleZone(zone_x, zone_y);
	}
	else
	{
		gPedNodes[id][pnZoneX] = -1;
		gPedNodes[id][pnZoneY] = -1;
	}

	return 1;
}

stock UpdateAllPedNodeZones(bool:print_count = false)
{
	foreach(new id : PedNode)
	{
		UpdatePedNodeZone(id);
	}

	if(print_count)
	{
		new max_x = -1, max_y, count, tmpcount;

		for(new x = 0; x < NUM_PED_ZONES_X; x ++) for(new y = 0; y < NUM_PED_ZONES_Y; y ++)
		{
			tmpcount = GetTeleZoneCount(x, y);

			if(max_x == -1 || tmpcount > count)
			{
				max_x = x;
				max_y = y;
				count = tmpcount;
			}
		}

		if(max_x != -1) printf("Highest Spawn Node Count: %d/%d (%d)", max_x, max_y, count);
	}

	return 1;
}

stock IsPedNodeInZone(id, x, y)
{
	if(!IsValidPedNode(id)) return 0;

	return (x == gPedNodes[id][pnZoneX] && y == gPedNodes[id][pnZoneY]);
}

stock GetPedNodeInterior(id)
{
	if(!IsValidPedNode(id)) return -1;

	return gPedNodes[id][pnInterior];	
}

stock SetPedNodeInterior(id, interior, bool:render = true)
{
	if(!IsValidPedNode(id)) return 0;

	gPedNodes[id][pnInterior] = interior;

	if(render) RenderPedNode(id);

	return 1;
}

stock GetPedNodePos(id, &Float:x, &Float:y, &Float:z)
{
	if(!IsValidPedNode(id)) return 0;

	x = gPedNodes[id][pnX];
	y = gPedNodes[id][pnY];
	z = gPedNodes[id][pnZ];

	return 1;
}

stock SetPedNodePos(id, Float:x, Float:y, Float:z, bool:snap = false, bool:render = true)
{
	if(!IsValidPedNode(id)) return 0;

	if(snap)
	{
		new Float:nz;
		CA_GetClosestZ(x, y, z, -0.1, 1.5, nz);
		z = nz;
	}

	gPedNodes[id][pnX] = x;
	gPedNodes[id][pnY] = y;
	gPedNodes[id][pnZ] = z;

	if(render) RenderPedNode(id);

	return 1;
}

stock GetPedNodeWidth(id, &Float:w)
{
	if(!IsValidPedNode(id)) return 0;

	w = gPedNodes[id][pnW];

	return 1;
}

stock SetPedNodeWidth(id, Float:w)
{
	if(!IsValidPedNode(id)) return 0;

	gPedNodes[id][pnW] = w;

	return 1;
}

stock GetPedNodeHeight(id, &Float:h)
{
	if(!IsValidPedNode(id)) return 0;

	h = gPedNodes[id][pnH];

	return 1;
}

stock SetPedNodeHeight(id, Float:h)
{
	if(!IsValidPedNode(id)) return 0;

	gPedNodes[id][pnH] = h;

	return 1;
}

stock GetClosestPedNodeFromPoint(Float:x, Float:y, Float:z, interior = 0, Float:max_dist = 50.0)
{
	new Float:node_x, Float:node_y, Float:node_z, id = -1, Float:dist, Float:tmp_dist;

	foreach(new i : PedNode) if(gPedNodes[i][pnInterior] == interior)
	{
		GetPedNodePos(i, node_x, node_y, node_z);

		tmp_dist = VectorSize(x - node_x, y - node_y, z - node_z);

		if(max_dist > tmp_dist && (id == -1 || tmp_dist < dist))
		{
			id = i;
			dist = tmp_dist;
		}
	}

	return id;
}

stock GetWorldAngleBetween2PedNodes(id1, id2, &Float:angle)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return 0;

	new Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;

	GetPedNodePos(id1, x1, y1, z1);
	GetPedNodePos(id2, x2, y2, z2);

	PNE_GetRZFromVectorXY(x2 - x1, y2 - y1, angle);

	return 1;
}

stock GetWorldAngleBetween3PedNodes(id1, id2, id3, &Float:angle)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2) || !IsValidPedNode(id3)) return 0;

	new Float:angle1, Float:angle2;

	GetWorldAngleBetweenPedNodes(id1, id2, angle1);
	GetWorldAngleBetweenPedNodes(id2, id3, angle2);

	new Float:dif = GetAngleDif(angle1, angle2);

	angle = angle1 + (dif / 2.0);

	return 1;
}

stock CountPedNodeConnections(id)
{
	if(!IsValidPedNode(id)) return 0;

	new connections;

	for(new c = 0; c < MAX_PNODE_CONNECTIONS; c ++) if(gPedNodes[id][pnConnections][c] != -1) connections ++;

	return connections;
}

stock CountPedNodeRemoteConnections(id1)
{
	if(!IsValidPedNode(id1)) return 0;

	new connections;

	foreach(new id2 : PedNode)
	{
		if(id1 != id2 && GetPedNodeConnectionDirection(id1, id2) != -2)
		{
			connections ++;
		}
	}

	return connections;
}

stock GetPedNodeConnectionAt(id, connid)
{
	if(!IsValidPedNode(id)) return -1;

	if(connid < 0 || connid >= MAX_PNODE_CONNECTIONS) return -1;

	return gPedNodes[id][pnConnections][connid];
}

stock ConnectPedNodes(id1, id2, direction)
{
	if(direction > 0) AddPedNodeConnection(id1, id2);
	else if(direction < 0) AddPedNodeConnection(id2, id1);
	else
	{
		AddPedNodeConnection(id1, id2);
		AddPedNodeConnection(id2, id1);
	}

	return 1;
}

stock AddPedNodeConnection(id1, id2)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return -1;

	new slot = -1;

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++)
	{
		if(gPedNodes[id1][pnConnections][i] == id2) return -1;

		if(gPedNodes[id1][pnConnections][i] == -1 && slot == -1) slot = i;
	}

	if(slot == -1) return -1;

	gPedNodes[id1][pnConnections][slot] = id2;

	return slot;
}

stock IsPedNodeConnectedToNode(id1, id2)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return 0;

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) if(gPedNodes[id1][pnConnections][i] == id2) return 1;

	return 0;
}

stock GetPedNodeConnectionDirection(id1, id2)
{
	new a2b = IsPedNodeConnectedToNode(id1, id2), b2a = IsPedNodeConnectedToNode(id2, id1);

	if(a2b == b2a) return (a2b ? 0 : -2);
	else return (a2b ? 1 : -1);
}

stock DisconnectPedNode(id1, id2)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return 0;

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) if(gPedNodes[id1][pnConnections][i] == id2)
	{
		DeRenderPedNodeConnection(id1, id2);

		gPedNodes[id1][pnConnections][i] = -1;
	}

	return 1;
}

stock DisconnectAllPedNodes(id)
{
	if(!IsValidPedNode(id)) return 0;

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) if(gPedNodes[id][pnConnections][i] != -1)
	{
		DisconnectPedNode(gPedNodes[id][pnConnections][i], id);
		RenderPedNode(gPedNodes[id][pnConnections][i]);
		gPedNodes[id][pnConnections][i] = -1;	
	}

	return 1;
}

stock RenderPedNode(id)
{
	if(!IsValidPedNode(id)) return 0;

	#if PNE_EDITOR == true

	if(gPedNodes[id][pnRendered]) DeRenderPedNode(id);

	new text[28], connections;

	new objid = CreateDynamicObject(PNODE_OBJECT_MODEL, gPedNodes[id][pnX], gPedNodes[id][pnY], gPedNodes[id][pnZ] + PNODE_OBJECT_OFF_Z, 0.0, 0.0, 0.0, 0, gPedNodes[id][pnInterior], 900000, PNODE_OBJECT_SD, PNODE_OBJECT_DD, .priority = 1);

	gPedNodes[id][pnObjectID] = objid;

	foreach(new playerid : Player)
	{
		if(GetPlayerEditState(playerid) != PLAYER_EDIT_NONE)
		{
			Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_PLAYER_ID, playerid);
		}
	}

	new e_info[3];
	e_info[0] = PNODES_XID;
	e_info[1] = -1;
	e_info[2] = -1;

	Streamer_SetArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_EXTRA_ID, e_info);

	for(new i = 0; i < MAX_PNODE_CONNECTIONS; i ++) if(gPedNodes[id][pnConnections][i] != -1)
	{
		RenderPedNodeConnection(id, gPedNodes[id][pnConnections][i]);

		connections ++;
	}

	switch(gPedNodes[id][pnType])
	{
		case PNODE_TYPE_WALK:
		{
			format(text, sizeof(text), "#%d\nWalk\n>%d", id, connections);

			SetDynamicObjectMaterialText(objid, 0, " ", OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF00FF00, 1);
			SetDynamicObjectMaterialText(objid, 1, text, OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF000000, 1);
		}
		case PNODE_TYPE_CROSS:
		{
			format(text, sizeof(text), "#%d\nCross\n>%d", id, connections);

			SetDynamicObjectMaterialText(objid, 0, " ", OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFFFFFF00, 1);
			SetDynamicObjectMaterialText(objid, 1, text, OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF000000, 1);
		}
		case PNODE_TYPE_FLEE:
		{
			format(text, sizeof(text), "#%d\nFlee\n>%d", id, connections);

			SetDynamicObjectMaterialText(objid, 0, " ", OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFFFF0000, 1);
			SetDynamicObjectMaterialText(objid, 1, text, OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF000000, 1);
		}
		case PNODE_TYPE_JUMP:
		{
			format(text, sizeof(text), "#%d\nJump\n>%d", id, connections);

			SetDynamicObjectMaterialText(objid, 0, " ", OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFFFF00FF, 1);
			SetDynamicObjectMaterialText(objid, 1, text, OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF000000, 1);
		}
		case PNODE_TYPE_TELE:
		{
			format(text, sizeof(text), "#%d\nTele\n>%d", id, connections);

			SetDynamicObjectMaterialText(objid, 0, " ", OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFFFFFFFF, 1);
			SetDynamicObjectMaterialText(objid, 1, text, OBJECT_MATERIAL_SIZE_256x128, "Verdana", 45, 0, 0xFFFFFFFF, 0xFF000000, 1);
		}
	}

	gPedNodes[id][pnRendered] = true;

	#endif

	return 1;
}

stock RenderAllPedNodes()
{
	#if PNE_EDITOR == true

	foreach(new id : PedNode)
	{
		RenderPedNode(id);
	}

	#endif

	return 1;
}

stock RecRenderPedNode(id)
{
	if(!IsValidPedNode(id)) return 0;

	#if PNE_EDITOR == true

	new connid;
	foreach(new i : PedNode) for(new c = 0; c < MAX_PNODE_CONNECTIONS; c ++)
	{
		if((connid = GetPedNodeConnectionAt(i, c)) != -1)
		{
			if(i == id || i == connid) RenderPedNode(i);
		}
	}

	#endif

	return 1;
}

stock DeRenderPedNode(id)
{
	if(!IsValidPedNode(id)) return 0;

	#if PNE_EDITOR == true

	if(IsValidDynamicObject(gPedNodes[id][pnObjectID])) DestroyDynamicObject(gPedNodes[id][pnObjectID]);
	gPedNodes[id][pnObjectID] = -1;

	DeRenderAllPedNodeConnections(id);

	#endif

	return 1;
}

stock RenderPedNodeConnection(id1, id2)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return 0;

	#if PNE_EDITOR == true

	new Float:x1 = gPedNodes[id1][pnX], Float:y1 = gPedNodes[id1][pnY], Float:z1 = gPedNodes[id1][pnZ],
		Float:x2 = gPedNodes[id2][pnX], Float:y2 = gPedNodes[id2][pnY], Float:z2 = gPedNodes[id2][pnZ],
		Float:dis = VectorSize(x1 - x2, y1 - y2, z1 - z2), num = floatround(dis / 2.5, floatround_floor);

	new Float:vx = (x2 - x1) / dis, Float:vy = (y2 - y1) / dis, Float:vz = (z2 - z1) / dis,
		Float:rx, Float:rz,
		Float:x, Float:y, Float:z, objid;

	PNE_GetRXFromVectorZ(vz, rx);
	PNE_GetRZFromVectorXY(vx, vy, rz);

	for(new i = 0; i < (num/2) + 1; i ++)
	{
		x = x1 + i * vx * 2.5;
		y = y1 + i * vy * 2.5;
		z = z1 + i * vz * 2.5;

		objid = CreateDynamicObject(19087, x, y, z + (id1 < id2 ? 0.2 : 0.4), rx + 90.0, 0.0, rz, 0, gPedNodes[id1][pnInterior], 1000000, PNODE_CONN_SD, PNODE_CONN_DD, .priority = 0);

		foreach(new playerid : Player) if(GetPlayerEditState(playerid) != PLAYER_EDIT_NONE)
		{
			Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_PLAYER_ID, playerid);
		}

		if(IsValidDynamicObject(objid))
		{
			new e_info[3];
			e_info[0] = PNODES_CONNECTION_XID;
			e_info[1] = id1;
			e_info[2] = id2;

			Streamer_SetArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_EXTRA_ID, e_info);
		}
	}

	#endif

	return 1;
}

stock DeRenderPedNodeConnection(id1, id2)
{
	if(!IsValidPedNode(id1) || !IsValidPedNode(id2)) return 0;

	#if PNE_EDITOR == true

	new e_info[3], count;

	for(new objid = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT) + 1; objid >= 0; objid --)
	{
		if(IsValidDynamicObject(objid))
		{
			Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_EXTRA_ID, e_info);

			if(e_info[0] == PNODES_CONNECTION_XID)
			{
				if(e_info[1] == id1 && e_info[2] == id2)
				{
					DestroyDynamicObject(objid);

					count ++;
				}
			}
		}
	}

	return count;

	#else

	return 0;

	#endif
}

stock DeRenderAllPedNodeConnections(id)
{
	if(!IsValidPedNode(id)) return 0;

	#if PNE_EDITOR == true

	new e_info[3];

	for(new objid = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objid >= 0; objid --)
	{
		if(IsValidDynamicObject(objid))
		{
			Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_EXTRA_ID, e_info);

			if(e_info[0] == PNODES_CONNECTION_XID)
			{
				if(e_info[1] == id)
				{
					DestroyDynamicObject(objid);
				}
			}
		}
	}

	#endif

	return 1;
}

stock ShowEditorObjects(playerid = -1, toggle = 1)
{
	#if PNE_EDITOR == true

	new e_info[3];

	for(new objid = Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); objid >= 0; objid --)
	{
		if(IsValidDynamicObject(objid))
		{
			Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_EXTRA_ID, e_info);

			if(e_info[0] == PNODES_XID || e_info[0] == PNODES_CONNECTION_XID)
			{
				if(toggle) Streamer_AppendArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_PLAYER_ID, playerid);
				else Streamer_RemoveArrayData(STREAMER_TYPE_OBJECT, objid, E_STREAMER_PLAYER_ID, playerid);
			}
		}
	}

	#endif

	return 1;
}

stock FindSpawnNode()
{
	new zone_x, zone_y;

	if(!GetRandomTeleZone(zone_x, zone_y))
	{
		printf("Failed to get random Spawn Zone");

		return -1;
	}

	new list[150], count;

	foreach(new id : PedNode)
	{
		if(IsPedNodeInZone(id, zone_x, zone_y) && GetPedNodeType(id) == PNODE_TYPE_TELE && CountPedNodeConnections(id) == 1)
		{
			if(count >= sizeof(list))
			{
				printf("Zone %d/%d exceeded %d Spawn Nodes", zone_x, zone_y, sizeof(list));
				break;
			}

			list[count ++] = id;
		}
	}

	if(count == 0)
	{
		printf("failed to get random spawn node in zone %d/%d", zone_x, zone_y);

		return -1;
	}

	return list[random(count)];
}

// Loading / Saving

TogglePedNodesAutoSave(toggle, const filename[] = "")
{
	gPedNodesAutoSave = (toggle ? true : false);

	if(filename[0] != EOS)
	{
		format(gPedNodesAutoSaveFile, sizeof(gPedNodesAutoSaveFile), filename);
	}

	return 1;
}

stock SavePedNodes(const filename[])
{
	new tmp[150];

	if(fexist(filename))
	{
		new File:fIn = fopen(filename, io_read);

		print("exists");

		if(fIn)
		{
			print("opened in");

			new year, month, day, hour, minute, second;
			gettime(hour, minute, second);
			getdate(year, month, day);

			format(tmp, sizeof(tmp), PNODE_FILE_TMP, filename, year, month, day, hour, minute, second);

			print(tmp);

			new File:fOutTMP = fopen(tmp, io_write);

			if(fOutTMP)
			{
				print("opened out");

				while(fread(fIn, tmp)) fwrite(fOutTMP, tmp);

				fclose(fOutTMP);
			}

			fclose(fIn);
		}
	}

	new File:fOut = fopen(filename, io_write);

	if(!fOut) return 0;

	fwrite(fOut, "#Ped Nodes for PNEdit v1 by NaS\r\n");
	fwrite(fOut, "#FORMAT (Nodes): N ID, Type, Interior, X, Y, Z, W, H\r\n");
	fwrite(fOut, "#FORMAT (Connections): C ID1, ID2\r\n");
	fwrite(fOut, "VER:1\r\n\r\n");

	new count, type, interior, Float:x, Float:y, Float:z, Float:w, Float:h, type_name[8];

	foreach(new id : PedNode)
	{
		type = GetPedNodeType(id);
		interior = GetPedNodeInterior(id);
		GetPedNodePos(id, x, y, z);
		GetPedNodeWidth(id, w);
		GetPedNodeHeight(id, h);
		GetPedNodeTypeName(type, type_name);

		format(tmp, sizeof(tmp), "N %d, %d, %d, %f, %f, %f, %f, %f // %s (ID: %d)\r\n", id, type, interior, x, y, z, w, h, type_name, id);
		fwrite(fOut, tmp);

		count ++;
	}

	new connid;

	foreach(new id : PedNode)
	{
		new conncount;

		for(new c = 0; c < MAX_PNODE_CONNECTIONS; c ++)
		{
			connid = GetPedNodeConnectionAt(id, c);

			if(connid == -1) continue;

			format(tmp, sizeof(tmp), "C %d, %d // (Count: %d, CID: %d)\r\n", id, connid, ++ conncount, c);
			fwrite(fOut, tmp);
		}
	}

	fclose(fOut);

	return count;
}

stock LoadPedNodes(const filename[], bool:add = false)
{
	if(!fexist(filename)) return 0;

	new File:fIn = fopen(filename, io_read);

	if(!fIn) return 0;

	if(!add)
	{
		foreach(new id : PedNode) DestroyPedNode(id, false);
	}

	new count, conncount, tmp[100], len, id, connid, type, interior, Float:x, Float:y, Float:z, Float:w, Float:h, ver = 1;

	printf("Loading Ped Nodes from \"%s\" ...", filename);

	while(fread(fIn, tmp))
	{
		if(tmp[0] == '#') continue;

		len = strlen(tmp);

		for(new i = 0; i < len; i ++)
		{
			if(tmp[i] == '/' || tmp[i] == '\r' || tmp[i] == '\n')
			{
				tmp[i] = EOS;
				len = i;
				break;
			}
		}

		if(len < 3) continue;

		if(!sscanf(tmp, "p<:>'ver'i", ver)) continue;

		switch(ver)
		{
			default: // 1
			{
				if(!sscanf(tmp, "'N'p<,>iiifffff", id, type, interior, x, y, z, w, h))
				{
					if(id < 0 || id >= MAX_PNODES)
					{
						printf("PN Error: LoadPedNodes() - Invalid ID: %d", id);
						continue;
					}

					if(w >= 0.64) w = PNODE_DEFAULT_WIDTH;
					if(h >= 2.38) w = PNODE_DEFAULT_HEIGHT;

					if(CreatePedNode(type, x, y, z, interior, w, h, .snap = false, .render = false, .id = id) != -1) count ++;

					continue;
				}

				if(!sscanf(tmp, "'C'p<,>ii", id, connid))
				{
					if(AddPedNodeConnection(id, connid)) conncount ++;

					continue;
				}
			}
		}
	}

	fclose(fIn);

	printf("Loaded %d Ped Nodes and %d Connections.", count, conncount);

	print("Updating all Ped Nodes and Zones ...");

	RenderAllPedNodes();

	UpdateAllPedNodeZones(true);

	print("Done");

	SetTimer("PNE_UpdateNodes", 500, 0);

	/*new Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2,
		Float:dis;

	for(new i = 0; i < MAX_PNODES; i ++) if(IsValidPedNode(i))
	{
		for(new j = 0; j < MAX_PNODES; j ++) if(IsValidPedNode(j))
		{
			if(i == j) continue;

			GetPedNodePos(i, x1, y1, z1);
			GetPedNodePos(j, x2, y2, z2);

			dis = VectorSize(x1 - x2, y1 - y2, z1 - z2);

			if(dis < 0.05)
			{
				printf("Warning: Node %d is too close to Node %d - %fm", i, j, dis);
			}
		}
	}*/

	return count;
}

stock CountPlayersNearPedNode(Float:range, id)
{
	if(!IsValidPedNode(id)) return -1;

	new Float:x, Float:y, Float:z;
	GetPedNodePos(id, x, y, z);

	return CountPlayersNearPoint(range, x, y, z, GetPedNodeInterior(id));
}

stock IsAnyPlayerNearPedNode(Float:range, id)
{
	if(!IsValidPedNode(id)) return 0;

	new Float:x, Float:y, Float:z;
	GetPedNodePos(id, x, y, z);

	return IsAnyPlayerNearPoint(range, x, y, z, GetPedNodeInterior(id));
}

stock FindNextValidPedNode(id, dir)
{
	//if(itemid < 0 || itemid >= MAX_ITEMS) itemid = 0;
	new slot = -1, s = id;

	for(new i = 0; i <= MAX_PNODES; i ++)
	{
		s += dir;
		
		if(s < 0) s = MAX_PNODES - 1;
		else if(s >= MAX_PNODES) s = 0;
		
		if(s == id) continue;
		
		if(!IsValidPedNode(s)) continue;

		slot = s;
		break;
	}
	
	return slot;
}

public PNE_UpdateNodes()
{
	
}
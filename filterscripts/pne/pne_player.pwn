// Callback Hooks

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_NONE || hittype == BULLET_HIT_TYPE_OBJECT || hittype == BULLET_HIT_TYPE_PLAYER_OBJECT)
	{
		new editstate = GetPlayerEditState(playerid);

		if(editstate != PLAYER_EDIT_NONE && GetPlayerLastShotDur(playerid) > 800)
		{
			UpdatePlayerLastShotStamp(playerid);

			new Float:ox, Float:oy, Float:oz, Float:hx, Float:hy, Float:hz;
			GetPlayerLastShotVectors(playerid, ox, oy, oz, hx, hy, hz);

			if(VectorSize(hx, hy, hz) < 0.1) return 1;

			new Float:dist = VectorSize(hx - ox, hy - oy, hz - oz);

			if(dist > 50.0) return 1;

			GetPlayerPos(playerid, fX, fY, fZ);

			if(VectorSize(fX - hx, fY - hy, fZ - hz) > 50.0) return 1;

			GivePlayerWeapon(playerid, weaponid, 2);

			switch(weaponid)
			{
				case WEAPON_DEAGLE: // Select
				{
					new id = GetClosestPedNodeFromPoint(hx, hy, hz, GetPlayerInterior(playerid), 50.0);

					if(id != -1)
					{
						SetPlayerEditSelection(playerid, id);

						PNE_SendSuccess(playerid, "Updated Ped Node selection.");
					}
				}
				case WEAPON_MP5: // Action
				{
					new keys, ud, lr;

					GetPlayerKeys(playerid, keys, ud, lr);

					if(keys & KEY_WALK) // Connect
					{
						new sel = GetPlayerEditSelection(playerid);

						if(sel == -1) return PNE_SendError(playerid, "No Node selected.");

						new id = GetClosestPedNodeFromPoint(hx, hy, hz, GetPlayerInterior(playerid), 5.0);

						if(id == -1) return PNE_SendError(playerid, "No Node found.");

						if(IsValidPedNode(sel))
						{
							if(ConnectPedNodes(id, sel, 0))
							{
								PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
							}
							else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
						}

						RenderPedNode(sel);
						RecRenderPedNode(id);

						SetPlayerEditSelection(playerid, id);
					}
					else
					{
						switch(editstate)
						{
							case PLAYER_EDIT_MASS_ADD_WALK:
							{
								new id = CreatePedNode(PNODE_TYPE_WALK, hx, hy, hz, GetPlayerInterior(playerid), 3.5, 7.2, true, true);

								if(!IsValidPedNode(id))
								{
									PNE_SendError(playerid, "Failed to create Ped Node.");

									return 1;
								}

								PNE_SendSuccess(playerid, "Ped Node successfully created.");

								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									if(ConnectPedNodes(id, sel, 0))
									{
										PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
									}
									else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
								}

								RenderPedNode(sel);
								RecRenderPedNode(id);

								SetPlayerEditSelection(playerid, id);
							}

							case PLAYER_EDIT_MASS_ADD_CROSS:
							{
								new id = CreatePedNode(PNODE_TYPE_CROSS, hx, hy, hz, GetPlayerInterior(playerid), 3.5, 7.2, true);

								if(!IsValidPedNode(id))
								{
									PNE_SendError(playerid, "Failed to create Ped Node.");

									return 1;
								}

								PNE_SendSuccess(playerid, "Ped Node successfully created.");

								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									if(ConnectPedNodes(id, sel, 0))
									{
										PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
									}
									else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
								}

								RenderPedNode(sel);
								RecRenderPedNode(id);

								SetPlayerEditSelection(playerid, id);
							}

							case PLAYER_EDIT_MASS_ADD_FLEE:
							{
								new id = CreatePedNode(PNODE_TYPE_FLEE, hx, hy, hz, GetPlayerInterior(playerid), 3.5, 7.2, true);

								if(!IsValidPedNode(id))
								{
									PNE_SendError(playerid, "Failed to create Ped Node.");

									return 1;
								}

								PNE_SendSuccess(playerid, "Ped Node successfully created.");

								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									if(ConnectPedNodes(id, sel, 0))
									{
										PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
									}
									else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
								}

								RenderPedNode(sel);
								RecRenderPedNode(id);

								SetPlayerEditSelection(playerid, id);
							}

							case PLAYER_EDIT_MASS_ADD_JUMP:
							{
								new id = CreatePedNode(PNODE_TYPE_JUMP, hx, hy, hz, GetPlayerInterior(playerid), 3.5, 7.2, true);

								if(!IsValidPedNode(id))
								{
									PNE_SendError(playerid, "Failed to create Ped Node.");

									return 1;
								}

								PNE_SendSuccess(playerid, "Ped Node successfully created.");

								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									if(ConnectPedNodes(id, sel, -1))
									{
										PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
									}
									else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
								}

								RenderPedNode(sel);
								RecRenderPedNode(id);

								SetPlayerEditSelection(playerid, id);
							}

							case PLAYER_EDIT_MASS_ADD_TELE:
							{
								new id = CreatePedNode(PNODE_TYPE_TELE, hx, hy, hz, GetPlayerInterior(playerid), 3.5, 7.2, true);

								if(!IsValidPedNode(id))
								{
									PNE_SendError(playerid, "Failed to create Ped Node.");

									return 1;
								}

								PNE_SendSuccess(playerid, "Ped Node successfully created.");

								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									if(ConnectPedNodes(id, sel, 0))
									{
										PNE_SendSuccess(playerid, "Ped Nodes successfully connected.");
									}
									else PNE_SendError(playerid, "Failed to connect Ped Nodes.");
								}

								RenderPedNode(sel);
								RecRenderPedNode(id);

								SetPlayerEditSelection(playerid, id);
							}

							case PLAYER_EDIT_MOVE:
							{
								new sel = GetPlayerEditSelection(playerid);

								if(IsValidPedNode(sel))
								{
									SetPedNodePos(sel, hx, hy, hz, true, false);

									RecRenderPedNode(sel);
									SetPlayerEditSelection(playerid, sel);

									PNE_SendSuccess(playerid, "Moved Ped Node to new position.");
								}
							}

							case PLAYER_EDIT_NODE_W:
							{
								new id = GetClosestPedNodeFromPoint(hx, hy, hz, GetPlayerInterior(playerid), 15.0);

								if(id != -1)
								{
									SetPlayerEditSelection(playerid, id);

									ShowDialog(playerid, DID_PN_NODE_W);
								}
							}

							case PLAYER_EDIT_NODE_H:
							{
								new id = GetClosestPedNodeFromPoint(hx, hy, hz, GetPlayerInterior(playerid), 15.0);

								if(id != -1)
								{
									SetPlayerEditSelection(playerid, id);

									ShowDialog(playerid, DID_PN_NODE_H);
								}
							}
						}
					}
				}
				case WEAPON_SNIPER: // Teleport
				{

				}
			}

			return 1;
		}
	}

	#if defined PPED_OnPlayerWeaponShot
	CallLocalFunction("PPLAYER_OnPlayerWeaponShot", "iiiifff", playerid, weaponid, hittype, hitid, fX, fY, fZ);
	#endif

	return 1;
}

#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot PPLAYER_OnPlayerWeaponShot
forward OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);


public OnPlayerConnect(playerid)
{
	UpdatePlayerLastShotStamp(playerid);
	
	#if defined PPLAYER_OnPlayerConnect
		return PPLAYER_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif

#define OnPlayerConnect PPLAYER_OnPlayerConnect
#if defined PPLAYER_OnPlayerConnect
	forward PPLAYER_OnPlayerConnect(playerid);
#endif

// Functions

GetPlayerEditState(playerid)
{
	if(!IsPlayerConnected(playerid)) return PLAYER_EDIT_NONE;

	return gPlayerEdit[playerid][pEditState];
}

SetPlayerEditState(playerid, editstate)
{
	if(!IsPlayerConnected(playerid)) return 0;

	if(IsPlayerNPC(playerid))
	{
		SetPlayerEditSelection(playerid, -1);

		return 1;
	}

	if(gPlayerEdit[playerid][pEditState] != editstate)
	{
		if(editstate == PLAYER_EDIT_NONE)
		{
			ResetPlayerWeapons(playerid);
			SetPlayerEditSelection(playerid, -1);
			
			ShowEditorObjects(playerid, 0);
		}
		else
		{
			ResetPlayerWeapons(playerid);
			if(GetPlayerWeapon(playerid) == WEAPON_DEAGLE)
			{
				GivePlayerWeapon(playerid, WEAPON_MP5, 10);
				GivePlayerWeapon(playerid, WEAPON_DEAGLE, 10);
			}
			else
			{
				GivePlayerWeapon(playerid, WEAPON_DEAGLE, 10);
				GivePlayerWeapon(playerid, WEAPON_MP5, 10);
			}

			if(gPlayerEdit[playerid][pEditState] == PLAYER_EDIT_NONE) ShowEditorObjects(playerid, 1);
		}
	}

	gPlayerEdit[playerid][pEditState] = editstate;

	UpdatePlayerEditTextDraw(playerid);

	return 1;
}

GetPlayerEditStateName(editstate, result[], size = sizeof result, bool:tdcolor = false)
{
	switch(editstate)
	{
		case PLAYER_EDIT_NONE:
		{
			if(tdcolor) format(result, size, "~w~NONE");
			else format(result, size, "NONE");

			return 1;
		}
		case PLAYER_EDIT_MOVE:
		{
			if(tdcolor) format(result, size, "~w~MOVE");
			else format(result, size, "MOVE");
			return 1;
		}
		case PLAYER_EDIT_MASS_ADD_WALK:
		{
			if(tdcolor) format(result, size, "~g~ADD WALK");
			else format(result, size, "ADD WALK");
			return 1;
		}
		case PLAYER_EDIT_MASS_ADD_CROSS:
		{
			if(tdcolor) format(result, size, "~y~ADD CROSS");
			else format(result, size, "ADD CROSS");
			return 1;
		}
		case PLAYER_EDIT_MASS_ADD_FLEE:
		{
			if(tdcolor) format(result, size, "~r~ADD FLEE");
			else format(result, size, "ADD FLEE");
			return 1;
		}
		case PLAYER_EDIT_MASS_ADD_JUMP:
		{
			if(tdcolor) format(result, size, "~p~ADD JUMP");
			else format(result, size, "ADD JUMP");
			return 1;
		}
		case PLAYER_EDIT_MASS_ADD_TELE:
		{
			if(tdcolor) format(result, size, "~w~ADD TELE");
			else format(result, size, "ADD TELE");
			return 1;
		}
		case PLAYER_EDIT_NODE_W:
		{
			if(tdcolor) format(result, size, "~w~WIDTH EDITOR");
			else format(result, size, "WIDTH EDITOR");
			return 1;
		}
		case PLAYER_EDIT_NODE_H:
		{
			if(tdcolor) format(result, size, "~w~HEIGHT EDITOR");
			else format(result, size, "HEIGHT EDITOR");
			return 1;
		}
	}

	return 0;
}

GetPlayerEditSelection(playerid)
{
	if(GetPlayerEditState(playerid) == PLAYER_EDIT_NONE) return -1;

	return gPlayerEdit[playerid][pEditSel];
}

SetPlayerEditSelection(playerid, id)
{
	if(!IsValidPedNode(id)) id = -1;

	if(id == -1)
	{
		DisablePlayerRaceCheckpoint(playerid);
	}
	else
	{
		new Float:x, Float:y, Float:z;
		GetPedNodePos(id, x, y, z);

		SetPlayerRaceCheckpoint(playerid, 4, x, y, z + 0.35, x, y, z + 1.0, 0.35);
	}

	gPlayerEdit[playerid][pEditSel] = id;

	UpdatePlayerEditTextDraw(playerid);

	return 1;
}

UpdatePlayerLastShotStamp(playerid)
{
	gPlayerEdit[playerid][pLastShotStamp] = GetTickCount();

	return 1;
}

GetPlayerLastShotDur(playerid)
{
	return GetTickCount() - gPlayerEdit[playerid][pLastShotStamp];
}

UpdatePlayerEditTextDraw(playerid)
{
	new editstate = GetPlayerEditState(playerid);

	switch(editstate)
	{
		case PLAYER_EDIT_NONE:
		{
			PlayerTextDrawHide(playerid, txtState[playerid]);
			PlayerTextDrawHide(playerid, txtSelection[playerid]);
		}
		default:
		{
			new text[30];

			GetPlayerEditStateName(editstate, text, sizeof(text), true);
			PlayerTextDrawSetString(playerid, txtState[playerid], text);
			PlayerTextDrawShow(playerid, txtState[playerid]);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1)
			{
				PlayerTextDrawHide(playerid, txtSelection[playerid]);
			}
			else
			{
				format(text, sizeof(text), "Sel: %d", sel);

				PlayerTextDrawSetString(playerid, txtSelection[playerid], text);
				PlayerTextDrawShow(playerid, txtSelection[playerid]);
			}
		}
	}
}
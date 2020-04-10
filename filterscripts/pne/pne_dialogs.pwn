
ShowDialog(playerid, id, dialogid = -1)
{
	if(dialogid == -1) dialogid = id;

	switch(id)
	{
		case DID_PN_MAIN: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "PNEdit - Main", "{00FF00}Add (Walk)\n{FFFF00}Add (Cross)\n{FF0000}Add (Flee)\n{FF00FF}Add (Jump)\n{FFFFFF}Add (Tele)\nMove\nWidth Editor\nHeight Editor\nStop Editing", "Select", "Cancel");
		case DID_PN_NODE_OPT: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "PNEdit - Node Options", "Info\nDestroy\nDisconnect (List)\nDisconnect (All)\nSet Type\nSet Interior\nSet Width\nSet Height", "Select", "Cancel");

		case DID_PN_NODE_CON_LIST:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new text[500], connid, count;
			for(new i = 0; i < MAX_PNODES; i ++) for(new c = 0; c < MAX_PNODE_CONNECTIONS; c ++)
			{
				if((connid = GetPedNodeConnectionAt(i, c)) != -1)
				{
					if(i == sel)
					{
						format(text, sizeof(text), "%s{00FF00}%d {FFFFFF}> %d\n", text, i, connid);

						count ++;
					}
					else if(connid == sel)
					{
						format(text, sizeof(text), "%s{FFFFFF}%d > {00FF00}%d\n", text, i, connid);

						count ++;
					}
				}
			}

			if(count)
			{
				ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "PNEdit - Disconnect (Directional)", text, "Disc.", "Cancel");
			}
		}

		case DID_PN_NODE_INFO:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new text[120], name[30], type = GetPedNodeType(sel), Float:w, Float:h;

			GetPedNodeTypeName(type, name);
			GetPedNodeWidth(sel, w);
			GetPedNodeHeight(sel, h);

			format(text, sizeof(text), "Ped Node ID:\t%d\nType:\t%d (%s)\nInterior:\t%d\nWidth:\t%.02f\nHeight:\t%.02f", sel, type, name, GetPedNodeInterior(sel), w, h);

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_TABLIST, "PNEdit - Node Info", text, "OK", "");
		}

		case DID_PN_NODE_DESTROY:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, "PNEdit - Destroy Node", "Destroy selected Ped Node?", "Yes", "No");
		}

		case DID_PN_NODE_TYPE:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new text[120], name[30];

			for(new i = 0; i < PNODE_TYPE_MAX; i ++)
			{
				GetPedNodeTypeName(i, name);

				strcat(text, name);

				if(i != PNODE_TYPE_MAX - 1) strcat(text, "\n");
			}

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, "PNEdit - Set Type", text, "Set", "Cancel");
		}

		case DID_PN_NODE_INTERIOR:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "PNEdit - Set Interior", "Type an Interior ID (0 - 24):", "Set", "Cancel");
		}

		case DID_PN_NODE_W:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "PNEdit - Set Width", "Type a Width for the Node (0.0 - 5.0):", "Set", "Cancel");
		}

		case DID_PN_NODE_H:
		{
			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, "PNEdit - Set Height", "Type a Height for the Node (0.0 - 5.0):", "Set", "Cancel");
		}
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new inputlen = strlen(inputtext);

	switch(dialogid)
	{
		case DID_PN_MAIN:
		{
			if(!response) return 1;

			switch(listitem)
			{
				case 8:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_NONE);
				}
				case 0:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MASS_ADD_WALK);
				}
				case 1:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MASS_ADD_CROSS);
				}
				case 2:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MASS_ADD_FLEE);
				}
				case 3:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MASS_ADD_JUMP);
				}
				case 4:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MASS_ADD_TELE);
				}
				case 5:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_MOVE);
				}
				case 6:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_NODE_W);
				}
				case 7:
				{
					SetPlayerEditState(playerid, PLAYER_EDIT_NODE_H);
				}
			}
		}

		case DID_PN_NODE_OPT:
		{
			if(!response) return 1;

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			switch(listitem)
			{
				case 0: // Info
				{
					ShowDialog(playerid, DID_PN_NODE_INFO);
				}
				case 1: // Destroy
				{
					ShowDialog(playerid, DID_PN_NODE_DESTROY);
				}
				case 2: // Disconnect (List)
				{
					ShowDialog(playerid, DID_PN_NODE_CON_LIST);
				}
				case 3: // Disconnect (All)
				{
					DisconnectAllPedNodes(sel);
					RenderPedNode(sel);
				}
				case 4: // Set Type
				{
					ShowDialog(playerid, DID_PN_NODE_TYPE);
				}
				case 5: // Set Interior
				{
					ShowDialog(playerid, DID_PN_NODE_INTERIOR);
				}
				case 6: // Set Width
				{
					ShowDialog(playerid, DID_PN_NODE_W);
				}
				case 7: // Set Width
				{
					ShowDialog(playerid, DID_PN_NODE_H);
				}
			}
		}

		case DID_PN_NODE_CON_LIST:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			if(inputlen == 0)
			{
				ShowDialog(playerid, DID_PN_NODE_OPT);

				return 1;
			}

			new id1, id2;

			if(sscanf(inputtext, "i'>'i", id1, id2))
			{
				ShowDialog(playerid, DID_PN_NODE_OPT);

				PNE_SendError(playerid, "Invalid Input.");

				return 1;
			}

			if(!IsValidPedNode(id1) || !IsValidPedNode(id2))
			{
				ShowDialog(playerid, DID_PN_NODE_OPT);

				PNE_SendError(playerid, "Invalid Node(s).");

				return 1;
			}

			DisconnectPedNode(id1, id2);

			PNE_SendSuccess(playerid, "Nodes disconnected.");

			RenderPedNode(id1);
			RenderPedNode(id2);
		}

		case DID_PN_NODE_INFO:
		{
			ShowDialog(playerid, DID_PN_NODE_OPT);
		}

		case DID_PN_NODE_DESTROY:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;
			
			DestroyPedNode(sel);

			PNE_SendSuccess(playerid, "Ped Node destroyed.");
		}

		case DID_PN_NODE_TYPE:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			if(listitem < 0 || listitem >= PNODE_TYPE_MAX) return 1;

			SetPedNodeType(sel, listitem);

			PNE_SendSuccess(playerid, "Ped Node Type updated.");
		}

		case DID_PN_NODE_INTERIOR:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new interior;

			if(!inputlen || sscanf(inputtext, "i", interior) || interior < 0 || interior > 24) return ShowDialog(playerid, dialogid);

			SetPedNodeInterior(sel, interior);

			PNE_SendSuccess(playerid, "Ped Node Interior updated.");
		}

		case DID_PN_NODE_W:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new Float:width;

			if(!inputlen || sscanf(inputtext, "f", width) || width < 0.0 || width > 5.0) return ShowDialog(playerid, dialogid);

			SetPedNodeWidth(sel, width);

			PNE_SendSuccess(playerid, "Ped Node Width updated.");
		}

		case DID_PN_NODE_H:
		{
			if(!response) return ShowDialog(playerid, DID_PN_NODE_OPT);

			new sel = GetPlayerEditSelection(playerid);

			if(sel == -1) return 1;

			new Float:height;

			if(!inputlen || sscanf(inputtext, "f", height) || height < 0.0 || height > 5.0) return ShowDialog(playerid, dialogid);

			SetPedNodeHeight(sel, height);

			PNE_SendSuccess(playerid, "Ped Node Height updated.");
		}

		default: return 0;
	}

	return 1;
}
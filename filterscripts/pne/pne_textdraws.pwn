stock CreateTextDraws()
{

}

CreatePlayerTextDraws(playerid = -1)
{
	if(playerid == -1)
	{
		foreach(new playerid2 : Player) CreatePlayerTextDraws(playerid2);
	}
	else
	{
		txtState[playerid] = CreatePlayerTextDraw(playerid, 320.0, 1.0, "None");
		PlayerTextDrawFont(playerid, txtState[playerid], 1);
		PlayerTextDrawColor(playerid, txtState[playerid], 0xFFFFFFFF);
		PlayerTextDrawBackgroundColor(playerid, txtState[playerid], 0x000000AA);
		PlayerTextDrawSetShadow(playerid, txtState[playerid], 0);
		PlayerTextDrawSetOutline(playerid, txtState[playerid], 1);
		PlayerTextDrawLetterSize(playerid, txtState[playerid], 0.3, 0.95);
		PlayerTextDrawAlignment(playerid, txtState[playerid], 2);
		PlayerTextDrawSetProportional(playerid, txtState[playerid], 1);
		PlayerTextDrawUseBox(playerid, txtState[playerid], 0);

		txtSelection[playerid] = CreatePlayerTextDraw(playerid, 320.0, 8.0, "None");
		PlayerTextDrawFont(playerid, txtSelection[playerid], 1);
		PlayerTextDrawColor(playerid, txtSelection[playerid], 0xFFFFFFFF);
		PlayerTextDrawBackgroundColor(playerid, txtSelection[playerid], 0x000000AA);
		PlayerTextDrawSetShadow(playerid, txtSelection[playerid], 0);
		PlayerTextDrawSetOutline(playerid, txtSelection[playerid], 1);
		PlayerTextDrawLetterSize(playerid, txtSelection[playerid], 0.2, 0.75);
		PlayerTextDrawAlignment(playerid, txtSelection[playerid], 2);
		PlayerTextDrawSetProportional(playerid, txtSelection[playerid], 1);
		PlayerTextDrawUseBox(playerid, txtSelection[playerid], 0);
	}

	return 1;
}

DestroyPlayerTextDraws(playerid = -1)
{
	if(playerid == -1)
	{
		foreach(new playerid2 : Player) DestroyPlayerTextDraws(playerid2);
	}
	else
	{
		PlayerTextDrawDestroy(playerid, txtState[playerid]);
		PlayerTextDrawDestroy(playerid, txtSelection[playerid]);
	}

	return 1;
}
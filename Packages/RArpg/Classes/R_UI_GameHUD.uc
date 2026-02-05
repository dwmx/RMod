//==============================================================================
//	R_UI_GameHUD
//	Game HUD for RArpg
//==============================================================================
class R_UI_GameHUD extends R_RunePlayerHUD;

simulated event PostRender(Canvas C)
{
	Super.PostRender(C);

	DrawSelectionTarget(C);
}

simulated function R_ArpgRunePlayer GetArpgRunePlayer()
{
	local R_ArpgRunePlayer RP;
	RP = R_ArpgRunePlayer(Owner);
	return RP;
}

simulated function DrawSelectionTarget(Canvas C)
{
	local R_ArpgRunePlayer RP;
	local Actor SelectionTarget;

	SelectionTarget = None;
	RP = GetArpgRunePlayer();
	if(RP != None)
	{
		SelectionTarget = RP.GetSelectionTarget();
	}

	if(SelectionTarget == None)
	{
		return;
	}

	C.SetPos(C.ClipX * 0.5, C.ClipY * 0.5);
	C.DrawText("" $ SelectionTarget);
}
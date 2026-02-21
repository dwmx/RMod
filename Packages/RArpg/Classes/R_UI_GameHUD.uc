//==============================================================================
//	R_UI_GameHUD
//	Game HUD for RArpg
//==============================================================================
class R_UI_GameHUD extends R_RunePlayerHUD;

const CanvasLib = Class'RBase.R_ACanvasLibrary';

simulated event PostRender(Canvas C)
{
	Super.PostRender(C);

	DrawSelectionTarget(C);
	DrawInWorldHUD(C);
	DrawExperience(C);
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

	CanvasLib.Static.DrawCircle3D(C, SelectionTarget.Location, Vect(0,0,1), SelectionTarget.CollisionRadius, 32, 1.0, 1.0, 0.0);
}

simulated function DrawInWorldHUD(Canvas C)
{
	local Pawn P;
	local R_ArpgPawn RP;

	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		RP = R_ArpgPawn(P);
		if(RP != None)
		{
			RP.DrawInWorldHUD(C);
		}
	}
}

simulated function DrawExperience(Canvas C)
{
	local R_ArpgPawn RP;

	C.Reset();
	RP = GetArpgRunePlayer().GetControlledPawn();
	if(RP == None)
	{
		return;
	}
	C.SetPos(C.ClipX * 0.5, C.ClipY * 0.9);
	C.Font = C.MedFont;
	C.DrawText(String(RP.GetExperience()));
}
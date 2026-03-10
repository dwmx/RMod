//==============================================================================
//	R_UI_GameHUD
//	Game HUD for RArpg
//==============================================================================
class R_UI_GameHUD extends R_RunePlayerHUD;

const CanvasLib = Class'RBase.R_ACanvasLibrary';

simulated event PostRender(Canvas C)
{
	Super.PostRender(C);

	DrawExperience(C);
}

simulated function R_ArpgPlayerController GetArpgRunePlayer()
{
	local R_ArpgPlayerController RP;
	RP = R_ArpgPlayerController(Owner);
	return RP;
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
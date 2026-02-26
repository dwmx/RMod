class R_ArpgGameInfo extends R_GameInfo;

function Killed( pawn killer, pawn Other, name damageType )
{
	Super.Killed(Killer, Other, DamageType);

	if(R_ArpgPawn(Killer) != None && R_ArpgPawn(Other) != None)
	{
		R_ArpgPawn(Killer).IncrementExperience(50.0);
	}
}

defaultproperties
{
	RunePlayerClass=Class'RArpg.R_ArpgPlayerController'
	HUDType=Class'RArpg.R_UI_GameHUD'
}
class R_ArpgGameInfo extends R_GameInfo;

event PostLogin(PlayerPawn NewPlayer)
{
	local R_ArpgPlayerController PlayerController;

	Super.PostLogin(NewPlayer);

	// Spawn the controlled pawn for the new player
	PlayerController = R_ArpgPlayerController(NewPlayer);
	if(PlayerController != None)
	{
		SpawnPawnForPlayer(PlayerController);
	}
}

function SpawnPawnForPlayer(R_ArpgPlayerController PlayerController)
{
	local R_ArpgPawn NewPawn;

	if(PlayerController == None)
	{
		return;
	}

	NewPawn = Spawn(
		Class'RArpg.R_ArpgPawn_Hero',
		PlayerController,,
		PlayerController.Location + Vect(0,0,1) * 200.0,
		PlayerController.Rotation);
	PlayerController.SetControlledPawn(NewPawn);
}

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
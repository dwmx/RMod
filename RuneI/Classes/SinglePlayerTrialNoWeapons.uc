//=============================================================================
// SinglePlayerTrialNoWeapons.
//=============================================================================
class SinglePlayerTrialNoWeapons extends SinglePlayerTrial;


event AcceptInventory(pawn aPlayer)
{
	local Inventory Inv;
	local Inventory next;

	if (!PlayerPawn(aPlayer).bJustSpawned)	// Only adjust inventory if newly travelled to this level
	{
		Super.AcceptInventory(aPlayer);
		return;
	}

	// Discard all inventory first
	aPlayer.Weapon = None;
	aPlayer.Shield = None;
	PlayerPawn(aPlayer).StowSpot[0] = None;
	PlayerPawn(aPlayer).StowSpot[1] = None;
	PlayerPawn(aPlayer).StowSpot[2] = None;

	for(Inv = aPlayer.Inventory; Inv != None; Inv = next)
	{
		next = Inv.Inventory;
		Inv.Destroy();
	}

	// Remove all RunePower from the player
	aPlayer.RunePower = 0;

	// Refill the player's health (as if he's "rested up")
	aPlayer.Health = aPlayer.MaxHealth;

	AddDefaultInventory( aPlayer );

	log( "All inventory from" @ aPlayer.PlayerReplicationInfo.PlayerName @ "is rejected" );
}

defaultproperties
{
}

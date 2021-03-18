//=============================================================================
// SinglePlayerSRNMHSHKTGPANGFH.
//
// SinglePlayerSarkRagnarNotMuchHealthSoHeKnowsTheGooPoolsAreNowGoodForHim
//=============================================================================
class SinglePlayerSRNMHSHKTGPANGFH extends SinglePlayerSark;


event AcceptInventory(pawn aPlayer)
{
	local Inventory Inv;
	local Inventory next;

	if (!PlayerPawn(aPlayer).bJustSpawned)	// Only adjust inventory if newly travelled to this level
	{
		Super.AcceptInventory(aPlayer);
		return;
	}

	// Remove all RunePower from the player
	aPlayer.RunePower = 0;
	aPlayer.Health = 50;

	log( "All inventory from" @ aPlayer.PlayerReplicationInfo.PlayerName @ "is rejected" );
}

defaultproperties
{
}

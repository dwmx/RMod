//=============================================================================
// MutatorFatBoy
// Players grow fatter as they get killed
//=============================================================================
class MutatorFatBoy expands Mutator;


function ScoreKill(Pawn Killer, Pawn Other)
{
	if ((Killer != Other) && (Other != None) && (Killer != None))
	{
		// Normal kill.
		if (Killer.DesiredFatness >= 240)
			Killer.DesiredFatness = 255;
		else
			Killer.DesiredFatness += 10;

		Other.DesiredFatness -= 10;
		if (Other.DesiredFatness < 60)
			Other.DesiredFatness = 60;
	}
		
	if ( (Other != None) && ((Killer == None) || (Killer == Other)) )
	{
		// Suicide.
		Other.DesiredFatness -= 10;
		if (Other.DesiredFatness < 60)
			Other.DesiredFatness = 60;
	}

	Super.ScoreKill(Killer, Other);
}

defaultproperties
{
}

//=============================================================================
// MutatorLefty
// Players switch handedness upon death
//=============================================================================
class MutatorLefty expands Mutator;


function ScoreKill(Pawn Killer, Pawn Other)
{
	if ((Killer != Other) && (Other != None) && (Killer != None))
	{	// Normal kill.
		Other.bMirrored = !Other.bMirrored;
	}

	if ( (Other != None) && ((Killer == None) || (Killer == Other)) )
	{	// Suicide.
		Other.bMirrored = !Other.bMirrored;
	}

	Super.ScoreKill(Killer, Other);
}

/*
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Pawn'))
		Other.bMirrored = true;

	return true;
}
*/

defaultproperties
{
}

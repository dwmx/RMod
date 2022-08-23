//=============================================================================
// MutatorLowGrav
// makes all zones low gravity
//=============================================================================
class MutatorLowGrav expands Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('ZoneInfo'))
	{
		ZoneInfo(Other).ZoneGravity = vect(0,0,-200);
	}

	Level.ZoneGravity = vect(0,0,-500);
	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}

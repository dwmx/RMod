//=============================================================================
// MutatorNoRunes.
// Powerups, Berzerk, and RuneHealth not allowed.
//=============================================================================
class MutatorNoRunes expands Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon'))
	{
		Weapon(Other).bCanBePoweredUp = false;
	}
	
	else if(Other.IsA('Runes'))
	{
		return false;
	}

	return true;
}

defaultproperties
{
}

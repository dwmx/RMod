//=============================================================================
// MutatorNoPowerups
// Powerups are not allowed
//=============================================================================
class MutatorNoPowerups expands Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon'))
	{
		Weapon(Other).bCanBePoweredUp = false;
	}
	
	else
	
	if(Other.IsA('RuneOfPower') || Other.IsA('RuneOfPowerRefill'))
	{
		return false;
	}

	return true;
}

defaultproperties
{
}

//=============================================================================
// MutatorInfinitePowerups
// all powerups last forever
//=============================================================================
class MutatorInfinitePowerups expands Mutator;

function ModifyPlayer(Pawn Other)
{
		RunePlayer(Other).RunePower = 100;
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon') && Weapon(Other).bCanBePoweredUp)
	{
		Weapon(Other).RunePowerDuration = 500;
		Weapon(Other).RunePowerRequired = 0;
	}
	else if(Other.IsA('RuneOfPower') || Other.IsA('RuneOfPowerRefill'))
		return false;

	return true;
}

defaultproperties
{
}

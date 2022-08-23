//=============================================================================
// MutatorLowDamage
// Weapons do lower damage amount
//=============================================================================
class MutatorLowDamage expands Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Axe') || Other.IsA('Hammer') || Other.IsA('Sword'))
	{
		Weapon(Other).Damage = float(Weapon(Other).Damage)*0.5;
		Weapon(Other).Damage = Clamp(Weapon(Other).Damage, 1, 100);
	}

	return true;
}

defaultproperties
{
}

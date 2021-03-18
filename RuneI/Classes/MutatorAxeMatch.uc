//=============================================================================
// MutatorAxeMatch
// All players start with a battle axe, no other weapons allowed
//=============================================================================
class MutatorAxeMatch expands Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon') && !Other.IsA('DwarfBattleAxe'))
		return false;

	if (Other.IsA('Shield') && !Other.IsA('DwarfBattleShield'))
		return false;

	return true;
}

function bool AllowWeaponDrop()
{
	return false;
}

function bool AllowShieldDrop()
{
	return false;
}

defaultproperties
{
     DefaultWeapon=Class'RuneI.DwarfBattleAxe'
     DefaultShield=Class'RuneI.DwarfBattleShield'
}

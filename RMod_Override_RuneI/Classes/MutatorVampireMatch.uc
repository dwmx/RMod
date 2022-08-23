//=============================================================================
// MutatorVampireMatch
// All players start with a vampiric broad sword, no other weapons allowed
//=============================================================================
class MutatorVampireMatch expands Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon') && !Other.IsA('VikingBroadSword'))
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
     DefaultWeapon=Class'RuneI.VikingBroadSword'
     DefaultShield=Class'RuneI.DwarfBattleShield'
}

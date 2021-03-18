//=============================================================================
// MutatorRandWeapon
// All players start with a random default weapon
//=============================================================================
class MutatorRandWeapon expands Mutator;


function PreBeginPlay()
{
	// Choose default weapon
	switch(Rand(15))
	{
		// Axes
		case 0:		DefaultWeapon = class'runei.handaxe';			break;
		case 1:		DefaultWeapon = class'runei.goblinaxe';			break;
		case 2:		DefaultWeapon = class'runei.vikingaxe';			break;
		case 3:		DefaultWeapon = class'runei.sigurdaxe';			break;
		case 4:		DefaultWeapon = class'runei.dwarfbattleaxe';	break;

		// Swords
		case 5:		DefaultWeapon = class'runei.vikingshortsword';	break;
		case 6:		DefaultWeapon = class'runei.romansword';		break;
		case 7:		DefaultWeapon = class'runei.vikingbroadsword';	break;
		case 8:		DefaultWeapon = class'runei.dwarfworksword';	break;
		case 9:		DefaultWeapon = class'runei.dwarfbattlesword';	break;

		// Hammers
		case 10:	DefaultWeapon = class'runei.boneclub';			break;
		case 11:	DefaultWeapon = class'runei.rustymace';			break;
		case 12:	DefaultWeapon = class'runei.trialpitmace';		break;
		case 13:	DefaultWeapon = class'runei.dwarfworkhammer';	break;
		case 14:	DefaultWeapon = class'runei.dwarfbattlehammer';	break;
	}

	// Choose default shield
	switch(Rand(7))
	{
		case 0:		DefaultShield = class'runei.waterloggedshield';	break;
		case 1:		DefaultShield = class'runei.goblinshield';		break;
		case 2:		DefaultShield = class'runei.dwarfwoodshield';	break;
		case 3:		DefaultShield = class'runei.darkshield';		break;
		case 4:		DefaultShield = class'runei.dwarfbattleshield';	break;
		case 5:		DefaultShield = class'runei.vikingshield';		break;
		case 6:		DefaultShield = class'runei.vikingshield2';		break;
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('Weapon') && Other.Class != DefaultWeapon)
	{
		return false;
	}

	if (Other.IsA('Shield') && Other.Class != DefaultShield)
	{
		return false;
	}

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
}

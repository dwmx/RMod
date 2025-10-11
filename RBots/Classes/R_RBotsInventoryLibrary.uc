//==============================================================================
//	R_RBotsInventoryLibrary
//	Inventory related library functions for RBots
//==============================================================================
class R_RBotsInventoryLibrary extends R_RBotsObject abstract;

const PickupType_None = -1;
const PickupType_Weapon = 0;
const PickupType_Shield = 1;
const PickupType_Health = 2;
const PickupType_Strength = 3;
const PickupType_RunePower = 4;

const PickupTypeArraySize = 4;
var private Class PickupTypes_Weapon[4];
var private Class PickupTypes_Shield[4];
var private Class PickupTypes_Health[4];
var private Class PickupTypes_Strength[4];
var private Class PickupTypes_RunePower[4];

static function int GetInventoryPickupTypeCode(Inventory Inv)
{
	local int i;

	if(Inv == None)
	{
		return PickupType_None;
	}

	for(i = 0; i < PickupTypeArraySize; ++i)
	{
		if(ClassIsChildOf(Inv.Class, Default.PickupTypes_Weapon[i]))	{ return PickupType_Weapon; }
		if(ClassIsChildOf(Inv.Class, Default.PickupTypes_Shield[i]))	{ return PickupType_Shield; }
		if(ClassIsChildOf(Inv.Class, Default.PickupTypes_Health[i]))	{ return PickupType_Health; }
		if(ClassIsChildOf(Inv.Class, Default.PickupTypes_Strength[i]))	{ return PickupType_Strength; }
		if(ClassIsChildOf(Inv.Class, Default.PickupTypes_RunePower[i]))	{ return PickupType_RunePower; }
	}

	return PickupType_None;
}

defaultproperties
{
	PickupTypes_Weapon(0)=Class'Engine.Weapon'
	PickupTypes_Shield(0)=Class'Engine.Shield'
	PickupTypes_Health(0)=Class'RuneI.Food'
	PickupTypes_Health(1)=Class'RuneI.RuneOfHealth'
	PickupTypes_Strength(0)=Class'RuneI.RuneOfStrength'
	PickupTypes_Strength(1)=Class'RuneI.RuneOfStrengthRefill'
	PickupTypes_RunePower(0)=Class'RuneI.RuneOfPower'
	PickupTypes_RunePower(1)=Class'RuneI.RuneOfPowerRefill'
}
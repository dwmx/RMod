//=============================================================================
// DwarfUnderground.
//=============================================================================
class DwarfUnderground expands Dwarf;
//abstract;	// use individual child classes

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_SHIELD;
}


//============================================================
//
// LimbPassThrough
//
// Determines what damage is passed through to body
//============================================================
function int LimbPassThrough(int BodyPart, int Blunt, int Sever)
{
	if (BodyPart == BODYPART_BODY)	// Falling damage, etc.
		return Blunt;

	return Blunt;	// Armor protects from sever damage
}

defaultproperties
{
     StartWeapon=Class'RuneI.DwarfBattleHammer'
}

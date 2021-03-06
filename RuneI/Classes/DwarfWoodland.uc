//=============================================================================
// DwarfWoodland.
//=============================================================================
class DwarfWoodland expands Dwarf;


//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
			break;
		case BODYPART_LARM1:
			return class'WoodDwarfLArm';
		case BODYPART_RARM1:
			return class'WoodDwarfRArm';
		case BODYPART_HEAD:
			return class'WoodDwarfAHead';
			break;
	}

	return None;
}


//================================================
//
// BodyPartForPolyGroup
//
//================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 1: case 4: case 7:
		case 5: case 6:	case 8:	return BODYPART_TORSO;
		case 2: case 12:		return BODYPART_HEAD;
		case 3:					return BODYPART_RARM1;
		case 11:				return BODYPART_LARM1;
		case 9:					return BODYPART_RLEG1;
		case 10:				return BODYPART_LLEG1;
		default:				return BODYPART_BODY;
	}
}

//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[8] = Texture'runefx.w_neckgore';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
	}
}

//================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			SkelGroupSkins[1] = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[4] = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[7] = Texture'creatures.dwarfw_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[2] = Texture'creatures.dwarfw_bodypain';
			SkelGroupSkins[12] = Texture'creatures.dwarfw_facepain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'creatures.dwarfw_armpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[3] = Texture'creatures.dwarfw_armpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[10] = Texture'creatures.dwarfw_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[9] = Texture'creatures.dwarfw_legpain';
			break;
	}
	return None;
}

defaultproperties
{
     Health=100
}

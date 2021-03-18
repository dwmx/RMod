//=============================================================================
// Sven.
//=============================================================================
class Sven expands Viking;

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================

function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			SkelGroupSkins[1] = Texture'players.ragnarsven_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'players.ragnarsven_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[8] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[7] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[12] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[13] = Texture'players.ragnarwolf_armlegpain';
			break;
	}
	return None;
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================

function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 4:								return BODYPART_HEAD;
		case 8: 							return BODYPART_LARM1;
		case 7:								return BODYPART_RARM1;
		case 3: case 12:					return BODYPART_LLEG1;
		case 2:	case 13:					return BODYPART_RLEG1;
		case 1: case 6: case 9: case 11:
			case 5: case 10:				return BODYPART_TORSO;
	}
	return BODYPART_BODY;
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
			SkelGroupSkins[9] = Texture'runefx.gore_bone';
			SkelGroupFlags[9] = SkelGroupFlags[9] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'runefx.gore_bone';
			SkelGroupFlags[11] = SkelGroupFlags[11] & ~POLYFLAG_INVISIBLE;
			break;
	}
}

//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			return class'WolfLArm';
		case BODYPART_RARM1:
			return class'WolfRArm';
		case BODYPART_HEAD:
			return class'SvenHead';
			break;
	}

	return None;
}

defaultproperties
{
     AmbientWaitSoundDelay=9.000000
     AmbientFightSoundDelay=6.000000
     HitSound1=Sound'CreaturesSnd.Vikings.vike2hit01'
     HitSound2=Sound'CreaturesSnd.Vikings.vike2hit02'
     HitSound3=Sound'CreaturesSnd.Vikings.vike2hit03'
     Die=Sound'CreaturesSnd.Vikings.vike2death01'
     Die2=Sound'CreaturesSnd.Vikings.vike2death02'
     Die3=Sound'CreaturesSnd.Vikings.vike2death03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     LODDistMax=6000.000000
     LODCurve=LOD_CURVE_CONSERVATIVE
     SkelMesh=8
}

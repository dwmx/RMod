//=============================================================================
// Sigurd.
//=============================================================================
class Sigurd expands Viking;

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
			SkelGroupSkins[1] = Texture'players.ragnarsig_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'players.ragnarsig_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[9] = Texture'players.ragnarsig_armlegpain';
			SkelGroupSkins[10] = Texture'players.ragnarsig_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'players.ragnarsig_armlegpain';
			SkelGroupSkins[5] = Texture'players.ragnarsig_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarsig_armlegpain';
			SkelGroupSkins[13] = Texture'players.ragnarsig_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[4] = Texture'players.ragnarsig_armlegpain';
			SkelGroupSkins[14] = Texture'players.ragnarsig_armlegpain';
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
		case 11:							return BODYPART_HEAD;
		case 10:							return BODYPART_LARM1;
		case 5:								return BODYPART_RARM1;
		case 3: case 13:					return BODYPART_LLEG1;
		case 4:	case 14:					return BODYPART_RLEG1;
		case 1: case 2: case 6: case 7: case 8:
			case 9: case 12:				return BODYPART_TORSO;
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
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[12] = Texture'players.ragnarsig_neckgore';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
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
			return class'SigurdLArm';
		case BODYPART_RARM1:
			return class'SigurdRArm';
		case BODYPART_HEAD:
			return class'SigurdHead';
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
     SkelMesh=6
}

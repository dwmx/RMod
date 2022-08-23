//=============================================================================
// Ulf.
//=============================================================================
class Ulf expands Viking;

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
			SkelGroupSkins[3] = Texture'players.ragnarwolf_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[13] = Texture'players.ragnarulf_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[12] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[11] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[8] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[7] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[9] = Texture'players.ragnarwolf_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarwolf_armlegpain';
			SkelGroupSkins[5] = Texture'players.ragnarwolf_armlegpain';
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
		case 13:							return BODYPART_HEAD;
		case 11: 							return BODYPART_LARM1;
		case 7: 							return BODYPART_RARM1;
		case 2: case 9:						return BODYPART_LLEG1;
		case 1:	case 5:						return BODYPART_RLEG1;
		case 3: case 4: case 6: case 8: 
			case 10: case 12: 				return BODYPART_TORSO;
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
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
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
			return class'UlfHead';
			break;
	}

	return None;
}

defaultproperties
{
     AmbientWaitSoundDelay=9.000000
     AmbientFightSoundDelay=6.000000
     HitSound1=Sound'CreaturesSnd.Vikings.ulfhit01'
     HitSound2=Sound'CreaturesSnd.Vikings.ulfhit02'
     HitSound3=Sound'CreaturesSnd.Vikings.ulfhit03'
     Die=Sound'CreaturesSnd.Vikings.ulfdeath01'
     Die2=Sound'CreaturesSnd.Vikings.ulfdeath01'
     Die3=Sound'CreaturesSnd.Vikings.ulfdeath01'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=9
}

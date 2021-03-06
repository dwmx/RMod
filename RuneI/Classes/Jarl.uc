//=============================================================================
// Jarl.
//=============================================================================
class Jarl expands Viking;

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
			SkelGroupSkins[1] = Texture'players.ragnarjarl_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[5] = Texture'players.ragnarjarl_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'players.ragnarjarl_armlegpain';
			SkelGroupSkins[9] = Texture'players.ragnarjarl_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'players.ragnarjarl_armlegpain';
			SkelGroupSkins[8] = Texture'players.ragnarjarl_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarjarl_armlegpain';
			SkelGroupSkins[12] = Texture'players.ragnarjarl_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarjarl_armlegpain';
			SkelGroupSkins[13] = Texture'players.ragnarjarl_armlegpain';
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
		case 5:								return BODYPART_HEAD;
		case 9:								return BODYPART_LARM1;
		case 8:								return BODYPART_RARM1;
		case 3: case 12:					return BODYPART_LLEG1;
		case 2:	case 13:					return BODYPART_RLEG1;
		case 1: case 4: case 7: case 10:
			case 6: case 11:				return BODYPART_TORSO;
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
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
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
			return class'KarlLArm';
		case BODYPART_RARM1:
			return class'KarlRArm';
		case BODYPART_HEAD:
			return class'KarlHead';
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
     SkelMesh=4
     SkelGroupSkins(1)=Texture'Players.Ragnarjarl_chest'
     SkelGroupSkins(2)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarjarl_head'
     SkelGroupSkins(6)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnarjarl_armleg'
     SkelGroupSkins(13)=Texture'Players.Ragnarjarl_armleg'
}

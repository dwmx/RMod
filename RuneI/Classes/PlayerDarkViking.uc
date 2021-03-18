//=============================================================================
// PlayerDarkViking.
//=============================================================================
class PlayerDarkViking expands RunePlayer;

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
			SkelGroupSkins[2] = Texture'players.ragnardv_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[3] = Texture'players.ragnardv_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnardv_armlegpain';
			SkelGroupSkins[12] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'players.ragnardv_armlegpain';
			SkelGroupSkins[11] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[1] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[4] = Texture'players.ragnardv_armlegpain';
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
		case 3: case 5:						return BODYPART_HEAD;
		case 12:							return BODYPART_LARM1;
		case 11:							return BODYPART_RARM1;
		case 1:								return BODYPART_LLEG1;
		case 4:								return BODYPART_RLEG1;
		case 2: case 6: case 7: case 8: 
			case 9:	case 10: 				return BODYPART_TORSO;
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
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
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
			return class'DarkVikingLArm';
		case BODYPART_RARM1:
			return class'DarkVikingRArm';
		case BODYPART_HEAD:
			return class'DarkVikingHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.darkhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.darkhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.darkhit03'
     CarcassType=Class'RuneI.PlayerDarkVikingCarcass'
     Die=Sound'CreaturesSnd.Vikings.darkdeath01'
     Die2=Sound'CreaturesSnd.Vikings.darkdeath02'
     Die3=Sound'CreaturesSnd.Vikings.darkdeath03'
     SkelMesh=1
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnardv_body'
     SkelGroupSkins(3)=Texture'Players.Ragnardv_head'
     SkelGroupSkins(4)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnardv_hair'
     SkelGroupSkins(6)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(7)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(9)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnardv_armleg'
     SkelGroupSkins(13)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragd_arms'
}

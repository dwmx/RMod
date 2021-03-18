//=============================================================================
// PlayerBerserker.
//=============================================================================
class PlayerBerserker expands RunePlayer;

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
			SkelGroupSkins[4] = Texture'players.ragnarb_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[2] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[3] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[7] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[14] = Texture'players.ragnarb_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'players.ragnarb_armspain';
			SkelGroupSkins[13] = Texture'players.ragnarb_armspain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[10] = Texture'players.ragnarb_armspain';
			SkelGroupSkins[12] = Texture'players.ragnarb_armspain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[6] = Texture'players.ragnarb_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[5] = Texture'players.ragnarb_legpain';
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
		case 1: case 2: case 3: case 14:	return BODYPART_HEAD;
		case 13:							return BODYPART_LARM1;
		case 12:							return BODYPART_RARM1;
		case 6:								return BODYPART_LLEG1;
		case 5:								return BODYPART_RLEG1;
		case 4: case 7: case 8: case 9:
		case 10: case 11: case 15:			return BODYPART_TORSO;
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
			SkelGroupSkins[15] = Texture'players.ragnarb_neckgore';
			SkelGroupFlags[15] = SkelGroupFlags[15] & ~POLYFLAG_INVISIBLE;
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
			return class'BerserkerLArm';
		case BODYPART_RARM1:
			return class'BerserkerRArm';
		case BODYPART_HEAD:
			return class'BerserkerHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.berzerkhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.berzerkhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.berzerkhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.berzerkhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.berzerkhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.berzerkhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.berzerkhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.berzerkhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.berzerkhit03'
     CarcassType=Class'RuneI.PlayerBerserkerCarcass'
     Die=Sound'CreaturesSnd.Vikings.berzerkdeath01'
     Die2=Sound'CreaturesSnd.Vikings.berzerkdeath02'
     Die3=Sound'CreaturesSnd.Vikings.berzerkdeath03'
     LandGrunt=Sound'CreaturesSnd.Vikings.berzerkhit01'
     SkelMesh=2
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarb_head'
     SkelGroupSkins(2)=Texture'Players.Ragnarb_head'
     SkelGroupSkins(3)=Texture'Players.Ragnarb_head'
     SkelGroupSkins(4)=Texture'Players.Ragnarb_body'
     SkelGroupSkins(5)=Texture'Players.Ragnarb_leg'
     SkelGroupSkins(6)=Texture'Players.Ragnarb_leg'
     SkelGroupSkins(7)=Texture'Players.Ragnarb_head'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(9)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnarb_arms'
     SkelGroupSkins(11)=Texture'Players.Ragnarb_arms'
     SkelGroupSkins(12)=Texture'Players.Ragnarb_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnarb_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarb_head'
     SkelGroupSkins(15)=Texture'Players.Ragnarb_neckgore'
}

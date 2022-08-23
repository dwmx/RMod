//=============================================================================
// PlayerValkyrie.
//=============================================================================
class PlayerValkyrie expands RunePlayer;


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
			SkelGroupSkins[3] = Texture'players.ragnarwom_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[2] = Texture'players.ragnarwom_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[9] = Texture'players.ragnarwom_bodypain';
			SkelGroupSkins[10] = Texture'players.ragnarwom_bodypain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[4] = Texture'players.ragnarwom_bodypain';
			SkelGroupSkins[5] = Texture'players.ragnarwom_bodypain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[7] = Texture'players.ragnarwom_bodypain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarwom_bodypain';
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
		case 2:								return BODYPART_HEAD;
		case 9: 							return BODYPART_LARM1;
		case 5: 							return BODYPART_RARM1;
		case 7:								return BODYPART_LLEG1;
		case 1:								return BODYPART_RLEG1;
		case 3: case 4: case 6:
		case 8:	case 10: case 11:			return BODYPART_TORSO;
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
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
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
		case BODYPART_RARM1:
			return class'WomanArm';
		case BODYPART_HEAD:
			return class'WomanHead';
	}

	return None;
}

defaultproperties
{
     Die4=Sound'CreaturesSnd.Val.valdeath01'
     JumpGruntSound(1)=Sound'CreaturesSnd.Ragnar.ragjump03'
     KickSound=Sound'CreaturesSnd.Val.valhit01'
     HitSoundLow(0)=Sound'CreaturesSnd.Val.valhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Val.valhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Val.valhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Val.valhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Val.valhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Val.valhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Val.valhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Val.valhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Val.valhit03'
     BerserkSoundLoop=None
     BerserkYellSound(0)=Sound'CreaturesSnd.Val.valattack01'
     BerserkYellSound(1)=Sound'CreaturesSnd.Val.valattack02'
     BerserkYellSound(2)=Sound'CreaturesSnd.Val.valattack03'
     BerserkYellSound(3)=Sound'CreaturesSnd.Val.valattack04'
     BerserkYellSound(4)=Sound'CreaturesSnd.Val.valattack05'
     BerserkYellSound(5)=Sound'CreaturesSnd.Val.valattack05'
     CarcassType=Class'RuneI.PlayerValkyrieCarcass'
     Die=Sound'CreaturesSnd.Val.valdeath01'
     Die2=Sound'CreaturesSnd.Val.valdeath02'
     Die3=Sound'CreaturesSnd.Val.valdeath03'
     SkelMesh=22
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(2)=Texture'Players.Ragnarwom_head'
     SkelGroupSkins(3)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(4)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(5)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(6)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(7)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(8)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(9)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(10)=Texture'Players.Ragnarwom_body'
     SkelGroupSkins(11)=Texture'Players.Ragnarwom_body'
}

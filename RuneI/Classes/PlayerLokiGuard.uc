//=============================================================================
// PlayerLokiGuard.
//=============================================================================
class PlayerLokiGuard expands RunePlayer;

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
			SkelGroupSkins[2] = Texture'players.ragnarlg_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'players.ragnarlg_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[8] = Texture'players.ragnarlg_armpain';
			SkelGroupSkins[11] = Texture'players.ragnarlg_armpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnarlg_armpain';
			SkelGroupSkins[4] = Texture'players.ragnarlg_armpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarlg_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarlg_legpain';
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
		case 10:							return BODYPART_HEAD;
		case 11:							return BODYPART_LARM1;
		case 4: 							return BODYPART_RARM1;
		case 3:								return BODYPART_LLEG1;
		case 1:								return BODYPART_RLEG1;
		case 2: case 5: case 6: case 7:
			case 8: case 9: 				return BODYPART_TORSO;
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
			SkelGroupSkins[12] = Texture'runefx.gore_bone';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
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
			return class'GuardLArm';
		case BODYPART_RARM1:
			return class'GuardRArm';
		case BODYPART_HEAD:
			return class'GuardHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.guardhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.guardhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.guardhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.guardhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.guardhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.guardhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.guardhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.guardhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.guardhit03'
     CarcassType=Class'RuneI.PlayerLokiGuardCarcass'
     Die=Sound'CreaturesSnd.Vikings.guarddeath01'
     Die2=Sound'CreaturesSnd.Vikings.guarddeath02'
     Die3=Sound'CreaturesSnd.Vikings.guarddeath03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=5
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarlg_leg'
     SkelGroupSkins(2)=Texture'Players.Ragnarlg_body'
     SkelGroupSkins(3)=Texture'Players.Ragnarlg_leg'
     SkelGroupSkins(4)=Texture'Players.Ragnarlg_rarm'
     SkelGroupSkins(5)=Texture'Players.Ragnarlg_rarm'
     SkelGroupSkins(6)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarlg_rarm'
     SkelGroupSkins(9)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnarlg_head'
     SkelGroupSkins(11)=Texture'Players.Ragnarlg_rarm'
     SkelGroupSkins(12)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragd_arms'
}

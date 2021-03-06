//=============================================================================
// Elder.
//=============================================================================
class Elder expands Viking;

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
			SkelGroupSkins[6] = Texture'players.ragnareld_armrobepain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'players.ragnareld_cowlfootpain';
			SkelGroupSkins[7] = Texture'players.ragnareld_cowlfootpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[4] = Texture'players.ragnareld_armrobepain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnareld_armrobepain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnareld_cowlfootpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[3] = Texture'players.ragnareld_cowlfootpain';
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
		case 7:								return BODYPART_HEAD;
		case 4: 							return BODYPART_LARM1;
		case 5: 							return BODYPART_RARM1;
		case 2:								return BODYPART_LLEG1;
		case 3:								return BODYPART_RLEG1;
		case 1: case 6: case 8:				return BODYPART_TORSO;
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
		case BODYPART_HEAD:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
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
			return class'ElderArm';
		case BODYPART_HEAD:
			return class'ElderHead';
	}

	return None;
}

//============================================================
//
// BodyPartSeverable
//
//============================================================
function bool BodyPartSeverable(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_RARM1:
		case BODYPART_HEAD:
			return true;
	}
	return false;
}

defaultproperties
{
     StartStowWeapon=None
     AmbientWaitSoundDelay=9.000000
     AmbientFightSoundDelay=6.000000
     StartShield=None
     HitSound1=Sound'CreaturesSnd.Vikings.ulfhit01'
     HitSound2=Sound'CreaturesSnd.Vikings.ulfhit02'
     HitSound3=Sound'CreaturesSnd.Vikings.ulfhit03'
     Die=Sound'CreaturesSnd.Vikings.ulfdeath01'
     Die2=Sound'CreaturesSnd.Vikings.ulfdeath01'
     Die3=Sound'CreaturesSnd.Vikings.ulfdeath01'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=15
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnareld_cowlfoot'
     SkelGroupSkins(2)=Texture'Players.Ragnareld_cowlfoot'
     SkelGroupSkins(3)=Texture'Players.Ragnareld_cowlfoot'
     SkelGroupSkins(4)=Texture'Players.Ragnareld_armrobe'
     SkelGroupSkins(5)=Texture'Players.Ragnareld_armrobe'
     SkelGroupSkins(6)=Texture'Players.Ragnareld_armrobe'
     SkelGroupSkins(7)=Texture'Players.Ragnareld_cowlfoot'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_arms'
}

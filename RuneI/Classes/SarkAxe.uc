//=============================================================================
// SarkAxe.
//=============================================================================
class SarkAxe expands Sark;


//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

	f = Spawn(Class'SarkEyeAxe');
	AttachActorToJoint(f, JointNamed('head'));
}

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
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
		case 1: case 14:		return BODYPART_LLEG1;
		case 2: case 7:			return BODYPART_RLEG1;
		case 5:					return BODYPART_HEAD;
		case 6: case 8:			return BODYPART_RARM1;
		case 11: case 13:		return BODYPART_LARM1;
		case 3: case 4: case 9:
		case 10: case 12:		return BODYPART_TORSO;
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
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
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
			return class'AxeSarkArm';
		case BODYPART_HEAD:
			return class'SarkAxeHead';
	}

	return None;
}

defaultproperties
{
     JumpSound=Sound'CreaturesSnd.Sark.sark4jump01'
     AcquireSound=Sound'CreaturesSnd.Sark.sark4see'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Sark.sark4ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Sark.sark4ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Sark.sark4ambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Sark.sark4attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Sark.sark4attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Sark.sark4attack03'
     AmbientWaitSoundDelay=8.000000
     AmbientFightSoundDelay=5.000000
     StartWeapon=Class'RuneI.DwarfBattleAxe'
     Health=350
     HitSound1=Sound'CreaturesSnd.Sark.sark4hit01'
     HitSound2=Sound'CreaturesSnd.Sark.sark4hit02'
     HitSound3=Sound'CreaturesSnd.Sark.sark4hit03'
     Die=Sound'CreaturesSnd.Sark.sark4death01'
     Die2=Sound'CreaturesSnd.Sark.sark4death02'
     Die3=Sound'CreaturesSnd.Sark.sark4death03'
     LandSoundWood=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundMetal=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundStone=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundFlesh=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundIce=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundSnow=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundEarth=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundWater=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundMud=Sound'CreaturesSnd.Sark.sarkland03'
     LandSoundLava=Sound'CreaturesSnd.Sark.sarkland03'
     SkelMesh=17
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarss_torso'
     SkelGroupSkins(4)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(5)=Texture'Players.Ragnarsa_head'
     SkelGroupSkins(6)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(8)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(9)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(10)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(11)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(13)=Texture'Players.Ragnarsa_armor'
     SkelGroupSkins(14)=Texture'Players.Ragnarsa_armor'
}

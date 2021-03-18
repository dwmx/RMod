//=============================================================================
// SarkSpawn.
//=============================================================================
class SarkSpawn expands Sark;


//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

	f = Spawn(Class'SarkEyeNone');
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
		case 2:					return BODYPART_LLEG1;
		case 3:					return BODYPART_RLEG1;
		case 5:					return BODYPART_LARM1;
		case 10:				return BODYPART_RARM1;
		case 4: case 6: case 7:
		case 8: case 9: case 11:return BODYPART_TORSO;
		case 1:					return BODYPART_HEAD;
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
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[9] = Texture'runefx.gore_bone';
			SkelGroupFlags[9] = SkelGroupFlags[9] & ~POLYFLAG_INVISIBLE;
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
			return class'SarkArm';
		case BODYPART_HEAD:
			return class'SarkHead';
	}
	return None;
}

defaultproperties
{
     JumpSound=Sound'CreaturesSnd.Sark.sark1jump01'
     AcquireSound=Sound'CreaturesSnd.Sark.sark1see'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Sark.sark1ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Sark.sark1ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Sark.sark1ambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Sark.sark1attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Sark.sark1attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Sark.sark1attack03'
     AmbientWaitSoundDelay=10.000000
     AmbientFightSoundDelay=7.000000
     StartWeapon=Class'RuneI.SarkClaw'
     HitSound1=Sound'CreaturesSnd.Sark.sark1hit01'
     HitSound2=Sound'CreaturesSnd.Sark.sark1hit02'
     HitSound3=Sound'CreaturesSnd.Sark.sark1hit03'
     Die=Sound'CreaturesSnd.Sark.sark1death01'
     Die2=Sound'CreaturesSnd.Sark.sark1death02'
     Die3=Sound'CreaturesSnd.Sark.sark1death03'
     LandSoundWood=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundMetal=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundStone=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundFlesh=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundIce=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundSnow=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundEarth=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundWater=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundMud=Sound'CreaturesSnd.Sark.sarkland01'
     LandSoundLava=Sound'CreaturesSnd.Sark.sarkland01'
     SkelMesh=12
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarss_head'
     SkelGroupSkins(2)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarss_torso'
     SkelGroupSkins(5)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarss_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarragd_arms'
}

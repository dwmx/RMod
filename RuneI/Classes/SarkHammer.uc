//=============================================================================
// SarkHammer.
//=============================================================================
class SarkHammer expands Sark;


//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

	f = Spawn(Class'SarkEyeHammer');
	AttachActorToJoint(f, JointNamed('head'));
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
		case 8: case 9:				return BODYPART_LLEG1;
		case 4: case 5:				return BODYPART_RLEG1;
		case 11:					return BODYPART_HEAD;
		case 3: case 6:				return BODYPART_RARM1;
		case 7: case 10:			return BODYPART_LARM1;
		case 1: case 2: case 12:	return BODYPART_TORSO;
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
			SkelGroupSkins[1] = Texture'runefx.gore_bone';
			SkelGroupFlags[1] = SkelGroupFlags[1] & ~POLYFLAG_INVISIBLE;
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
			return class'SarkHammerArm';
		case BODYPART_HEAD:
			return class'SarkHammerHead';
	}
	return None;
}

defaultproperties
{
     JumpSound=Sound'CreaturesSnd.Sark.sark3jump01'
     AcquireSound=Sound'CreaturesSnd.Sark.sark3see'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Sark.sark3ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Sark.sark3ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Sark.sark3ambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Sark.sark3attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Sark.sark3attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Sark.sark3attack03'
     AmbientWaitSoundDelay=9.000000
     AmbientFightSoundDelay=6.000000
     StartWeapon=Class'RuneI.DwarfBattleHammer'
     Health=400
     HitSound1=Sound'CreaturesSnd.Sark.sark3hit01'
     HitSound2=Sound'CreaturesSnd.Sark.sark3hit02'
     HitSound3=Sound'CreaturesSnd.Sark.sark3hit03'
     Die=Sound'CreaturesSnd.Sark.sark3death01'
     Die2=Sound'CreaturesSnd.Sark.sark3death02'
     Die3=Sound'CreaturesSnd.Sark.sark3death03'
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
     SkelMesh=21
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(2)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(3)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(4)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(6)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(8)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(10)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarsh_head'
     SkelGroupSkins(12)=Texture'Players.Ragnarsh_chest'
}

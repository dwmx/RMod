//=============================================================================
// SnowBeastTrial.
//=============================================================================
class SnowBeastTrial expands SnowBeast;

/*	DESCRIPTION:
		Encountered in the trial pit, is bigger than snowbeast.  Ledges
		will exist and other ways of getting above him.  Best strategy
		is to jump from above and land on his back bash him with the
		trial pit mace.
		
		trial pit mace is the preferred weapon for killing him.

		TODO:
			allow landing on his back
*/

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
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'creatures.snowbeasttp_bodypain';
			SkelGroupSkins[8] = Texture'creatures.snowbeasttp_bodypain';
			SkelGroupSkins[4] = Texture'creatures.snowbeasttp_bodypain';//teeth
			SkelGroupSkins[5] = Texture'creatures.snowbeasttp_bodypain';
			break;
		case BODYPART_TORSO:
			SkelGroupSkins[3] = Texture'creatures.snowbeasttp_bodypain';
			SkelGroupSkins[6] = Texture'creatures.snowbeasttp_bodypain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'creatures.snowbeasttp_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[9] = Texture'creatures.snowbeasttp_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[7] = Texture'creatures.snowbeasttp_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'creatures.snowbeasttp_armlegpain';
			break;
	}
	return None;
}

defaultproperties
{
     HowlingSound=Sound'CreaturesSnd.SnowBeast.beastyell01'
     BreathSound=Sound'CreaturesSnd.SnowBeast.beastbreath04'
     AcquireSound=Sound'CreaturesSnd.SnowBeast.beastyell11'
     AmbientFightSounds(0)=Sound'CreaturesSnd.SnowBeast.beastattack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.SnowBeast.beastattack05'
     AmbientFightSounds(2)=Sound'CreaturesSnd.SnowBeast.beastattack06'
     bIsBoss=True
     GroundSpeed=411.000000
     WalkingSpeed=160.500000
     HitSound1=Sound'CreaturesSnd.SnowBeast.beasthit02'
     HitSound2=Sound'CreaturesSnd.SnowBeast.beastdeath03'
     HitSound3=Sound'CreaturesSnd.SnowBeast.beasthit04'
     Die2=Sound'CreaturesSnd.SnowBeast.beastdeath03'
     Die3=Sound'CreaturesSnd.SnowBeast.beastyell06'
     FootStepWood(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepWood(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepWood(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepMetal(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepMetal(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepMetal(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepStone(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepStone(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepStone(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepFlesh(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepFlesh(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepFlesh(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepIce(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepIce(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepIce(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepEarth(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepEarth(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepEarth(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepSnow(0)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepSnow(1)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     FootStepSnow(2)=Sound'CreaturesSnd.SnowBeast.beastfootstep02'
     DrawScale=1.500000
     CollisionRadius=60.000000
     CollisionHeight=69.500000
     SkelMesh=1
}

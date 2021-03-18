//=============================================================================
// TubestrikerTongue.
//=============================================================================
class TubestrikerTongue expands InvisibleWeapon;



//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================
function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;

	// Determine what kind of matter was hit
	if ((HitActor.Skeletal != None) && (LowMask!=0 || HighMask!=0))
	{
		for (j=0; j<HitActor.NumJoints(); j++)
		{
			if (((j <  32) && ((LowMask  & (1 <<  j      )) != 0)) ||
				((j >= 32) && (j < 64) && ((HighMask & (1 << (j - 32))) != 0)) )
			{	// Joint j was hit
				matter = HitActor.MatterForJoint(j);
				break;
			}
		}
	}
	else if(HitActor.IsA('LevelInfo'))
	{	
		matter = HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	if (HitActor.IsA('Shield'))
		FinishAttack();

	// Create effects
	PlayHitMatterSound(matter);

	switch(matter)
	{
		case MATTER_FLESH:
			if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
				Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
			else
				Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_WOOD:
			break;
		case MATTER_STONE:
			Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_METAL:
			break;
		case MATTER_EARTH:
			break;
		case MATTER_BREAKABLEWOOD:
			break;
		case MATTER_BREAKABLESTONE:
			break;
		case MATTER_WEAPON:
			break;
		case MATTER_SHIELD:
			break;
		case MATTER_ICE:
			break;
		case MATTER_WATER:
			break;
	}
}

defaultproperties
{
     DamageType=Sever
     ThroughAir(0)=Sound'CreaturesSnd.TubeStriker.tubebite01'
     ThroughAir(1)=Sound'CreaturesSnd.TubeStriker.tubebite02'
     ThroughAir(2)=Sound'CreaturesSnd.TubeStriker.tubebite06'
     HitFlesh(0)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitFlesh(1)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitWood(0)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitWood(1)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitStone(0)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitStone(1)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitStone(2)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitMetal(0)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitMetal(1)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitMetal(2)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitDirt(0)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitDirt(1)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitDirt(2)=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitShield=Sound'WeaponsSnd.ImpWood.impactwood02'
     HitBreakableWood=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     HitBreakableStone=Sound'CreaturesSnd.Zombie.zombiearmimp01'
     SheathSound=Sound'WeaponsSnd.Stows.stow05'
     UnsheathSound=Sound'WeaponsSnd.Stows.stow06'
     SwipeClass=Class'RuneI.WeaponSwipePurple'
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.MechClaw'
}

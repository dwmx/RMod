//=============================================================================
// SarkClaw.
//=============================================================================
class SarkClaw expands InvisibleWeapon;


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

	// Create effects
	switch(matter)
	{
		case MATTER_FLESH:
			if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
				Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
			else
				Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));

			i = Rand(NumFleshSounds);
			PlaySound(HitFlesh[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WOOD:
			i = Rand(NumWoodSounds);
			PlaySound(HitWood[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_STONE:
			Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
			i = Rand(NumStoneSounds);
			PlaySound(HitStone[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_METAL:
			i = Rand(NumMetalSounds);
			PlaySound(HitMetal[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_EARTH:
			i = Rand(NumEarthSounds);
			PlaySound(HitDirt[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLEWOOD:
			PlaySound(HitBreakableWood, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLESTONE:
			PlaySound(HitBreakableStone, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WEAPON:
			PlaySound(HitWeapon, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_SHIELD:
			PlaySound(HitShield, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_ICE:
			break;
		case MATTER_WATER:
			break;
	}
}

defaultproperties
{
     Damage=30
     DamageType=Sever
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing02'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe01'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood06'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone05'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactcombo02'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth05'
     HitShield=Sound'WeaponsSnd.Shields.shield15'
     HitWeapon=Sound'WeaponsSnd.Swords.sword15'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SwipeClass=Class'RuneI.WeaponSwipePurple'
     A_Idle=weapon1_idle
     A_Forward=S1_Walk
     A_Backward=weapon1_backup
     A_Forward45Right=S1_Walk45Right
     A_Forward45Left=S1_Walk45Left
     A_Backward45Right=weapon1_backup45Right
     A_Backward45Left=weapon1_backup45Left
     A_StrafeRight=StrafeRight
     A_StrafeLeft=StrafeLeft
     A_AttackA=S1_attackA
     A_AttackAReturn=S1_attackAreturn
     A_AttackB=S1_attackB
     A_AttackBReturn=S1_attackBreturn
     A_AttackStandA=S1_StandingAttackA
     A_AttackStandAReturn=S1_StandingAttackAReturn
     A_AttackStandB=S1_StandingAttackB
     A_AttackStandBReturn=S1_StandingAttackBReturn
     A_PainFront=S1_painFront
     A_PainRight=S1_painBack
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.InvisibleShort'
}

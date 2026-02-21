class R_ArpgWeapon extends Weapon;

function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;
	local vector start, end;
	local texture tex;

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

		//TEST: Wall marks (need graphics)
		//Spawn(class'WallMark',self,,HitLoc, rotator(HitNorm));
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	PlayHitMatterSound(matter);

	// Create effects
	switch(matter)
	{
		case MATTER_FLESH:
			if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
				Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
			else
				Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));

			if(BloodTexture != None && !Region.Zone.bWaterZone && !class'GameInfo'.Default.bVeryLowGore)
			{
				SkelGroupSkins[1] = BloodTexture;
			}
			break;
		case MATTER_WOOD:
			Spawn(class'HitWood',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_STONE:
			Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_METAL:
			Spawn(class'HitMetal',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_EARTH:
			Spawn(class'GroundDust',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_BREAKABLEWOOD:
			break;
		case MATTER_BREAKABLESTONE:
			break;
		case MATTER_WEAPON:
			Spawn(class'HitWeapon',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_SHIELD:
			break;
		case MATTER_ICE:
			Spawn(class'HitIce',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_WATER:
			break;
	}
}

defaultproperties
{
	    EffectRadius=150.000000
     RockCount=15
     DropDelay=0.100000
     StowMesh=1
     Damage=40
     rating=4
     RunePowerRequired=100
     RunePowerDuration=5.000000
     PowerupMessage="Avalanche!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing02'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing05'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshsword10'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood09'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone04'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal12'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth05'
     HitShield=Sound'WeaponsSnd.Shields.shield05'
     HitWeapon=Sound'WeaponsSnd.Swords.sword05'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SheathSound=Sound'WeaponsSnd.Stows.xstow04'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow04'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw03L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart29'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power63L'
     PowerupIcon=Texture'RuneFX2.dsword'
     PowerupIconAnim=Texture'RuneFX2.dsword1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeGray'
     A_Idle=S5_idle
     A_Forward=S4_walk
     A_Backward=S4_backup
     A_Forward45Right=S4_walk45right
     A_Forward45Left=S4_walk45left
     A_Backward45Right=S4_backup45Right
     A_Backward45Left=S4_backup45Left
     A_StrafeRight=S4_strafeRight
     A_StrafeLeft=S4_strafeLeft
     A_AttackA=S5_attackA
     A_AttackAReturn=S5_attackAreturn
     A_AttackB=S5_attackB
     A_AttackBReturn=S5_attackBreturn
     A_AttackC=None
     A_AttackCReturn=None
     A_AttackStandA=S5_StandingAttackA
     A_AttackStandAReturn=S5_StandingAttackAreturn
     A_AttackStandB=S5_StandingAttackB
     A_AttackStandBReturn=S5_StandingAttackBreturn
     A_AttackBackupA=S5_Backupattack
     A_AttackBackupAReturn=None
     A_AttackStrafeRight=S4_StrafeRightAttack
     A_AttackStrafeLeft=S4_StrafeLeftAttack
     A_Throw=S5_Throw
     A_Powerup=S5_Powerup
     A_Defend=None
     A_DefendIdle=None
     A_PainFront=S5_painFront
     A_PainBack=S5_painBack
     A_PainLeft=S5_painLeft
     A_PainRight=S5_painRight
     A_PickupGroundLeft=S5_PickupLeft
     A_PickupHighLeft=S5_PickupLeftHigh
     A_Taunt=s5_taunt
     A_PumpTrigger=S5_PumpTrigger
     A_LeverTrigger=S5_LeverTrigger
     PickupMessage="You have claimed a Dwarven Battle Sword"
     PickupSound=Sound'OtherSnd.Pickups.grab05'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop01'
     Mass=18.000000
     Skeletal=SkelModel'weapons.battlesword'
     SkelGroupSkins(0)=Texture'weapons.battleswordsword'
     SkelGroupSkins(1)=Texture'weapons.battleswordChrome'
     SkelGroupSkins(2)=Texture'weapons.battleswordsword'
}
class R_Weapon_HandAxe extends R_AWeapon_Axe;

//=============================================================================
//
// Powerup: Spirit (translucent/unhittable)
//
// This function is called when the weapon is initially powered up
//=============================================================================
function PowerupInit()
{
    Super.PowerupInit();

    if (Pawn(Owner)!=None)
    {
        Pawn(Owner).bInvisible = true;
        Owner.Style = STY_Translucent;
//		Owner.SetCollision(true, false, false);		// This was causing ragnar to get stuck inside tables
        Owner.ScaleGlow = 0.2;  // also in viewcamera
        Owner.bSweepable = false;                   // I Put this back in to account for missing collision
        Pawn(Owner).ReducedDamageType = 'conventional';
        Pawn(Owner).ReducedDamagePct = 1.0;
    }
}

function PowerupEnded()
{
    Super.PowerupEnded();

    if (Pawn(Owner)!=None)
    {
        Pawn(Owner).bInvisible = Pawn(Owner).Default.bInvisible;
        Owner.Style = Owner.Default.Style;
//		Owner.SetCollision(Owner.Default.bCollideActors, Owner.Default.bBlockActors, Owner.Default.bBlockPlayers);
        Owner.ScaleGlow = 1.0;
        Owner.bSweepable = Owner.Default.bSweepable;
        Pawn(Owner).ReducedDamageType = Pawn(Owner).Default.ReducedDamageType;
        Pawn(Owner).ReducedDamagePct = Pawn(Owner).Default.ReducedDamagePct;
    }
}

defaultproperties
{
     StowMesh=1
     Damage=15
     BloodTexture=Texture'weapons.handaxehandaxe_blood'
     RunePowerRequired=50
     RunePowerDuration=15.000000
     PowerupMessage="Spirit!"
     SweepVector=(Y=0.954000,Z=-0.300000)
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing05'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing11'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe04'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood11'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone06'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal07'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth06'
     HitShield=Sound'WeaponsSnd.Shields.shield11'
     HitWeapon=Sound'WeaponsSnd.Swords.sword11'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow05'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow05'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart37'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power66L'
     PitchDeviation=0.070000
     PowerupIcon=Texture'RuneFX2.haxe'
     PowerupIconAnim=Texture'RuneFX2.haxe1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeRed'
     A_Idle=X1_Idle
     A_AttackA=X1_AttackA
     A_AttackAReturn=X1_AttackAreturn
     A_AttackB=X1_AttackB
     A_AttackBReturn=X1_AttackBreturn
     A_AttackC=X1_AttackC
     A_AttackCReturn=X1_AttackCreturn
     A_AttackStandA=X1_StandingAttackA
     A_AttackStandAReturn=X1_StandingAttackAreturn
     A_AttackStandB=X1_StandingAttackB
     A_AttackStandBReturn=X1_StandingAttackBreturn
     A_AttackBackupB=S1_BackupAttackB
     A_AttackBackupBReturn=S1_BackupAttackBReturn
     A_Throw=X1_Throw
     A_Powerup=X1_Powerup
     A_Defend=X1_DefendTO
     A_DefendIdle=X1_DefendIdle
     A_PainFront=X1_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=X1_PickupLeft
     A_PickupHighLeft=X1_PickupLeftHigh
     A_Taunt=X1_Taunt
     A_PumpTrigger=X1_PumpTrigger
     A_LeverTrigger=X1_LeverTrigger
     PickupMessage="You have found a Hand Axe"
     PickupSound=Sound'OtherSnd.Pickups.grab01'
     DropSound=Sound'WeaponsSnd.Drops.axedrop05'
     CollisionRadius=15.000000
     Skeletal=SkelModel'weapons.handaxe'
     SkelGroupSkins(0)=Texture'weapons.handaxehandaxe'
     SkelGroupSkins(1)=Texture'weapons.handaxehandaxe'
}
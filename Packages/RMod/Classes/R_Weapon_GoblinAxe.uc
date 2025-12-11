class R_Weapon_GoblinAxe extends R_AWeapon_Axe;

//=============================================================================
//
// Powerup: Throw (unlimited throw ammo)
//
// This function is called when the weapon is initially powered up
//=============================================================================
function PowerupInit()
{
    Super.PowerupInit();

    A_AttackA = 'ghostthrow';
    A_AttackAReturn = '';
    A_AttackB = '';

    A_AttackStandA = 'ghostthrow';
    A_AttackStandAReturn = '';
    A_AttackStandB = '';

    A_AttackBackupA = 'ghostthrow';
    A_AttackBackupAReturn = '';
    A_AttackBackupB = '';

    A_AttackStrafeRight = 'ghostthrow';
    A_AttackStrafeLeft = 'ghostthrow';

    DesiredColorAdjust.X = 172;
    DesiredColorAdjust.Y = 133;
    DesiredColorAdjust.Z = 60;  
}

function PowerupEnded()
{
    Super.PowerupEnded();

    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;

    A_AttackA = Default.A_AttackA;
    A_AttackAReturn = Default.A_AttackAReturn;
    A_AttackB = Default.A_AttackB;

    A_AttackStandA = Default.A_AttackStandA;
    A_AttackStandAReturn = Default.A_AttackStandAReturn;
    A_AttackStandB = Default.A_AttackStandB;

    A_AttackBackupA = Default.A_AttackA;
    A_AttackBackupAReturn = Default.A_AttackAReturn;
    A_AttackBackupB = Default.A_AttackB;

    A_AttackStrafeRight = Default.A_AttackStrafeRight;
    A_AttackStrafeLeft = Default.A_AttackStrafeLeft;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.X = 172;
    DesiredColorAdjust.Y = 133;
    DesiredColorAdjust.Z = 60;  
}

function WeaponFire(int SwingCount)
{
    if (bPoweredUp)
    {
        // make sound ?
    }
}

defaultproperties
{
     StowMesh=1
     Damage=15
     BloodTexture=Texture'weapons.goblinaxegoblin_axeBLOOD'
     rating=1
     RunePowerRequired=25
     RunePowerDuration=8.000000
     PowerupMessage="Unlimited Throw!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing21'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing12'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe02'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood04'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone14'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal08'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth06'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone14'
     HitShield=Sound'WeaponsSnd.Shields.shield12'
     HitWeapon=Sound'WeaponsSnd.Swords.sword12'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow05'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow05'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart22'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power43L'
     PitchDeviation=0.075000
     PowerupIcon=Texture'RuneFX2.gaxe'
     PowerupIconAnim=Texture'RuneFX2.gaxe1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeYellow'
     A_Idle=X2_idle
     A_AttackA=X2_attackA
     A_AttackAReturn=X2_attackAreturn
     A_AttackB=X2_attackB
     A_AttackBReturn=X2_attackBreturn
     A_AttackC=X2_attackC
     A_AttackCReturn=X2_attackCreturn
     A_AttackStandA=X2_StandingAttackA
     A_AttackStandAReturn=X2_StandingAttackAreturn
     A_AttackStandB=X2_StandingAttackB
     A_AttackStandBReturn=X2_StandingAttackBreturn
     A_Throw=X2_Throw
     A_Powerup=X2_Powerup
     A_Defend=X2_DefendTO
     A_DefendIdle=X2_Defendidle
     A_PainFront=X2_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=X2_PickupLeft
     A_PickupHighLeft=X2_PickupLeftHigh
     A_Taunt=X2_Taunt
     A_PumpTrigger=X2_PumpTrigger
     A_LeverTrigger=X2_LeverTrigger
     PickupMessage="You now carry a Goblin Axe"
     PickupSound=Sound'OtherSnd.Pickups.grab02'
     DropSound=Sound'WeaponsSnd.Drops.axedrop04'
     CollisionRadius=20.000000
     Mass=12.000000
     Skeletal=SkelModel'weapons.goblinaxe'
     SkelGroupSkins(0)=Texture'weapons.goblinaxegoblin_axe'
     SkelGroupSkins(1)=Texture'weapons.goblinaxegoblin_axe'
     WeaponTier=2
}
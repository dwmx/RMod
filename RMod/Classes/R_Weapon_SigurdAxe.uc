class R_Weapon_SigurdAxe extends R_AWeapon_Axe;

var bool bWasBloody;    //Remember whether BloodTexture was on Axe before powerup..
//=============================================================================
//
// Powerup: IceStatue
//
//=============================================================================
function PowerupInit()
{   
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    DamageType='ice';
    ThrownDamageType='ice';
    if(SkelGroupSkins[1] == BloodTexture)
        bWasBloody = True;

    BloodTexture = None;    //Stop from placing blood texture while Powered-Up...
    SkelGroupSkins[0]=Texture'weapons.sigurdaxesigurds_axeice';
    SkelGroupSkins[1]=Texture'weapons.sigurdaxesigurds_axeice';
    bUnlit = true;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.Z = 0;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.Z = 150;
}

function PowerupEnded()
{
    local int i;
    local debris IceChunk;
    
    Super.PowerupEnded();
    DesiredColorAdjust.Z = 0;

    DamageType=Default.DamageType;
    ThrownDamageType=Default.ThrownDamageType;
    BloodTexture=Default.BloodTexture;
    SkelGroupSkins[0]=Default.SkelGroupSkins[0];

    if(bWasBloody)
        SkelGroupSkins[1]=BloodTexture;
    else
        SkelGroupSkins[1]=Default.SkelGroupSkins[1];

    bUnlit = false;

    for(i=0; i<15; i++)
    {
        IceChunk = spawn(class'DebrisIce',,,GetJointPos(1));
        if(IceChunk != None)
        {
            IceChunk.SetSize(0.2);
            IceChunk.bUnlit = true;
        }
    }
}

simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelIceAxe', self);
    if (ES != None)
    {
        AttachActorToJoint(ES, 0);
    }
}

simulated function RemovePowerupEffect()
{
    local actor A;
    // Remove Effect skeleton
    A = DetachActorFromJoint(0);
    A.Destroy();
}



function int CalculateDamage(actor Victim)
{
    if (bPoweredUp && Victim.IsA('Pawn') && Pawn(Victim).CanBeStatued()
        && !Victim.Region.Zone.bNeutralZone)
    {
        Pawn(Victim).PowerupIce(Pawn(Owner));
        return 0;
    }

    return Super.CalculateDamage(Victim);
}

defaultproperties
{
     StowMesh=1
     Damage=30
     BloodTexture=Texture'weapons.sigurdaxesigurds_axeblood'
     rating=3
     RunePowerRequired=75
     RunePowerDuration=15.000000
     PowerupMessage="Freeze!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing12'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing14'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe07'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood09'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone03'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactcombo01'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth03'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone03'
     HitShield=Sound'WeaponsSnd.Shields.shield14'
     HitWeapon=Sound'WeaponsSnd.Swords.sword14'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SheathSound=Sound'WeaponsSnd.Stows.xstow06'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow06'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw03L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart32'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power50L'
     PitchDeviation=0.085000
     PowerupIcon=Texture'RuneFX2.saxe'
     PowerupIconAnim=Texture'RuneFX2.saxe1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeGray'
     A_Idle=X4_idle
     A_Forward=X4_walk
     A_Backward=X4_Backup
     A_Forward45Right=X4_walk45Right
     A_Forward45Left=X4_walk45Left
     A_Backward45Right=X4_Backup45Right
     A_Backward45Left=X4_Backup45Left
     A_StrafeRight=X4_Straferight
     A_StrafeLeft=X4_Strafeleft
     A_AttackA=S4_attackA
     A_AttackAReturn=X4_attackAreturn
     A_AttackB=S4_attackB
     A_AttackBReturn=None
     A_AttackC=S4_attackC
     A_AttackCReturn=X4_attackCreturn
     A_AttackStandA=X4_StandingAttackA
     A_AttackStandAReturn=X4_StandingAttackAreturn
     A_AttackStandB=X4_StandingAttackB
     A_AttackStandBReturn=X4_StandingAttackBreturn
     A_AttackBackupA=X4_Backupattack
     A_AttackBackupAReturn=None
     A_AttackStrafeRight=X4_StrafeRightAttack
     A_AttackStrafeLeft=X4_StrafeLeftAttack
     A_Throw=X4_throw
     A_Powerup=X4_Powerup
     A_Defend=None
     A_DefendIdle=None
     A_PainFront=X4_painFront
     A_PainBack=X4_painBack
     A_PainLeft=X4_painLeft
     A_PainRight=X4_painRight
     A_PickupGroundLeft=X4_PickupLeft
     A_PickupHighLeft=X4_PickupLeftHigh
     A_Taunt=X4_Taunt
     A_PumpTrigger=X4_PumpTrigger
     A_LeverTrigger=X4_LeverTrigger
     PickupMessage="You now wield Sigurd's Axe"
     PickupSound=Sound'OtherSnd.Pickups.grab04'
     DropSound=Sound'WeaponsSnd.Drops.axedrop02'
     Mass=16.000000
     Skeletal=SkelModel'weapons.sigurdaxe'
     SkelGroupSkins(0)=Texture'weapons.sigurdaxesigurds_axe'
     SkelGroupSkins(1)=Texture'weapons.sigurdaxesigurds_axe'
     WeaponTier=3
}
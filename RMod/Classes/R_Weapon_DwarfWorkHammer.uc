class R_Weapon_DwarfWorkHammer extends R_AWeapon_Hammer;

var(Sounds) Sound PoweredUpFireSound;

//=============================================================================
//
// WeaponFire
//
// Ground effect
//=============================================================================
function PowerupInit()
{   
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;

    DesiredColorAdjust.X = 77;
    DesiredColorAdjust.Z = 110;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.Z = 110;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.X = 77;
    DesiredColorAdjust.Z = 0;
}

function PowerupEnded()
{
    Super.PowerupEnded();
    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Z = 0;
}


simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelGroundHammer', self);
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

function WeaponFire(int SwingCount)
{
    local vector loc;
    local rotator rot;
    local GroundProjectile proj;

    if(!bPoweredUp)
        return;

    loc = Owner.Location;
    loc.Z -= Owner.CollisionHeight;
    proj = Spawn(class'GroundProjectile', Owner,, loc, Rotation);

    // Forward projectile
    if(proj != None)
    {
        proj.Velocity = vector(Owner.Rotation) * (450 + FRand() * 100);
        proj.TimeToExplode = 1.5 + FRand() * 0.5;
    }

    // Left projectile
    proj = Spawn(class'GroundProjectile', Owner,, loc, Rotation);
    if(proj != None)
    {
        rot = Owner.Rotation;
        rot.Yaw += 3000;
        proj.Velocity = vector(rot) * (450 + FRand() * 100);
        proj.TimeToExplode = 1.5 + FRand() * 0.5;
    }

    // Right projectile
    proj = Spawn(class'GroundProjectile', Owner,, loc, Rotation);
    if(proj != None)
    {
        rot = Owner.Rotation;
        rot.Yaw -= 3000;
        proj.Velocity = vector(rot) * (450 + FRand() * 100);
        proj.TimeToExplode = 1.5 + FRand() * 0.5;
    }
    PlaySound(PoweredUpFireSound, SLOT_Interface);
}

defaultproperties
{
     PoweredUpFireSound=Sound'WeaponsSnd.PowerUps.apowerrocks01'
     bCrouchTwoHands=True
     StowMesh=1
     Damage=45
     BloodTexture=Texture'weapons.WorkHammerd_work_hammerblood'
     rating=3
     RunePowerRequired=75
     RunePowerDuration=5.000000
     PowerupMessage="Earth Attack!"
     SweepVector=(Y=0.867000,Z=-0.500000)
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing01'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing09'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshhammer02'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood13'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone12'
     HitMetal(0)=Sound'WeaponsSnd.ImpWood.impactcombo03'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth07'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone12'
     HitShield=Sound'WeaponsSnd.Shields.shield09'
     HitWeapon=Sound'WeaponsSnd.Swords.sword09'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SheathSound=Sound'WeaponsSnd.Stows.xstow02'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow02'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw03L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart07'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power69L'
     PitchDeviation=0.085000
     PowerupIcon=Texture'RuneFX2.whammer'
     PowerupIconAnim=Texture'RuneFX2.whammer1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeRed'
     A_Idle=H5_Idle
     A_Forward=walkforwardTwohands
     A_Backward=H5_Backup
     A_Forward45Right=H5_Walk45Right
     A_Forward45Left=H5_Walk45Left
     A_Backward45Right=H5_BackupRight
     A_Backward45Left=H5_BackupLeft
     A_StrafeRight=H5_StrafeRight
     A_StrafeLeft=H5_StrafeLeft
     A_Jump=H5_Jump
     A_AttackA=H4_AttackA
     A_AttackAReturn=H4_attackAreturn
     A_AttackB=H4_AttackB
     A_AttackBReturn=H4_attackBreturn
     A_AttackC=None
     A_AttackCReturn=None
     A_AttackStandA=H4_StandingAttackA
     A_AttackStandAReturn=H4_StandingAttackAreturn
     A_AttackStandB=H4_StandingAttackB
     A_AttackStandBReturn=H4_StandingAttackBreturn
     A_AttackBackupA=H5_Backupattack
     A_AttackBackupAReturn=None
     A_AttackStrafeRight=H5_StrafeRightAttack
     A_AttackStrafeLeft=H5_StrafeLeftAttack
     A_JumpAttack=H5_jumpattack
     A_Throw=H5_Throw
     A_Powerup=H5_Powerup
     A_Defend=None
     A_DefendIdle=None
     A_PainFront=H5_painFront
     A_PainBack=H5_painFront
     A_PainLeft=H5_painFront
     A_PainRight=H5_painFront
     A_PickupGroundLeft=H5_PickupLeft
     A_PickupHighLeft=H5_PickupLeftHigh
     A_Taunt=H5_Taunt
     A_PumpTrigger=H5_PumpTrigger
     A_LeverTrigger=H5_LeverTrigger
     PickupMessage="You are armed with a Dwarven Work Hammer"
     PickupSound=Sound'OtherSnd.Pickups.grab04'
     DropSound=Sound'WeaponsSnd.Drops.hammerdrop02'
     Mass=16.000000
     Skeletal=SkelModel'weapons.WorkHammer'
     SkelGroupSkins(0)=Texture'weapons.WorkHammerd_work_hammer'
     SkelGroupSkins(1)=Texture'weapons.WorkHammerd_work_hammer'
}
class R_Weapon_DwarfBattleSword extends R_AWeapon_Sword;

var float EffectRadius;
var int RockCount;
var() float DropDelay;
var float ElapsedTime;
var bool bAvalanche;
var int testint;

//=============================================================================
//
// Powerup: Avalanche
//
//=============================================================================
function PowerupInit()
{
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    DesiredColorAdjust.X = 44;
    DesiredColorAdjust.Y = 33;
    DesiredColorAdjust.Z = 15;
}

function PowerupEndingPulseOn()
{
    PlaySound(PoweredUpEndingSound, SLOT_None);
    DesiredFatness = 140;
    DesiredColorAdjust.X = 200;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.X = 0;
}


function PowerupEnded()
{
    Super.PowerupEnded();
    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;

    bAvalanche = false;
}

simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelAvalancheSword', self);
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
    if (bPoweredUp)
    {
        bAvalanche = true;
        ElapsedTime=DropDelay;
        RockCount = Default.RockCount;
    }
}

function Tick(float DeltaTime)
{
    local RockAvalanche R;
    local vector loc;
    local vector outward;
    local int angle;

    if (bPoweredUp && bAvalanche)
    {
        ElapsedTime += DeltaTime;

        if (ElapsedTime > DropDelay)
        {
            ElapsedTime -= DropDelay;

            // Drop a rock
            angle = RandRange(Owner.Rotation.Yaw-4096, Owner.Rotation.Yaw+4096);
            outward = vector(rot(0,1,0)*angle);
            loc = Owner.Location + outward*RandRange(0, 50);
            loc.Z += 3*Owner.CollisionRadius + FRand()*Owner.CollisionRadius;
            switch(Rand(3))
            {
            case 0: R = spawn(class'RockAvalancheSmall',Owner,,loc);        break;
            case 1: R = spawn(class'RockAvalancheMed',  Owner,,loc);        break;
            case 2: R = spawn(class'RockAvalancheLarge',Owner,,loc);        break;
            }
            R.Velocity = outward * 500;
            R.Instigator = Pawn(Owner);

            if (--RockCount <= 0)
            {
                RockCount = Default.RockCount;
                bAvalanche = false;
            }
        }
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
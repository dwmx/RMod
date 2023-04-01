class R_Weapon_BoneClub extends R_AWeapon_Hammer;

var(Sounds) Sound PoweredUpFireSound;
//=============================================================================
//
// Powerup: SonicBlast
//
// This function is called when the weapon is initially powered up
//=============================================================================


function PowerupInit()
{   
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    //DesiredColorAdjust.Z = 140;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
}

function PowerupEnded()
{
    Super.PowerupEnded();
}


simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelSonicClub', self);
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
    local SonicBlast B;
    local SonicBlastHighlight C;
    local BeamSystem beam;
    local vector loc;
    local int i, count;
    local float speed;
    local vector end;
    local vector HitLocation, HitNormal;
    local float dist;
    local vector X, Y, Z;

    if (bPoweredUp && SwingCount == 0)
    {
        GetAxes(PlayerPawn(Owner).ViewRotation, X, Y, Z);
        loc = Owner.Location + X * 30;
        speed = 0.6;
        
        end = Owner.Location + X * 350;
        if(Trace(HitLocation, HitNormal, end, Owner.Location, false) == None)
            HitLocation = end;

        dist = VSize(HitLocation - Owner.Location);
        count = dist / 50;
        for(i = 0; i < count; i++)
        {
            B = Spawn(class'SonicBlast',,, loc, rotator(X));
            B.DrawScale = 0.3 * speed;
            C = Spawn(class'SonicBlastHighlight',,, loc, rotator(X));
            C.DrawScale = 0.3 * speed;
            loc += X * 50;
            speed += 0.35;
        }
        
//		beam = Spawn(class'SonicBeam',,, Owner.Location + X * 25);
//		beam.TargetLocation = HitLocation;

        // Damage all actors along the sonic blast range
        SonicDamage(dist, X);   
        
        PlaySound(PoweredUpFireSound, SLOT_Interface);  
    }
}

function SonicDamage(float dist, vector dir)
{
    // Note:  This is a method that damages all actors in a given cone
    local actor A;
    local vector v1;
    local float dot;

    foreach VisibleActors(class'actor', A, dist, Owner.Location)
    {
        if(A == Owner || A.Owner == Owner)
            continue;

        if(A.IsA('ScriptPawn') && ScriptPawn(A).bIsBoss)
            continue;

        v1 = Normal(A.Location - Location);

        dot = v1 dot dir;

        // If the target actor is within the cone, damage it
        if(abs(dot) > 0.75)
            a.JointDamaged(Damage * 1.5, Pawn(Owner), a.Location, vect(0, 0, 0), 'blunt', 0);
    }   

/* This method damages actors in a cylinder emminating from the Player
    extent.x = 50;
    extent.y = 50;
    extent.z = 50;
    foreach TraceActors(class'actor', a, hitLoc, hitNorm, end, start, extent, false)
    {
        if(a != Owner && a.Owner != Owner)      
            a.JointDamaged(Damage * 1.5, Pawn(Owner), a.Location, vect(0, 0, 0), 'blunt', 0);
    }
*/
}

defaultproperties
{
     PoweredUpFireSound=Sound'WeaponsSnd.PowerUps.atwilight04'
     StowMesh=1
     Damage=20
     BloodTexture=Texture'weapons.GoblinClubgoblin_spikeclubblood'
     rating=1
     RunePowerRequired=25
     RunePowerDuration=15.000000
     PowerupMessage="Sonic Blast!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing20'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing07'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshhammer05'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood01'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone19'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal10'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth02'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone19'
     HitShield=Sound'WeaponsSnd.Shields.shield07'
     HitWeapon=Sound'WeaponsSnd.Swords.sword07'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow01'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow01'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart30'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power70L'
     PitchDeviation=0.075000
     PowerupIcon=Texture'RuneFX2.gclub'
     PowerupIconAnim=Texture'RuneFX2.gclub1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeRed'
     A_Idle=X1_Idle
     A_AttackA=H2_attackA
     A_AttackAReturn=H2_attackAreturn
     A_AttackB=H2_attackB
     A_AttackBReturn=H2_attackBreturn
     A_AttackC=H2_attackC
     A_AttackCReturn=H2_attackCreturn
     A_AttackStandA=H2_StandingAttackA
     A_AttackStandAReturn=H2_StandingAttackAReturn
     A_AttackStandB=H2_StandingAttackB
     A_AttackStandBReturn=H2_StandingAttackBReturn
     A_AttackBackupA=H2_BackupAttackA
     A_AttackBackupAReturn=H2_BackupAttackAreturn
     A_AttackBackupB=H2_BackupAttackB
     A_Throw=H3_throw
     A_Powerup=X1_Powerup
     A_Defend=X1_DefendTO
     A_DefendIdle=X1_DefendIdle
     A_PainFront=X1_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=X1_PickupLeft
     A_PickupHighLeft=X1_PickupLeftHigh
     A_Taunt=H2_Taunt
     A_PumpTrigger=X1_PumpTrigger
     A_LeverTrigger=X1_LeverTrigger
     PickupMessage="You have discovered a Bone Club"
     PickupSound=Sound'OtherSnd.Pickups.grab02'
     DropSound=Sound'WeaponsSnd.Drops.hammerdrop04'
     Mass=12.000000
     Skeletal=SkelModel'weapons.GoblinClub'
     SkelGroupSkins(0)=Texture'weapons.GoblinClubgoblin_spikeclub'
     SkelGroupSkins(1)=Texture'weapons.GoblinClubgoblin_spikeclub'
     WeaponTier=2
}
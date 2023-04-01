//==============================================================================
//  R_AWeapon_BodyPart
//==============================================================================
class R_AWeapon_BodyPart extends R_AWeapon_NonStow;

var actor Blood;
var() bool bNeverExpire;

function ApplyBodyPartSubClass(Class<Actor> SubClass)
{
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
    return MATTER_FLESH;
}

function SpawnBloodSpray(vector HitLoc, vector HitNorm, EMatterType matter)
{
    if (matter != MATTER_NONE)
    {
        Spawn(class'BloodSpray',,, HitLoc, rotator(HitNorm));
    }
}


//-----------------------------------------------------------------------------
//
// State Pickup
//
// LimbWeapons will remove themselves if not picked up within a given amount
// of time.
//-----------------------------------------------------------------------------

auto state Pickup
{
    function BeginState()
    {
        bSweepable=false;
        SetCollision(true, false, false);
        bCollideWorld = true;
        bLookFocusPlayer = true;
        bLookFocusCreature = true;
        if (!bNeverExpire)
        {
            LifeSpan = ExpireTime; //RandRange(15,20);
        }
    }
    
    function EndState()
    {
        bSweepable=Default.bSweepable;
        SetCollision(false, false, false);
        bCollideWorld = false;
        bLookFocusPlayer = false;
        bLookFocusCreature = false;

        LifeSpan=0;
        Style=Default.Style;
        ScaleGlow=Default.ScaleGlow;
    }
    
Begin: // Overridden to avoid overwriting subclass settings
}


state Drop
{
    function BeginState()
    {   
        bFixedRotationDir = true;
        Super.BeginState();
    
        Blood = Spawn(class'Blood',,, Location,);
        if(Blood != None)
        {
            AttachActorToJoint(Blood, JointNamed('offset'));
        }
        
        //DesiredRotation.Yaw = Rotation.Yaw - Rand(2000) + 1000;     
    }
    
    function EndState()
    {
        Super.EndState();

        Blood = DetachActorFromJoint(JointNamed('offset'));
        Blood.Destroy();        
    }
    
    function InitializeStateRotation()
    {
        bFixedRotationDir = true;
        bRotateToDesired = false;
        RotationRate.Yaw = VSize(Velocity) * 65536.0 * 0.001;
        RotationRate.Pitch = VSize(Velocity) * 65536.0 * 0.005;
    }
}

defaultproperties
{
     Damage=12
     DamageType=Blunt
     ThroughAir(0)=Sound'WeaponsSnd.Arm.armswing02'
     ThroughAir(1)=Sound'WeaponsSnd.Arm.armswing01'
     ThroughAir(2)=Sound'WeaponsSnd.Arm.armswing02'
     HitFlesh(0)=Sound'WeaponsSnd.Arm.armflesh01'
     HitWood(0)=Sound'WeaponsSnd.Arm.armimp01'
     HitWood(1)=Sound'WeaponsSnd.Arm.armimp02'
     HitWood(2)=Sound'WeaponsSnd.Arm.armimp03'
     HitStone(0)=Sound'WeaponsSnd.Arm.armimp01'
     HitStone(1)=Sound'WeaponsSnd.Arm.armimp02'
     HitStone(2)=Sound'WeaponsSnd.Arm.armimp03'
     HitMetal(0)=Sound'WeaponsSnd.Arm.armimp01'
     HitMetal(1)=Sound'WeaponsSnd.Arm.armimp02'
     HitMetal(2)=Sound'WeaponsSnd.Arm.armimp03'
     HitDirt(0)=Sound'WeaponsSnd.Arm.armimp01'
     HitDirt(1)=Sound'WeaponsSnd.Arm.armimp02'
     HitDirt(2)=Sound'WeaponsSnd.Arm.armimp03'
     HitShield=Sound'WeaponsSnd.Arm.armshield01'
     HitWeapon=Sound'WeaponsSnd.Arm.armweapon01'
     HitBreakableWood=Sound'WeaponsSnd.Arm.armimp01'
     HitBreakableStone=Sound'WeaponsSnd.Arm.armimp01'
     A_AttackStandA=T_OUTStandingAttackA
     A_AttackStandAReturn=T_OUTStandingAttackAreturn
     A_Taunt=T_OUTTaunt
     PickupMessage="You picked up a severed limb"
     RespawnTime=0.000000
     ExpireTime=20.000000
     DropSound=Sound'WeaponsSnd.Arm.armdrop01'
     Buoyancy=2.500000
     Skeletal=SkelModel'objects.Limbs'
     WeaponTier=1
}
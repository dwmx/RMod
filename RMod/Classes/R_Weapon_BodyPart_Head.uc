class R_Weapon_BodyPart_Head extends R_AWeapon_BodyPart;

var Actor Blood;
var(Sounds) Sound LandSound[3];
var() bool bBloodyHead;
var int landcount;

function ApplyBodyPartSubClass(Class<Actor> SubClass)
{
    local Class<Head> HeadSubClass;
    local int i;
    
    HeadSubClass = Class<Head>(SubClass);
    if(HeadSubClass == None)
    {
        return;
    }
    
    Self.bBloodyHead = HeadSubClass.Default.bBloodyHead;
    Self.SkelMesh = HeadSubClass.Default.SkelMesh;
    for(i = 0; i < 16; ++i)
        Self.SkelGroupSkins[i] = HeadSubClass.Default.SkelGroupSkins[i];
}

simulated function PostBeginPlay()
{
    DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;     
    DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
    DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
    DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;

    RotationRate.Yaw = 50000 + Rand(150000);
    RotationRate.Pitch = 10000 + Rand(150000);


//Removed To allow LimbWeapon to handle blood on DropState.
/*
    if(bBloodyHead)
    {
        Blood = Spawn(class'Blood');
        if(Blood != None)
        {
            AttachActorToJoint(Blood, JointNamed('base'));
            Blood.RemoteRole = ROLE_None;   // don't replicate
        }
    }

    SetTimer(0.25, true);
*/

    Super.PostBeginPlay();
}
        
simulated function Landed(vector HitNormal, actor HitActor)
{
    HitWall(HitNormal, HitActor);
}
    
simulated function HitWall(vector HitNormal, actor HitWall)
{
    local float speed;
    
    speed = VSize(velocity);

    if(speed > 100 && landcount < 2)
    {
        landcount++;
        PlaySound(LandSound[Rand(3)]);
    }
    
    if(((HitNormal.Z > 0.8) && (speed < 60)) || (speed < 20))
    {
        SetPhysics(PHYS_None);
        bBounce = false;
        bFixedRotationDir = false;
        bCollideWorld = false;
        bLookFocusPlayer = false; // Player isn't interested in the head anymore
        SetTimer(0, false);

//		GotoState('WaitingToRemove');

//Removed To Allow LimbWeapon to handle Blood on DropState.
/*
        if(bBloodyHead)
        {
            Blood = DetachActorFromJoint(JointNamed('base'));
            if(Blood != None)
            {
                Blood.Destroy();
            }
        }
*/

    }
    else
    {           
        SetPhysics(PHYS_Falling);
        RotationRate.Yaw = VSize(Velocity) * 100;
        RotationRate.Pitch = VSize(Velocity) * 50;
        
        Velocity = 0.45 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
        if(VSize(Velocity) < 20)
        {
            self.HitWall(HitNormal, HitWall); // Force the actor to stop
        }
        DesiredRotation = rotator(HitNormal);
    }
    
    // Put a blood splot on the wall where the head struck it
    // Trace a line to determine the location to put the blood decal
    if(speed > 100 && HitWall.Skeletal == None && bBloodyHead)
    { // Only put blood splats on walls
        if(FRand() < 0.5)
            Spawn(class'DecalBlood3',,,, rotator(HitNormal));
        else
            Spawn(class'DecalBlood4',,,, rotator(HitNormal));
    }

    if(speed < 100)
        GotoState('Pickup');
}

//-----------------------------------------------------------------------------
//
// State Active
//
// Melee Weapon is Active and in the actor's hand, waiting to be used
//-----------------------------------------------------------------------------

state Active
{
    function BeginState()
    {
        if(bBloodyHead)
        {
            Blood = Spawn(class'Blood');
            if(Blood != None)
            {
                AttachActorToJoint(Blood, JointNamed('base'));
            }
        }

        SetPhysics(PHYS_None);
    }
    
    function EndState()
    {
        if(bBloodyHead)
        {
            Blood = DetachActorFromJoint(JointNamed('base'));
            if(Blood != None)
            {
                Blood.Destroy();
            }
        }
        landcount=0;
    }

begin:
}

//-----------------------------------------------------------------------------
//
// State Throw
//
// Melee weapon was thrown
//
//-----------------------------------------------------------------------------

state Throw
{
    simulated function Landed(vector HitNormal, actor HitActor)
    {
        HitWall(HitNormal, HitActor);
    }
    
    simulated function HitWall(vector HitNormal, actor HitWall)
    {
        local int DamageAmount;

        Global.HitWall(HitNormal, HitWall);

        // Damage movers or polyobjects
        if((Role == ROLE_Authority) && ((Mover(HitWall) != None) || (PolyObj(HitWall) != None)))
        {
            DamageAmount = CalculateDamage(HitWall);
            if (DamageAmount != 0)
                HitWall.JointDamaged(DamageAmount, instigator, Location, Velocity*0.5, ThrownDamageType, 0);
        }

        GotoState('Drop');
    }
}

/*
simulated function Timer()
{
    bDestroyable=True;
    if(FRand() < 0.5)
        spawn(class'BloodDrips');
    else
        spawn(class'BloodDrips2');
}
*/

defaultproperties
{
     LandSound(0)=Sound'OtherSnd.Gibs.gibhead01'
     LandSound(1)=Sound'OtherSnd.Gibs.gibhead02'
     LandSound(2)=Sound'OtherSnd.Gibs.gibhead03'
     bBloodyHead=True
     ThrownSoundLOOP=None
     PickupMessage="You picked up a head"
     Physics=PHYS_Falling
     LODCurve=LOD_CURVE_ULTRA_AGGRESSIVE
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     bCollideWorld=True
     bBounce=True
     Skeletal=SkelModel'objects.Heads'
}
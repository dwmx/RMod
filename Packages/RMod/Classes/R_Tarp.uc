//=============================================================================
//  R_Tarp
//  RMod Tarp actor which is substituted for all RuneI.Tarp actors.
//  Replicates TossVelocity to fix glitchy client-side launch issues.
//=============================================================================
class R_Tarp extends DecorationRune;

var() float TossVelocity;
var(Sounds) Sound JumpTarp;
var() float MaxAppliedVelocity;

replication
{
    reliable if(Role == ROLE_Authority)
        TossVelocity,
        MaxAppliedVelocity;
}

/**
*   NotifySubstitutedForInstance
*   Called to notify this Actor that it was spawned as a substitution for
*   another actor. This is where any important property copying should occur.
*/
function NotifySubstitutedForInstance(Actor InActor)
{
    local Tarp InTarp;

    // Disable collide world for correct actor placement
    bCollideWorld = false;

    // Perform important copying
    SetRotation(InActor.Rotation);
    SetLocation(InActor.Location);
    
    bCollideWorld = InActor.bCollideWorld;

    // Tarp properties
    InTarp = Tarp(InActor);
    if(InTarp != None)
    {
        Self.TossVelocity = InTarp.TossVelocity;
        Self.JumpTarp = InTarp.JumpTarp;
        Self.MaxAppliedVelocity = InTarp.TossVelocity;

    }
}

simulated event GetSpringJointParms(int joint, out float DampFactor, out float SpringConstant, out vector SpringThreshold)
{
    DampFactor = 5;
    SpringConstant = 300;
    SpringThreshold = vect(20,20,100);
}


function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
    if ((JointFlags[joint]&JOINT_FLAG_COLLISION)!=0)
        ApplyJointForce(joint, Momentum);
    return true;
}

function AddVelocity(vector NewVelocity)
{   // Momentum has come in from another actor
}

simulated function JointTouchedBy(actor Other, int joint)
{
    local vector vel;
    local vector X,Y,Z;
    local float mag;

    if (Other.Velocity.Z < 0)
    {
        // Apply only velocity in Z direction of joint's local coordinates
        GetAxes(Rotation, X,Y,Z);
        mag = VSize(Other.Velocity);
        mag = Clamp(mag, 0, MaxAppliedVelocity);
        vel = -Z * mag;
        ApplyJointForce(joint, vel);

        // Slow Other down so he doesn't simulate through ground
        Other.Velocity = vect(0,0,0);
        Other.Acceleration = vect(0,0,0);

        // Other is still in physics, so add to pendingtouch list
        Other.PendingTouch = self;
    }
}

simulated function PostTouch(actor Other)
{
    local vector X,Y,Z;

    GetAxes(Rotation, X,Y,Z);

    if (Other.IsA('Inventory') || Other.IsA('Decoration') ||
        (Other.IsA('Pawn') && Pawn(Other).Health <= 0))
    {   // Make these objects eventually work their way off straight up tarps
        Z -= VRand()*0.1;
    }

    Other.Acceleration = vect(0,0,0);
    Other.SetPhysics(PHYS_Falling);
    Other.Velocity = Z*TossVelocity;
    PlaySound(JumpTarp, SLOT_Misc,,,, FRand()*0.5 + 0.8);
}

simulated function Debug(Canvas canvas, int mode)
{
    Super.Debug(canvas, mode);
    
    Canvas.DrawText("Tarp:");
    Canvas.CurY -= 8;
}

defaultproperties
{
     TossVelocity=800.000000
     JumpTarp=Sound'OtherSnd.Instruments.drumhuge05'
     MaxAppliedVelocity=800.000000
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=64.000000
     CollisionHeight=10.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     bJointsTouch=True
     Skeletal=SkelModel'objects.Tarp'
}
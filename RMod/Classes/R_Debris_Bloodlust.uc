//==============================================================================
//  R_Debris_Bloodlust
//  Local host class for display bloodlust related debris effects.
//==============================================================================
class R_Debris_Bloodlust extends Debris abstract;

/**
*   Spawned (override)
*   Overridden to reduce scale and decrease spawn velocity.
*/
simulated function Spawned()
{
    Velocity = (VRand()+vect(0,0,1)) * RandRange(60,180);
    RotationRate.Yaw = RandRange(-64000, 64000);
    RotationRate.Pitch = RandRange(-64000, 64000);
    RotationRate.Roll = RandRange(-64000, 64000);
    DrawScale = 0.5;
}

/**
*   HitWall (override)
*   Overridden to enter into FadeOut state instead of instantly self destructing.
*/
simulated function HitWall(vector HitNormal, actor HitWall)
{
    local float speed;
    
    speed = VSize(velocity);
    LifeSpan = RandRange(10, 20);

    if (speed>300 && DrawScale>0.3 && FRand()>0.6)
    {
        if (!Region.Zone.bWaterZone)
            PlayLandSound();
    }

    if(((HitNormal.Z > 0.8) && (speed < 60)) || (speed < 20))
    {
        SetPhysics(PHYS_None);
        bBounce = false;
        bFixedRotationDir = false;
        SetCollision(false, false, false);
        bCollideWorld = false;
        bLookFocusPlayer = false; // Player isn't interested anymore
        bSimFall=false;
        GotoState('FadeOut');

        if (!Region.Zone.bWaterZone)
            SpawnDebrisDecal(HitNormal);
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

        if (!Region.Zone.bWaterZone)
            SpawnDebrisDecal(HitNormal);
    }
}

//==============================================================================
//  State FadeOut
//
//  The self-destructing state for a debris actor.
//==============================================================================
state FadeOut
{
Begin:
    Sleep(3.0);
    Destroy();
}

defaultproperties
{
    RemoteRole=ROLE_None
    Physics=PHYS_Falling
    CollisionRadius=5.0
    CollisionHeight=5.0
    bCollideWorld=True
    bBounce=True
    bFixedRotationDir=True
    Buoyancy=50.0
}
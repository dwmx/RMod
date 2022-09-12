class R_RunePlayer_LastManStanding extends R_RunePlayer;

var R_IceStatueProxy IceStatueProxy;

event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
    Health = 100;
    GotoState('IceStatue');
}

function bool ReceiveIceStatueProxyJointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
{
    return true;
}

state IceStatue
{
    event BeginState()
    {
        // Begin Super.BeginState()
        if (Weapon!=None && Weapon.bPoweredUp)
            Weapon.PowerupEnd();
        if (Weapon!=None)
            Weapon.FinishAttack();

        Acceleration=vect(0,0,0);
        SetPhysics(PHYS_Falling);
        CreatureStatue();
        InventoryStatue();

        Buoyancy = 10;
        //SetTimer(5, false);
        //bCanLook = false;
        bProjTarget = false;
        SlowAnimation();
        // End Super.BeginState()

        bSweepable = false;

        if(IceStatueProxy != None)
        {
            IceStatueProxy.Destroy();
        }
        IceStatueProxy = Spawn(Class'RMod_LastManStanding.R_IceStatueProxy', Self);
        IceStatueProxy.ApplyProxy(Self);
    }

    event EndState()
    {
        // Begin Super.EndState()
        Buoyancy = Default.Buoyancy;
        //bCanLook = Default.bCanLook;
        SetTimer(0, false);
        bMovable = Default.bMovable;
        bProjTarget = Default.bProjTarget;
        if (AnimProxy != None)
            AnimProxy.GotoState('Idle');
        // End Super.EndState()

        bSweepable = true;

        if(IceStatueProxy != None)
        {
            IceStatueProxy.Destroy();
        }

        CreatureNormal();
        InventoryNormal();
        SpawnDebris(vect(0,0,0));
        PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
    }

    function bool ReceiveIceStatueProxyJointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
    {
        // If struck by a teammate, then thaw
        if(EventInstigator != None && EventInstigator.PlayerReplicationInfo != None && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
        {
            GotoState('PlayerWalking');
        }
    }

    function bool JointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
    {
        return true;
    }
}

defaultproperties
{
    MaxHealth=200
    Health=200
}
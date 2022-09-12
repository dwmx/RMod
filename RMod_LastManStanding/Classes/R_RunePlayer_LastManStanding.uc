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

state IceStatue
{
    event BeginState()
    {
        Super.BeginState();

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
        Super.EndState();

        bSweepable = true;

        if(IceStatueProxy != None)
        {
            IceStatueProxy.Destroy();
        }
    }

    //function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
    //{
    //    Log("I took a hit!");
    //    return true;
    //}
}

defaultproperties
{
    MaxHealth=200
    Health=200
}
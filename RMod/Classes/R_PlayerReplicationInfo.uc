//=============================================================================
// R_PlayerReplicationInfo
//=============================================================================
class R_PlayerReplicationInfo extends Engine.PlayerReplicationInfo;

var int DamageDealt; // Cumulative damage dealt throughout the game

struct FStatTracker
{
    var int Cached;
    var float TimeSeconds;
};
var FStatTracker ScoreTracker;
var FStatTracker DeathsTracker;
var FStatTracker DamageDealtTracker;
var FStatTracker PingTracker;

replication
{
    reliable if(Role == ROLE_Authority)
        DamageDealt;
}

simulated function UpdateStatTracker(out FStatTracker StatTracker, int Value)
{
    if(StatTracker.Cached == Value)
    {
        return;
    }

    StatTracker.Cached = Value;
    StatTracker.TimeSeconds = Level.TimeSeconds;
}

simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    if(Level.NetMode == NM_StandAlone || Role < ROLE_Authority)
    {
        UpdateStatTracker(ScoreTracker, int(Score));
        UpdateStatTracker(DeathsTracker, int(Deaths));
        UpdateStatTracker(DamageDealtTracker, DamageDealt);
        UpdateStatTracker(PingTracker, Ping);
    }
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}

//=============================================================================
// R_PlayerReplicationInfo
//=============================================================================
class R_PlayerReplicationInfo extends Engine.PlayerReplicationInfo;

var String PlayerIP; // Set from R_GameInfo.PostLogin

// If true, this PRI's data will persist between logins when R_GameInfo has
// persistent score tracking enabled.
// R_GameInfo sets this to false when multipler players are sharing an IP.
var bool bShouldPersist;

var int DamageDealt; // Cumulative damage dealt throughout the game
var string ComputerName;

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
        DamageDealt,
        ComputerName;
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

simulated function string getKDR()
{
    if (Deaths == 0) {
        if (Score == 0) {
            return "N/A";
        } else {
            return "GOD";
        }
    } else {
        return Left(Score / Deaths, 4);
    }
}

function ResetPlayerReplicationInfo()
{
    Score = Default.Score;
    Deaths = Default.Deaths;
    bFirstBlood = Default.bFirstBlood;
    MaxSpree = Default.MaxSpree;
    HeadKills = Default.HeadKills;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    Score=0
    Deaths=0
    bFirstBlood=False
    MaxSpree=0
    HeadKills=0
    bShouldPersist=true
}

class R_GameInfo_LastManStanding extends R_GameInfo_TDM;

var float PreRoundDurationSeconds;
var float LiveRoundDurationSeconds;
var float PostRoundDurationSeconds;
var float GameStateTimeStampSeconds;

function Killed(pawn killer, pawn Other, name damageType)
{
    local R_RunePlayer LocalRunePlayer;

	Super.Killed(killer, Other, damageType);

    LocalRunePlayer = R_RunePlayer(Other);
    if(LocalRunePlayer != None)
    {
        LocalRunePlayer.bCanRestart = false;
        LocalRunePlayer.GotoState('PlayerSpectating');
    }
}

function ReplicateGameStateName(Name NewGameStateName)
{
    local R_GameReplicationInfo_LastManStanding GRI;
    GRI = R_GameReplicationInfo_LastManStanding(GameReplicationInfo);
    if(GRI != None)
    {
        GRI.GameStateName = NewGameStateName;
    }
}

function UpdateGameStateTimeStamp()
{
    GameStateTimeStampSeconds = Level.TimeSeconds;
}

// Returns true if the specified duration has been reached
function bool CheckGameStateTimer(float DurationSeconds)
{
    local float DeltaSeconds;

    DeltaSeconds = Level.TimeSeconds - GameStateTimeStampSeconds;
    if(DeltaSeconds >= DurationSeconds)
    {
        return true;
    }
    return false;
}

// GameWaiting: Waiting for a call to start the game
auto state GameWaiting
{
    event BeginState()
    {
        ReplicateGameStateName('GameWaiting');
        UpdateGameStateTimeStamp();
    }

    event Tick(float DeltaSeconds)
    {
        if(CheckGameReadyToStart())
        {
            StartGame();
        }
    }

    function bool CheckGameReadyToStart()
    {
        // This is where you'd wait for teams to be balanced or players to join
        return true;
    }

    function StartGame()
    {
        GotoState('PreRound');
    }
}

state PreRound
{
    event BeginState()
    {
        ReplicateGameStateName('PreRound');
        UpdateGameStateTimeStamp();
        ResetLevelSoft(0);
    }

    event Tick(float DeltaSeconds)
    {
        if(CheckGameStateTimer(PreRoundDurationSeconds))
        {
            GotoState('LiveRound');
        }
    }
}

state LiveRound
{
    event BeginState()
    {
        ReplicateGameStateName('LiveRound');
        UpdateGameStateTimeStamp();
    }

    event Tick(float DeltaSeconds)
    {
        if(CheckGameStateTimer(LiveRoundDurationSeconds))
        {
            GotoState('PostRound');
        }
    }
}

state PostRound
{
    event BeginState()
    {
        ReplicateGameStateName('PostRound');
        UpdateGameStateTimeStamp();
    }

    event Tick(float DeltaSeconds)
    {
        if(CheckGameStateTimer(PostRoundDurationSeconds))
        {
            GotoState('PreRound');
        }
    }
}

defaultproperties
{
    GameReplicationInfoClass=Class'RMod_LastManStanding.R_GameReplicationInfo_LastManStanding'
    HUDType=Class'RMod_LastManStanding.R_RunePlayerHUD_LastManStanding'
    PreRoundDurationSeconds=5.0
    LiveRoundDurationSeconds=15.0
    PostRoundDurationSeconds=5.0
}
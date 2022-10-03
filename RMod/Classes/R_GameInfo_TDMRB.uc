//==============================================================================
//  R_GameInfo_TDMRB
//  Round-based version of team death match.
//==============================================================================
class R_GameInfo_TDMRB extends R_GameInfo_TDM;

var float GameStateTimeStampSeconds;
var float GameStateDurationSeconds;

var config float GameStateDurationSeconds_PreLive;
var config float GameStateDurationSeconds_Loadout;
var config float GameStateDurationSeconds_PreRound;
var config float GameStateDurationSeconds_LiveRound;
var config float GameStateDurationSeconds_PostRound;

var int RoundNumber;
var int IntegerTimeSeconds;

// This const should match the size of the GameReplicationInfo.Teams array
const MAX_TEAMS = 4;

enum ERoundEndCondition
{
    REC_None,           // Round end condition not met
    REC_TimeExpired,    // Timer expiration condition met
    REC_Elimination     // All but one team has been eliminated
};

event BeginPlay()
{
    Super.BeginPlay();

    RoundNumber = 0;
}

function SetGameStateTimerSeconds(float NewDurationSeconds)
{
    local R_GameReplicationInfo RGRI;

    GameStateTimeStampSeconds = Level.TimeSeconds;
    GameStateDurationSeconds = NewDurationSeconds;

    RGRI = R_GameReplicationInfo(GameReplicationInfo);
    if(RGRI != None)
    {
        RGRI.UpdateTimeLimit(int(GameStateDurationSeconds));
    }
}

function float GetGameStateTimeRemainingSeconds()
{
    local float TimeDeltaSeconds;
    local float TimeRemainingSeconds;

    TimeDeltaSeconds = Level.TimeSeconds - GameStateTimeStampSeconds;
    TimeRemainingSeconds = GameStateDurationSeconds - TimeDeltaSeconds;
    TimeRemainingSeconds = Max(0.0, TimeRemainingSeconds);

    return TimeRemainingSeconds;
}

function BroadcastOpenLoadoutMenu()
{
    local R_RunePlayer RRP;

    foreach AllActors(Class'RMod.R_RunePlayer', RRP)
    {
        RRP.ClientOpenLoadoutMenu();
    }
}

function BroadcastCloseLoadoutMenu()
{
    local R_RunePlayer RRP;

    foreach AllActors(Class'RMod.R_RunePlayer', RRP)
    {
        RRP.ClientCloseLoadoutMenu();
    }
}

/**
*   CheckIsGameLiveConditionMet
*   Returns whether or not the game satisfies the conditions required to be in
*   the 'Live' state. If this returns false, the game should transition to
*   PreGame. If true, the game should either transition to Live, or stay Live.
*/
function bool CheckIsGameLiveConditionMet()
{
    local int ActiveTeamCount;
    local int i;
    local TeamInfo CurrentTeamInfo;

    // Returns true if there are at least 2 active teams
    ActiveTeamCount = 0;
    if(R_GameReplicationInfo(GameReplicationInfo) != None)
    {
        for(i = 0; i < MAX_TEAMS; ++i)
        {
            CurrentTeamInfo = R_GameReplicationInfo(GameReplicationInfo).Teams[i];
            if(CurrentTeamInfo != None && CurrentTeamInfo.Size > 0)
            {
                ++ActiveTeamCount;
            }
        }
    }

    if(ActiveTeamCount >= 2)
    {
        return true;
    }
    else
    {
        return false;
    }
}

/**
*   Killed (override)
*   Overridden to modify team scoring logic
*/
function Killed(Pawn killer, Pawn Other, Name damageType)
{
	Super(R_GameInfo).Killed(killer, Other, damageType);
}

/**
*   State PreGame
*   Warmup game state, gives a buffer to allow players to connect and get ready
*/
auto state PreGame
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
        Enable('Timer');
        SetTimer(20.0, true);
    }

    event EndState()
    {
        Disable('Timer');
    }

    /**
    *   CheckIsScoringEnabled (override)
    *   Overridden to disable score tracking in the PreGame state
    */
    function bool CheckIsScoringEnabled()
    {
        return false;
    }

    event Tick(float DeltaSeconds)
    {
        if(CheckIsGameLiveConditionMet())
        {
            GotoState('PreLive');
            return;
        }
    }

    event Timer()
    {
        BroadcastPreGameMessage();
    }

    function BroadcastPreGameMessage()
    {
        BroadcastMessage("Waiting for more teams", true, 'GameAnnouncement');
    }
}

/**
*   State PreLive
*   The game is transitioning into the Live state.
*/
state PreLive
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PreLive);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());

        //++RoundNumber;
        //BroadcastMessage("Round" @ RoundNumber, true, 'GameAnnouncement');
        BroadcastMessage("Game is starting...", true, 'GameAnnouncement');
    }

    /**
    *   CheckIsScoringEnabled (override)
    *   Overridden to disable score tracking in the PreLive state
    */
    function bool CheckIsScoringEnabled()
    {
        return false;
    }

    /**
    *   CheckIsGameDamageEnabled (override)
    *   Overridden to apply global invulnerability in PreLive state
    */
    function bool CheckIsGameDamageEnabled()
    {
        return false;
    }

    event Tick(float DeltaSeconds)
    {
        // Fall back to pregame if needed
        if(!CheckIsGameLiveConditionMet())
        {
            GotoState('PreGame');
            return;
        }
        else if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('Loadout');
            return;
        }
    }
}

/**
*   BaseLiveState
*   Base state for Loadout, PreRound, LiveRound, and PostRound states
*/
state BaseRoundState
{
    /**
    *   CheckAllowRestart (override)
    *   Disallow players from restarting while the round is live
    */
    function bool CheckAllowRestart(PlayerPawn P)
    {
        return false;
    }
}

/**
*   State Loadout
*   State in which players are allowed to select their loadouts.
*/
state Loadout extends BaseRoundState
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_Loadout);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
        BroadcastOpenLoadoutMenu();
    }

    event EndState()
    {
        BroadcastCloseLoadoutMenu();
    }

    /** R_GameInfo overrides for game behavior */
    function bool CheckIsScoringEnabled()       { return false; }
    function bool CheckIsGameDamageEnabled()    { return false; }

    event Tick(float DeltaSeconds)
    {
        // Fall back to pregame if needed
        if(!CheckIsGameLiveConditionMet())
        {
            GotoState('PreGame');
            return;
        }
        else if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('PreRound');
        }
    }
}

/**
*   State PreRound
*   Next round is about to begin
*/
state PreRound extends BaseRoundState
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PreRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());

        // Reset without stat reset
        ResetLevelSoft();

        InitializeCountdownVariables();
    }

    function InitializeCountdownVariables()
    {
        IntegerTimeSeconds = -1;
    }

    /** R_GameInfo overrides for game behavior */
    function bool CheckIsScoringEnabled()       { return false; }
    function bool CheckIsGameDamageEnabled()    { return false; }

    event Tick(float DeltaSeconds)
    {
        local float GameStateTimeRemainingSeconds;
        local int NewIntegerTimeSeconds;

        // Fall back to pregame if needed
        if(!CheckIsGameLiveConditionMet())
        {
            GotoState('PreGame');
            return;
        }

        // Broadcast countdown message
        GameStateTimeRemainingSeconds = GetGameStateTimeRemainingSeconds();
        NewIntegerTimeSeconds = GameStateTimeRemainingSeconds;
        if(NewIntegerTimeSeconds != IntegerTimeSeconds && NewIntegerTimeSeconds <= 5 && NewIntegerTimeSeconds > 0)
        {
            IntegerTimeSeconds = NewIntegerTimeSeconds;
            BroadcastMessage(String(IntegerTimeSeconds), true, 'GameAnnouncement');
        }

        if(GameStateTimeRemainingSeconds <= 0.0)
        {
            GotoState('LiveRound');
        }
    }
}

/**
*   State LiveRound
*   Round is in progress
*/
state LiveRound extends BaseRoundState
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_LiveRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());

        ++RoundNumber;
        BroadcastMessage("Round" @ RoundNumber, true, 'GameAnnouncement');
    }

    event Tick(float DeltaSeconds)
    {
        local ERoundEndCondition RoundEndCondition;
        local byte WinningTeamIndex;

        // Fall back to pregame if needed
        if(!CheckIsGameLiveConditionMet())
        {
            GotoState('PreGame');
            return;
        }

        DetermineWinningTeamForRound(RoundEndCondition, WinningTeamIndex);
        if(RoundEndCondition != REC_None)
        {
            AddScoreForRoundEnd(RoundEndCondition, WinningTeamIndex);
            BroadcastMessageForRoundEnd(RoundEndCondition, WinningTeamIndex);

            GotoState('PostRound');
        }
    }

    function AddScoreForRoundEnd(ERoundEndCondition RoundEndCondition, byte WinningTeamIndex)
    {
        if(WinningTeamIndex == 255)
        {
            // Draw, do nothing for now
            return;
        }

        if(Teams[WinningTeamIndex] != None)
        {
            Teams[WinningTeamIndex].Score += 1.0;
        }
    }

    function BroadcastMessageForRoundEnd(ERoundEndCondition RoundEndCondition, byte WinningTeamIndex)
    {
        local R_GameReplicationInfo RGRI;
        local String WinningTeamString;
        local String BroadcastString;

        if(WinningTeamIndex == 255)
        {
            WinningTeamString = "Round Draw";
        }
        else if(WinningTeamIndex >= 0 && WinningTeamIndex <= MAX_TEAMS)
        {
            RGRI = R_GameReplicationInfo(GameReplicationInfo);
            BroadcastLocalizedMessage(
                Class'RMod.R_Message_TeamAnnouncement',
                Class'RMod.R_Message_TeamAnnouncement'.Static.GetSwitch_TeamWinsTheRoundMessage(),
                None,
                None,
                RGRI.Teams[WinningTeamIndex]);
        }
        
        BroadcastString = WinningTeamString;

        if(RoundEndCondition == REC_TimeExpired)
        {
            BroadcastString = "Round time expired -" @ BroadcastString;
        }
    }

    /**
    *   DetermineWinningTeamForRound
    *   Returns the index of the winning team for this round. This is called
    *   from Tick, so do not perform any costly checks.
    *   In the event of a round-draw, this will return 255 for team index.
    */
    function DetermineWinningTeamForRound(out ERoundEndCondition OutRoundEndCondition, out byte OutWinningTeamIndex)
    {
        local Pawn P;
        local R_RunePlayer RRP;
        local int TeamAliveCountArray[32];
        local byte TeamIndex;
        local int i;
        local int TeamAliveCount;
        local byte CandidateTeamIndex;
        local bool bDraw;

        OutRoundEndCondition = REC_None;

        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            // Round timed out
            OutRoundEndCondition = REC_TimeExpired;
        }

        // Count how many players are alive on each team (valid up to 32 teams)
        P = Level.PawnList;
        while(P != None)
        {
            RRP = R_RunePlayer(P);
            if(RRP != None)
            {
                if(R_PlayerReplicationInfo(RRP.PlayerReplicationInfo) != None)
                {
                    TeamIndex = R_PlayerReplicationInfo(RRP.PlayerReplicationInfo).Team;
                    if(TeamIndex >= 0 && TeamIndex <= 32)
                    {
                        if(CheckIsPlayerConsideredAlive(RRP))
                        {
                            TeamAliveCountArray[TeamIndex]++;
                        }
                    }
                }
            }
            
            P = P.NextPawn;
        }

        // Count how many teams have at least 1
        TeamAliveCount = 0;
        for(i = 0; i < 32; ++i)
        {
            if(TeamAliveCountArray[i] > 0)
            {
                TeamAliveCount++;
            }
        }

        // If there is only 1 team left, elimination condition met
        // This overrides timeout condition in the extreme rare case
        // that the round timed out and the last player died in the same tick
        if(TeamAliveCount == 1)
        {
            OutRoundEndCondition = REC_Elimination;
        }

        // If there's an end condition, then return the winning team
        if(OutRoundEndCondition != REC_None)
        {
            CandidateTeamIndex = 0;
            bDraw = false;
            for(i = 1; i < 32; ++i)
            {
                if(TeamAliveCountArray[i] > TeamAliveCountArray[CandidateTeamIndex])
                {
                    CandidateTeamIndex = i;
                    bDraw = false;
                }
                else if(TeamAliveCountArray[i] == TeamAliveCountArray[CandidateTeamIndex])
                {
                    bDraw = true;
                }
            }

            if(bDraw)
            {
                OutWinningTeamIndex = 255;
            }
            else
            {
                OutWinningTeamIndex = CandidateTeamIndex;
            }
        }
    }

    /**
    *   CheckIsPlayerConsideredAlive
    *   Round end condition uses this function to check which players are alive or dead.
    */
    function bool CheckIsPlayerConsideredAlive(R_RunePlayer RRP)
    {
        if(RRP.Health > 0)
        {
            return true;
        }
        return false;
    }
}

/**
*   State PostRound
*   Round just finished
*/
state PostRound extends BaseRoundState
{
    event BeginState()
    {
        ReplicateCurrentGameState();
        SetGameStateTimerSeconds(GameStateDurationSeconds_PostRound);
        UtilitiesClass.Static.RModLog(Self @ "transitioned to state" @ GetStateName());
    }

    /** R_GameInfo overrides for game behavior */
    function bool CheckIsScoringEnabled()       { return false; }
    function bool CheckIsGameDamageEnabled()    { return false; }

    event Tick(float DeltaSeconds)
    {
        // Fall back to pregame if needed
        if(!CheckIsGameLiveConditionMet())
        {
            GotoState('PreGame');
            return;
        }

        if(GetGameStateTimeRemainingSeconds() <= 0.0)
        {
            GotoState('Loadout');
        }
    }
}

defaultproperties
{
    GameStateDurationSeconds_PreLive=30.0
    GameStateDurationSeconds_Loadout=10.0
    GameStateDurationSeconds_PreRound=5.0
    GameStateDurationSeconds_LiveRound=30.0
    GameStateDurationSeconds_PostRound=5.0
    RoundNumber=0
    IntegerTimeSeconds=0
    DefaultPlayerMaxHealth=200
    DefaultPlayerHealth=200
    bRemoveNativeWeapons=True
    bRemoveNativeShields=True
    bLoadoutsEnabled=True
}
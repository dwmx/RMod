//==============================================================================
//  R_PersistentScoreManager
//  Maintains persistent score tracking for the duration of a game.
//  Allows players to leave and rejoin without losing their score.
//==============================================================================
class R_PersistentScoreManager extends Object;

var Class<R_AUtilities> UtilitiesClass;

var R_GameInfo GameInfo;

struct FSavedPawnScore
{
    var float Score;
    var float Deaths;
    var float DamageDealt;
    var bool bFirstBlood;
    var int MaxSpree;
    var int HeadKills;
    var String IP;
    var bool bOccupied;
};
const MAX_SAVED_PAWN_SCORES = 128;
var FSavedPawnScore SavedPawnScoreArray[128];

const INVALID_PAWN_IP = "INVALID";
const INVALID_INDEX = -1;

function InitializeSavedPawnScore(out FSavedPawnScore SavedPawnScore)
{
    SavedPawnScore.Score = 0.0;
    SavedPawnScore.Deaths = 0.0;
    SavedPawnScore.DamageDealt = 0.0;
    SavedPawnScore.bFirstBlood = false;
    SavedPawnScore.MaxSpree = 0;
    SavedPawnScore.HeadKills = 0;
    SavedPawnScore.IP = "";
    SavedPawnScore.bOccupied = false;
}

function Initialize(R_GameInfo OwningGameInfo)
{
    local int i;
    for(i = 0; i < MAX_SAVED_PAWN_SCORES; ++i)
    {
        InitializeSavedPawnScore(SavedPawnScoreArray[i]);
    }
    UtilitiesClass.Static.RModLog("Initialized PersistentScoreManager with" @ MAX_SAVED_PAWN_SCORES @ "entries");

    GameInfo = OwningGameInfo;
}

/**
*   GetPawnIPString
*   Returns the IP associated with the given Pawn, or INVALID_PAWN_IP if not valid.
*/
function String GetPawnIPString(Pawn P)
{
    if(P != None && R_PlayerReplicationInfo(P.PlayerReplicationInfo) != None)
    {
        return R_PlayerReplicationInfo(P.PlayerReplicationInfo).PlayerIP;
    }

    return INVALID_PAWN_IP;
}

/**
*   FindSavedPawnScoreIndex
*   Returns the index in the saved pawn score array if the pawn is found,
*   otherwise returns INVALID_INDEX.
*/
function int FindSavedPawnScoreIndex(Pawn P)
{
    local String IP;
    local int i;

    IP = GetPawnIPString(P);
    if(IP == INVALID_PAWN_IP)
    {
        return INVALID_INDEX;
    }

    for(i = 0; i < MAX_SAVED_PAWN_SCORES; ++i)
    {
        if(SavedPawnScoreArray[i].bOccupied && SavedPawnScoreArray[i].IP == IP)
        {
            return i;
        }
    }

    return INVALID_INDEX;
}

/**
*   FindUnoccupiedSavedPawnScoreIndex
*   Returns index of the first available unoccupied saved score struct.
*   Returns INVALID_INDEX if none found.
*/
function int FindUnoccupiedSavedPawnScoreIndex()
{
    local int i;

    for(i = 0; i < MAX_SAVED_PAWN_SCORES; ++i)
    {
        if(SavedPawnScoreArray[i].bOccupied == false)
        {
            return i;
        }
    }

    return INVALID_INDEX;
}

function SetPRIFromSavedPawnScore(PlayerReplicationInfo PRI, out FSavedPawnScore SavedPawnScore)
{
    local R_PlayerReplicationInfo RPRI;

    RPRI = R_PlayerReplicationInfo(PRI);
    if(RPRI == None)
    {
        return;
    }

    RPRI.Score = SavedPawnScore.Score;
    RPRI.Deaths = SavedPawnScore.Deaths;
    RPRI.DamageDealt = SavedPawnScore.DamageDealt;
    RPRI.bFirstBlood = SavedPawnScore.bFirstBlood;
    RPRI.MaxSpree = SavedPawnScore.MaxSpree;
    RPRI.HeadKills = SavedPawnScore.HeadKills;
}

function SetSavedPawnScoreFromPRI(PlayerReplicationInfo PRI, String IP, out FSavedPawnScore SavedPawnScore)
{
    local R_PlayerReplicationInfo RPRI;

    RPRI = R_PlayerReplicationInfo(PRI);
    if(RPRI == None)
    {
        return;
    }

    SavedPawnScore.Score = RPRI.Score;
    SavedPawnScore.Deaths = RPRI.Deaths;
    SavedPawnScore.DamageDealt = RPRI.DamageDealt;
    SavedPawnScore.bFirstBlood = RPRI.bFirstBlood;
    SavedPawnScore.MaxSpree = RPRI.MaxSpree;
    SavedPawnScore.HeadKills = RPRI.HeadKills;
    SavedPawnScore.IP = IP;
    SavedPawnScore.bOccupied = true;
}

/**
*   CheckShouldEnablePersistantScore
*   Returns true if persistant score should be enabled for this player, false otherwise
*/
function bool CheckShouldEnablePersistantScore(Pawn P)
{
    local String PlayerIPString;
    local Pawn PawnIterator;
    local R_PlayerReplicationInfo RPRI;

    PlayerIPString = GetPawnIPString(P);
    if(PlayerIPString == INVALID_PAWN_IP)
    {
        return false;
    }

    // If there's another player in game with the same IP, return false
    for(PawnIterator = GameInfo.Level.PawnList; PawnIterator != None; PawnIterator = PawnIterator.NextPawn)
    {
        if(PawnIterator == P)
        {
            continue;
        }

        if(GetPawnIPString(PawnIterator) == PlayerIPString)
        {
            RPRI = R_PlayerReplicationInfo(PawnIterator.PlayerReplicationInfo);
            if(RPRI != None && RPRI.bShouldPersist)
            {
                return false;
            }
        }
    }

    return true;
}

/**
*   ApplyPersistentScore
*   Called when a persistent score needs to be restored from the provided pawn.
*   If there is no saved score, nothing happens.
*/
function ApplyPersistentScore(Pawn P)
{
    local int SavedPawnScoreIndex;
    local R_PlayerReplicationInfo RPRI;

    RPRI = R_PlayerReplicationInfo(P.PlayerReplicationInfo);
    if(RPRI == None || PlayerPawn(P) == None)
    {
        return;
    }

    // Check if this player's score should persist
    if(!CheckShouldEnablePersistantScore(P))
    {
        UtilitiesClass.Static.RModLog("Disabling score persistance for player" @ RPRI.PlayerName);
        RPRI.bShouldPersist = false;
        return;
    }

    SavedPawnScoreIndex = FindSavedPawnScoreIndex(P);
    if(SavedPawnScoreIndex != INVALID_INDEX)
    {
        UtilitiesClass.Static.RModLog("Restoring persistent score for player" @ RPRI.PlayerName);
        SetPRIFromSavedPawnScore(RPRI, SavedPawnScoreArray[SavedPawnScoreIndex]);
    }
}

/**
*   SavePersistentScore
*   Called when the persistent score for a given pawn needs to be updated.
*   Either updates an existing saved score, or saves a new entry.
*/
function SavePersistentScore(Pawn P)
{
    local int SavedPawnScoreIndex;
    local R_PlayerReplicationInfo RPRI;
    local String IP;

    IP = GetPawnIPString(P);
    if(IP == INVALID_PAWN_IP)
    {
        return;
    }

    RPRI = R_PlayerReplicationInfo(P.PlayerReplicationInfo);
    if(RPRI == None || PlayerPawn(P) == None || !RPRI.bShouldPersist)
    {
        return;
    }

    UtilitiesClass.Static.RModLog("Saving persistent score for player" @ RPRI.PlayerName @ "IP:" @ IP);

    // Check if there's a saved entry already
    SavedPawnScoreIndex = FindSavedPawnScoreIndex(P);
    if(SavedPawnScoreIndex == INVALID_INDEX)
    {
        // No saved entry, find a new one
        SavedPawnScoreIndex = FindUnoccupiedSavedPawnScoreIndex();
    }

    // If it's still invalid, there's a problem saving the score
    if(SavedPawnScoreIndex == INVALID_INDEX)
    {
        UtilitiesClass.Static.RModWarn("Failed to save persistent score data");
    }
    else
    {
        SetSavedPawnScoreFromPRI(RPRI, IP, SavedPawnScoreArray[SavedPawnScoreIndex]);
    }
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}
//==============================================================================
//  R_TempBanManager
//  Manages temporary bans that should persist only for the current level.
//==============================================================================
class R_TempBanManager extends Object;

var Class<R_AUtilities> UtilitiesClass;
var R_GameInfo GameInfo;

struct FTempBanParameters
{
    var String PlayerIPString;  // The banned IP
    var float TimeStampSeconds; // When the ban was initiated
    var float DurationSeconds;  // The duration of the ban
    var String ReasonString;    // String explaining why the player is banned
};
const MAX_TEMP_BANS = 128;
var FTempBanParameters TempBanArray[128];

const INVALID_INDEX = -1;

/**
*   Initialize
*   Temp ban manager initialization, called from R_GameInfo.
*/
function Initialize(R_GameInfo RGI)
{
    local int i;

    GameInfo = RGI;

    for(i = 0; i < MAX_TEMP_BANS; ++i)
    {
        TempBanArray[i].PlayerIPString = "";
        TempBanArray[i].TimeStampSeconds = 0.0;
        TempBanArray[i].DurationSeconds = 0.0;
        TempBanArray[i].ReasonString = "";
    }

    UtilitiesClass.Static.RModLog("Initialized temp ban manager with" @ MAX_TEMP_BANS @ "entries");
}

/**
*   FindTempBanEntryIndexByPlayerIPString
*   Returns the index for the specified player IP if they are banned.
*   Returns INVALID_INDEX if no ban is in place.
*/
function int FindTempBanEntryIndexByPlayerIPString(String PlayerIPString)
{
    local int i;

    for(i = 0; i < MAX_TEMP_BANS; ++i)
    {
        if(TempBanArray[i].PlayerIPString == PlayerIPString)
        {
            return i;
        }
    }

    return INVALID_INDEX;
}

/**
*   FindAvailableTempBanIndex
*   Returns the index of an available temp ban in the ban array.
*   Returns INVALID_INDEX if none found.
*/
function int FindAvailableTempBanIndex()
{
    local int i;

    for(i = 0; i < MAX_TEMP_BANS; ++i)
    {
        if(TempBanArray[i].PlayerIPString == "")
        {
            return i;
        }
    }

    return INVALID_INDEX;
}

/**
*   ApplyTempBan
*   Ban a player for some duration.
*/
function ApplyTempBan(String PlayerIPString, float DurationSeconds, String ReasonString)
{
    local int TempBanIndex;

    // Check for an existing temp ban entry
    TempBanIndex = FindTempBanEntryIndexByPlayerIPString(PlayerIPString);
    if(TempBanIndex == INVALID_INDEX)
    {
        // If no existing temp ban, create a new one
        TempBanIndex = FindAvailableTempBanIndex();
    }

    // If invalid temp ban index, something went wrong
    if(TempBanIndex == INVALID_INDEX)
    {
        UtilitiesClass.Static.RModLog("Failed to temporarily ban IP" @ PlayerIPString);
        return;
    }

    TempBanArray[TempBanIndex].PlayerIPString = PlayerIPString;
    TempBanArray[TempBanIndex].TimeStampSeconds = GameInfo.Level.TimeSeconds;
    TempBanArray[TempBanIndex].DurationSeconds = DurationSeconds;
    TempBanArray[TempBanIndex].ReasonString = ReasonString;

    if(ReasonString != "")
    {
        UtilitiesClass.Static.RModLog("Banned" @ PlayerIPString @ "for" @ DurationSeconds @ "seconds" @ "Reason:" @ ReasonString);
    }
    else
    {
        UtilitiesClass.Static.RModLog("Banned" @ PlayerIPString @ "for" @ DurationSeconds @ "seconds");
    }
}

/**
*   CheckTempBan
*   Returns whether or not the provided IP has a temp ban in place.
*   If there is a temp ban, the remaining duration is returned in RemainingDurationSeconds.
*/
function bool CheckTempBan(String PlayerIPString, out float RemainingDurationSeconds, out String ReasonString)
{
    local int TempBanIndex;
    local float RemainingBanSeconds;

    // Check for existing temp ban
    TempBanIndex = FindTempBanEntryIndexByPlayerIPString(PlayerIPString);
    if(TempBanIndex == INVALID_INDEX)
    {
        return false;
    }

    // Check if temp ban is expired
    RemainingBanSeconds = TempBanArray[TempBanIndex].DurationSeconds - (GameInfo.Level.TimeSeconds - TempBanArray[TempBanIndex].TimeStampSeconds);
    if(RemainingBanSeconds < 0.0)
    {
        return false;
    }

    RemainingDurationSeconds = RemainingBanSeconds;
    ReasonString = TempBanArray[TempBanIndex].ReasonString;
    return true;
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}
//==============================================================================
//	R_AnimData
//	Animation data lookup table
//==============================================================================
class R_AnimData extends Object config(RBotsAnimData);

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'AnimData';

const InvalidIndex = -1;

var private config Name AnimNames[4096];
var private config float AnimDurations[ArrayCount(AnimNames)];

//------------------------------------------------------------------------------
//	Hash table functions
static function int GetNameLookupHash(Name NameValue)
{
    local string NameString;
    local int Hash, i, c;

    NameString = string(NameValue);
    Hash = 5381;

    for (i = 0; i < Len(NameString); i++)
    {
        c = Asc(Mid(NameString, i, 1));
        Hash = ((Hash * 33) + c);
    }

    return Hash & 4095;
}

function int Insert(Name AnimName)
{
	local int Hash, Index;
	local int i;

	Hash = GetNameLookupHash(AnimName);
	for(i = 0; i < ArrayCount(AnimNames); ++i)
	{
		Index = i % ArrayCount(AnimNames);
		if(AnimNames[Index] == '')
		{
			AnimNames[Index] = AnimName;
			return Index;
		}
		else if(AnimNames[Index] == AnimName)
		{
			return Index;
		}
	}

	Utilities.Static.RLog("AnimData Insert failed for anim:" @ AnimName, LogCategory);
	return InvalidIndex;
}

function int Find(Name AnimName)
{
	local int Hash, Index;
	local int i;

	Hash = GetNameLookupHash(AnimName);
	for(i = 0; i < ArrayCount(AnimNames); ++i)
	{
		Index = i % ArrayCount(AnimNames);
		if(AnimNames[Index] == AnimName)
		{
			return Index;
		}
		if(AnimNames[Index] == '')
		{
			return InvalidIndex;
		}
	}

	return InvalidIndex;
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
//	Animation data
function float GetAnimDuration(Name AnimName)
{
	local int Index;

	Index = Find(AnimName);
	if(Index == InvalidIndex)
	{
		return 0.0;
	}

	return AnimDurations[Index];
}

function SetAnimDuration(Name AnimName, float Duration)
{
	local int Index;

	Index = Insert(AnimName);
	if(Index != InvalidIndex)
	{
		AnimDurations[Index] = Duration;
		SaveConfig();
	}
}
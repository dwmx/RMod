//==============================================================================
//	R_BehaviorTask
//==============================================================================
class R_BehaviorTask extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorTask';

struct R_ParameterMappings
{
	var Name BlackBoardKey;
	var Name TaskParameter;
};
var private R_ParameterMappings ParameterMappings[32];
var private int NumParameterMappings;

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

static function String GetTaskDisplayString() { return "Task"; }

//------------------------------------------------------------------------------

function MapBlackBoardKey(Name BlackBoardKey, Name TaskParameter)
{
	local String LogString;

	if(NumParameterMappings >= ArrayCount(ParameterMappings))
	{
		LogString = "MapBlackBoardKey failed -- array overflow";
		Warn(LogString);
		Utilities.Static.RLog(LogString, LogCategory);
		return;
	}

	ParameterMappings[NumParameterMappings].BlackBoardKey = BlackBoardKey;
	ParameterMappings[NumParameterMappings].TaskParameter = TaskParameter;
	++NumParameterMappings;
}

function bool GetMappedBlackBoardKey(Name TaskParameter, out Name OutBlackBoardKey)
{
	local int i;

	for(i = 0; i < NumParameterMappings; ++i)
	{
		if(ParameterMappings[i].TaskParameter == TaskParameter)
		{
			OutBlackBoardKey = ParameterMappings[i].BlackBoardKey;
			return true;
		}
	}
	return false;
}

//------------------------------------------------------------------------------

function bool ReadMappedInt(R_BlackBoard BlackBoard, Name TaskParameter, out int OutValue)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.GetInt(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedFloat(R_BlackBoard BlackBoard, Name TaskParameter, out float OutValue)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.GetFloat(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedVector(R_BlackBoard BlackBoard, Name TaskParameter, out Vector OutValue)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.GetVector(BBKey, OutValue);
	}
	return false;
}

function bool ReadMappedActor(R_BlackBoard BlackBoard, Name TaskParameter, out Actor OutValue)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.GetActor(BBKey, OutValue);
	}
	return false;
}

//------------------------------------------------------------------------------

function bool WriteMappedInt(R_BlackBoard BlackBoard, Name TaskParameter, int Value)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.SetInt(BBKey, Value);
	}
	return false;
}

function bool WriteMappedFloat(R_BlackBoard BlackBoard, Name TaskParameter, float Value)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.SetFloat(BBKey, Value);
	}
	return false;
}

function bool WriteMappedVector(R_BlackBoard BlackBoard, Name TaskParameter, Vector Value)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.SetVector(BBKey, Value);
	}
	return false;
}

function bool WriteMappedActor(R_BlackBoard BlackBoard, Name TaskParameter, Actor Value)
{
	local Name BBKey;
	if(BlackBoard != None && GetMappedBlackBoardKey(TaskParameter, BBKey))
	{
		return BlackBoard.SetActor(BBKey, Value);
	}
	return false;
}

//------------------------------------------------------------------------------
//	Bot Utilities
function R_BotPawnController GetPawnController(R_Bot Bot)
{
	if(Bot == None)
	{
		return None;
	}
	return Bot.GetBotPawnController();
}

function PlayerPawn GetPlayerPawn(R_Bot Bot)
{
	if(Bot == None)
	{
		return None;
	}
	return Bot.GetOwnedPlayerPawn();
}

//------------------------------------------------------------------------------

function TaskActivated(R_Bot Bot, R_BlackBoard BlackBoard);
function TaskDeactivated(R_Bot Bot, R_BlackBoard BlackBoard);
function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds);
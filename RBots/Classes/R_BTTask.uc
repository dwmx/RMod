//==============================================================================
//	R_BTTask
//	Asynchronous Behavior Task
//	Do not override Tick -- use TickTask
//	Tasks will continue to run until the Task calls:
//		- EndTaskSuccess -- Finished successfully
//		- EndTaskFail -- Task failed
//==============================================================================
class R_BTTask extends R_BTNode abstract;

var private R_Bot BotReference;
var private R_BotPawnController PawnController;
var private int Result;

static function String GetNodeClassString() { return "Task"; }

function SetBotReference(R_Bot NewBotReference) { BotReference = NewBotReference; }
function R_Bot GetBot() { return BotReference; }

function R_BotPawnController GetPawnController()
{
	local R_Bot Bot;
	if(PawnController == None)
	{
		Bot = GetBot();
		if(Bot != None)
		{
			PawnController = R_BotPawnController(Bot.GetBotObjectByClass(Class'RBots.R_BotPawnController'));
		}
	}
	
	return PawnController;
}

function int Tick(float DeltaSeconds)
{
	Result = NodeRunning;
	TickTask(DeltaSeconds);
	return Result;
}

function EndTaskSuccess()
{
	Result = NodeSuccess;
}

function EndTaskFail()
{
	Result = NodeFail;
}

function TickTask(float DeltaSeconds);

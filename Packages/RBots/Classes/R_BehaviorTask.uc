//==============================================================================
//	R_BehaviorTask
//==============================================================================
class R_BehaviorTask extends R_BehaviorAction abstract;

const LogCategory = 'BehaviorTask';

const TaskSuccess = 0;
const TaskFail = 1;
const TaskInProgress = 2;

//------------------------------------------------------------------------------

static function String GetTaskDisplayString() { return "Task"; }

//------------------------------------------------------------------------------
//	RBots Utilities
function R_NavQueryInterface GetNavQueryInterface()
{
	local R_RBotsServerActor LocalRBots;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots != None)
	{
		return LocalRBots.GetNavQueryInterface();
	}
	return None;
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

function Vector GetPawnLocation(R_Bot Bot)
{
	local Pawn P;

	P = GetPlayerPawn(Bot);
	if(P != None)
	{
		return P.Location;
	}
	return Vect(0,0,0);
}

//------------------------------------------------------------------------------

function TaskActivated(R_BTI_TaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function TaskDeactivated(R_BTI_TaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard);
function int TickTask(R_BTI_TaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds);

defaultproperties
{
	InstanceClass=Class'RBots.R_BTI_TaskInstance'
}
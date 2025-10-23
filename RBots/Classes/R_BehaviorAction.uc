//==============================================================================
//	R_BehaviorAction
//	BehaviorActions are objects which control the actual actions and decisions
//	that occur when executing a BehaviorTree
//==============================================================================
class R_BehaviorAction extends R_VirtualAsset abstract;

const LogCategory = 'BehaviorAction';

var private Class<R_BehaviorActionInstance> InstanceClass;

//------------------------------------------------------------------------------

function R_BehaviorActionInstance CreateInstance()
{
	local String LogString;
	local R_RBotsServerActor LocalRBots;
	local R_BehaviorActionInstance Instance;

	LocalRBots = GetRBotsServerActor();
	if(LocalRBots == None)
	{
		LogString = CommonError_InvalidRBots;
		GoTo FailWithLogString;
	}

	if(InstanceClass == None)
	{
		LogString = "Invalid InstanceClass:" @ InstanceClass;
		GoTo FailWithLogString;
	}

	// Create instance with deferred initialization so that Self can be set to the base first
	Instance = R_BehaviorActionInstance(LocalRBots.CreateRBotsObject(InstanceClass, Self, true));
	if(Instance == None)
	{
		LogString = "Failed to create instance";
		GoTo FailWithLogString;
	}

	Instance.SetBehaviorAction(Self);
	Instance.Initialize();
	AddParameters(Instance);
	return Instance;

FailWithLogString:
	LogString = "CreateInstance failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return None;
}

function AddParameters(R_BehaviorActionInstance Instance);
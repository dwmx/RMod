//==============================================================================
//	R_BTNode_Action
//==============================================================================
class R_BTNode_Action extends R_BTNode abstract;

const LogCategory = 'BehaviorTreeActionNode';

var private Class<R_BehaviorActionInstance> RequiredBehaviorActionInstanceClass;
var private R_BehaviorActionInstance BehaviorActionInstance;

//------------------------------------------------------------------------------

function R_BehaviorActionInstance GetBehaviorActionInstance()
{
	return BehaviorActionInstance;
}

function SetBehaviorActionInstance(R_BehaviorActionInstance NewBehaviorActionInstance)
{
	local String LogString;

	if(NewBehaviorActionInstance != None && !ClassIsChildOf(NewBehaviorActionInstance.Class, RequiredBehaviorActionInstanceClass))
	{
		LogString = "Invalid BehaviorActionInstance:" @ NewBehaviorActionInstance $ ", must be of type" @ RequiredBehaviorActionInstanceClass;
		GoTo FailWithLogString;
	}

	BehaviorActionInstance = NewBehaviorActionInstance;
	return;

FailWithLogString:
	LogString = "SetBehaviorActionInstance failed --" @ LogString;
	Warn(LogString);
	Utilities.Static.RLog(LogString, LogCategory);
	return;
}

//------------------------------------------------------------------------------

defaultproperties
{
	RequiredBehaviorActionInstanceClass=Class'RBots.R_BehaviorActionInstance'
}
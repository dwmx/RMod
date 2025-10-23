//==============================================================================
//	R_BTB_TaskBuilder
//==============================================================================
class R_BTB_TaskBuilder extends R_RBotsObject;

var private R_BehaviorActionInstance BehaviorActionInstance;

function SetBehaviorActionInstance(R_BehaviorActionInstance NewBehaviorActionInstance)
{
	BehaviorActionInstance = NewBehaviorActionInstance;
}

function R_BTB_TaskBuilder SetParameter(Name ParamName, R_Variant Value)
{
	BehaviorActionInstance.SetParameter(ParamName, Value);
	return Self;
}
//==============================================================================
//	R_BTB_TaskBuilder
//==============================================================================
class R_BTB_TaskBuilder extends R_BTB_ActionBuilder;

function R_BTB_TaskBuilder SetParameter(Name ParamName, R_Variant Value)
{
	InternalSetParameter(ParamName, Value);
	return Self;
}
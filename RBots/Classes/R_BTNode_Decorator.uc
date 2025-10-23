//==============================================================================
//	R_BTNode_Decorator
//	Behavior Tree node containing a Decorator
//==============================================================================
class R_BTNode_Decorator extends R_BTNode_Action;

var private R_BTI_DecoratorInstance DecoratorInstance;

function String GetNodeDisplayString()
{
	return "Decorator";
}

defaultproperties
{
	RequiredBehaviorActionInstanceClass=Class'RBots.R_BTI_DecoratorInstance'
}
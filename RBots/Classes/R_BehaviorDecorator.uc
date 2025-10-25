//==============================================================================
//	R_BehaviorDecorator
//==============================================================================
class R_BehaviorDecorator extends R_BehaviorAction abstract;

const LogCategory = 'BehaviorDecorator';

function DecoratorActivated(R_BTI_DecoratorInstance Instance, R_Bot Bot, R_DecoratorMemory Memory)
{
}

function DecoratorDeactivated(R_BTI_DecoratorInstance Instance, R_Bot Bot, R_DecoratorMemory Memory)
{
}

function DecoratorTick(R_BTI_DecoratorInstance Instance, R_Bot Bot, R_DecoratorMemory Memory, float ActiveTime, float DeltaSeconds)
{}

defaultproperties
{
	InstanceClass=Class'RBots.R_BTI_DecoratorInstance'
}
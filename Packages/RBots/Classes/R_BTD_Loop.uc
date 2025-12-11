//==============================================================================
//	R_BTD_Loop
//==============================================================================
class R_BTD_Loop extends R_BehaviorDecorator;

function AddParameters(R_BehaviorActionInstance Instance)
{
	Instance.AddParameter('Iterations', TypeCodeInt);
}
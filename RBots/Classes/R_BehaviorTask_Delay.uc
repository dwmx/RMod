//==============================================================================
//	R_BehaviorTask_Delay
//==============================================================================
class R_BehaviorTask_Delay extends R_BehaviorTask;

function AddTaskParameters(R_BehaviorTaskInstance TaskInstance)
{
	TaskInstance.AddParameter('Duration', TypeCodeFloat);
}
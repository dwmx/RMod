//==============================================================================
//	R_BehaviorTree_CompositeTree
//	This tree is just a test to check functionality of the SubTree node
//==============================================================================
class R_BehaviorTree_CompositeTree extends R_BehaviorTree;

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
	BT.CreateSequence();
	BT.Push();
		BT.CreateSubTree(Class'R_BehaviorTree_Wander');
		BT.CreateSubTree(Class'R_BehaviorTree_NavigateToGoal');
}
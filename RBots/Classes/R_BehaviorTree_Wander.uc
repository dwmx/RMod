//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

//------------------------------------------------------------------------------

function AddKeySetToBlackBoard(R_BlackBoard BlackBoard)
{
	BlackBoard.Add('MyTestFloat', TypeCodeFloat);
	BlackBoard.Add('MyTestInt', TypeCodeInt);
	BlackBoard.Add('EquipTarget', TypeCodeActor);
	BlackBoard.Add('MoveDirection', TypeCodeVector);
	BlackBoard.Add('TargetNavZoneIndex', TypeCodeInt);
	BlackBoard.Add('MyTestClass', TypeCodeClass);
	BlackBoard.Add('MyLookTarget', TypeCodeVector);
}

function BuildBehaviorTree(R_BehaviorTreeBuilder BT)
{
}
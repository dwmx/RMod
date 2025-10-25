//==============================================================================
//	R_BehaviorTree_Wander
//	Wander around like an idiot
//==============================================================================
class R_BehaviorTree_Wander extends R_BehaviorTree;

const BTT_Delay = Class'RBots.R_BTT_Delay';
const BTT_SelectDirectionTowardsNavZone = Class'RBots.R_BTT_SelectDirectionTowardsNavZone';

const BTD_Loop = Class'RBots.R_BTD_Loop';

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
	BlackBoard.Add('MyExampleInteger', TypeCodeInt);
	BlackBoard.Add('MyExampleVector', TypeCodeVector);
}

function BuildBehaviorTree(R_BTB_TreeBuilder TB)
{
	TB.BeginSequence('TopLevelSequence');
	TB.AddDecorator(BTD_Loop, 'TopLevelSequence');

		TB.CreateTask(BTT_Delay)
			.SetParameter('Duration', MakeFloatVariant(1.0));

		TB.CreateTask(BTT_Delay, 'ThisOneLoops')
			.SetParameter('Duration', MakeFloatVariant(7.0));
		TB.AddDecorator(BTD_Loop, 'ThisOneLoops')
			.SetParameter('Iterations', MakeIntVariant(3))
			.SetAbortType(0);

		TB.CreateTask(BTT_Delay)
			.SetParameter('Duration', MakeFloatVariant(9.0));
		
		// This one writes to a couple keys
		TB.CreateTask(BTT_SelectDirectionTowardsNavZone)
			.SetParameter('NavZoneIndexKey', MakeNameVariant('TargetNavZoneIndex'))
			.SetParameter('DirectionKey', MakeNameVariant('MoveDirection'));
		
		// This one writes to a couple other keys
		TB.CreateTask(BTT_SelectDirectionTowardsNavZone)
			.SetParameter('NavZoneIndexKey', MakeNameVariant('MyExampleInteger'))
			.SetParameter('DirectionKey', MakeNameVariant('MyExampleVector'));

	TB.EndSequence(); // TopLevelSequence
}
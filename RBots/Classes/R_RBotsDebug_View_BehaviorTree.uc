//==============================================================================
//	R_RBotsDebug_View_BehaviorTree
//	Debug visualization for Behavior Trees
//==============================================================================
class R_RBotsDebug_View_BehaviorTree extends R_RBotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';

const StringCategoryBT = 'BehaviorTree';

function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	local R_RBotsDebug DebugMutator;
	local R_Bot DebugTarget;
	local R_BotBehavior ActiveBehavior;
	local R_BTNode BehaviorTree;

	StringManager.AddCategory(StringCategoryBT);

	DebugMutator = GetDebugMutator();
	if(DebugMutator != None)
	{
		DebugTarget = DebugMutator.DebugTarget;
	}

	if(DebugTarget != None)
	{
		ActiveBehavior = DebugTarget.GetActiveBehavior();
		if(ActiveBehavior != None)
		{
			BehaviorTree = ActiveBehavior.GetBehaviorTree();
		}
	}

	DrawBehaviorTree(C, StringManager, BehaviorTree);
}

function DrawBehaviorTree(Canvas C, R_RBotsDebug_StringManager StringManager, R_BTNode BehaviorTree)
{
	if(BehaviorTree == None)
	{
		StringManager.AddWarning(StringCategoryBT, "No Behavior Tree reference available -- select a Bot DebugTarget");
		return;
	}

	DrawBehaviorTreeValidated(C, BehaviorTree);
}

function DrawBehaviorTreeValidated(Canvas C, R_BTNode BT)
{
	local R_BTNode NodeStack[128];
	local int NodeDepth[128];
	local byte NodeActive[128];
	local int NumNodes;
	local R_BTNode CurrentNode;
	local R_BTNode_Composite CurrentCompositeNode;
	local bool bCurrentIsActive;
	local int CurrentDepth;
	local int NumChildren;
	local int i;
	local float XPos, YPos;
	local float XDraw;
	local float RGBInactive[3], RGBActive[3];

	DebugLib.Static.InitializeCanvasForDebugDrawing(C);
	C.Style = 1;

	RGBInactive[0] = 1.0;
	RGBInactive[1] = 1.0;
	RGBInactive[2] = 1.0;

	RGBActive[0] = 1.0;
	RGBActive[1] = 1.0;
	RGBActive[2] = 0.0;

	XPos = C.ClipX * 0.5;
	YPos = C.ClipY * 0.1;

	NodeStack[0] = BT;
	NodeDepth[0] = 0;
	NodeActive[0] = 1;
	
	NumNodes = 1;

	while(NumNodes > 0)
	{
		--NumNodes;
		CurrentNode = NodeStack[NumNodes];
		CurrentDepth = NodeDepth[NumNodes];
		bCurrentIsActive = (NodeActive[NumNodes] == 1);

		CurrentCompositeNode = R_BTNode_Composite(CurrentNode);
		if(CurrentCompositeNode != None)
		{
			NumChildren = 0;
			NumChildren = CurrentCompositeNode.GetChildCount();
			for(i = NumChildren - 1; i >= 0; --i)
			{
				NodeStack[NumNodes] = CurrentCompositeNode.GetChild(i);
				NodeDepth[NumNodes] = CurrentDepth + 1;
				//if(CurrentCompositeNode.IsChildActive(i))
				//{
				//	NodeActive[NumNodes] = 1;
				//}
				//else
				//{
				//	NodeActive[NumNodes] = 0;
				//}
				++NumNodes;
			}
		}

		XDraw = XPos + 16.0 * float(CurrentDepth);
		if(bCurrentIsActive)
		{
			CanvasLib.Static.DrawText2D(C, XDraw, YPos, Vect(0,0,0), RGBActive, GetBehaviorNodeString(CurrentNode));
		}
		else
		{
			CanvasLib.Static.DrawText2D(C, XDraw, YPos, Vect(0,0,0), RGBInactive, GetBehaviorNodeString(CurrentNode));
		}
		YPos += 12.0;
	}
}

function String GetBehaviorNodeString(R_BTNode Node)
{
	local Class<R_BTNode> NodeClass;

	if(Node == None)
	{
		return "None";
	}

	NodeClass = Node.Class;
	if(NodeClass != None)
	{
		return NodeClass.Static.GetNodeClassString();
	}

	return String(Node.Class);
}
//==============================================================================
//	R_RbotsDebug_View_Bots
//	Debug View for RBots Bots
//==============================================================================
class R_RbotsDebug_View_Bots extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const CanvasBaseLib = Class'RBase.R_ACanvasLibrary';
const NavLib = Class'RBots.R_NavLibrary';

const DebugRBotsCategory = 'DebugTarget';
const DebugNavigation = 'DebugTargetNavigation';

var Color MovementInputColor;
var Color PerceptionColor_Idle;
var Color PerceptionColor_Attacking;
var Color PerceptionColor_Defending;
var Color PerceptionColor_VulnerableMoving;
var Color PerceptionColor_VulnerableStationary;
var Color EngagementColor_Minimum;
var Color EngagementColor_Maximum;

var private bool bDrawPerception;

// Values returned from GetPerceivedActorCombatState
const CombatState_None = 0;
const CombatState_Idle = 1;
const CombatState_Attacking = 2;
const CombatState_Defending = 3;
const CombatState_VulnerableMoving = 4;
const CombatState_VulnerableStationary = 5;

// Parameter visualizer
var private R_RBotsDebug_ParameterVisualizer ParameterVisualizer;

function ToggleDrawPerception() { bDrawPerception = !bDrawPerception; }

simulated function DrawDebugView(Canvas C, R_RBotsDebug_StringManager StringManager)
{
	local R_RBotsDebug DebugMutator;
	local R_Bot DebugTarget;

	StringManager.AddCategory(DebugRBotsCategory);

	DebugMutator = GetDebugMutator();
	if(DebugMutator != None)
	{
		DebugTarget = DebugMutator.DebugTarget;
	}

	if(DebugTarget != None)
	{
		DrawDebugTarget(C, StringManager, DebugTarget);

		if(R_RBotsDebug_DebugBot(DebugTarget) != None)
		{	// Draw debug DebugBot information
			DrawDebugTaret_DebugBot(C, StringManager, R_RBotsDebug_DebugBot(DebugTarget));
		}

		// Draw Nav information
		DrawDebugTarget_Navigation(C, StringManager, DebugTarget);
	}
	else
	{
		StringManager.AddString(DebugRBotsCategory, "No Debug Target selected");
	}

	if(ParameterVisualizer == None)
	{
		ParameterVisualizer = new(None) Class'RBots.R_RBotsDebug_ParameterVisualizer';
		ParameterVisualizer.Initialize();
		ParameterVisualizer.SetParameterNameString("Target Desirability");
		ParameterVisualizer.SetValueLimits(-1.0, 1.0);
	}
	if(ParameterVisualizer != None && DebugTarget != None)
	{
		//ParameterVisualizer.Push(Cos(DebugTarget.Level.TimeSeconds) * 0.5 + 0.5);
		ParameterVisualizer.DrawParameterVisualizer(
			C,
			(C.CLipX - 32.0) - 512.0,
			32.0,
			C.ClipX - 32.0,
			32.0 + 224.0);
	}
}

simulated function DrawDebugTarget(Canvas C, R_RBotsDebug_StringManager StringManager, R_Bot BotDebugTarget)
{
	local R_BotBehavior ActiveBehavior;

	// Add color legend
	StringManager.AddColor(DebugRBotsCategory, "Movement Input", MovementInputColor);

	// Add strings
	StringManager.AddActor(DebugRBotsCategory, "DebugTarget", BotDebugTarget);
	if(BotDebugTarget != None)
	{
		StringManager.AddActor(DebugRBotsCategory, "OwnedPlayerPawn", BotDebugTarget.GetOwnedPlayerPawn());
		StringManager.AddActor(DebugRBotsCategory, "OwnedPRI", BotDebugTarget.GetOwnedPRI());

		ActiveBehavior = BotDebugTarget.GetActiveBehavior();
		StringManager.AddObject(DebugRBotsCategory, "ActiveBehavior", ActiveBehavior);
		if(ActiveBehavior != None)
		{
			StringManager.AddString(DebugRBotsCategory, ActiveBehavior.GetDescriptiveString(), "ActiveBehavior Description");
		}
		
		// Draw perception
		if(bDrawPerception)
		{
			DrawDebugTarget_Perception(C, StringManager, BotDebugTarget);
		}
		
		// Draw movement input vector
		DrawDebugTarget_MovementInput(C, BotDebugTarget);
	}
}

function DrawDebugTarget_Perception(Canvas C, R_RBotsDebug_StringManager StringManager, R_Bot BotDebugTarget)
{
	local R_BotPerception BotPerception;
	local Actor PerceivedActor;
	local PlayerPawn PP;
	local float RGBCombatState[3];
	local Color EngagementColor;
	local float RGBEngagement[3];
	local int CombatState;
	local float EngagementScore;

	PP = BotDebugTarget.GetOwnedPlayerPawn();
	if(PP == None)
	{
		return;
	}

	StringManager.AddColor(DebugRBotsCategory, "Perception_Idle", PerceptionColor_Idle);
	StringManager.AddColor(DebugRBotsCategory, "Perception_Attacking", PerceptionColor_Attacking);
	StringManager.AddColor(DebugRBotsCategory, "Perception_Defending", PerceptionColor_Defending);
	StringManager.AddColor(DebugRBotsCategory, "Perception_VulnerableMoving", PerceptionColor_VulnerableMoving);
	StringManager.AddColor(DebugRBotsCategory, "Perception_VulnerableStationary", PerceptionColor_VulnerableStationary);

	BotPerception = R_BotPerception(BotDebugTarget.GetBotObjectByClass(Class'RBots.R_BotPerception'));
	if(BotPerception != None)
	{
		PerceivedActor = BotPerception.GetPerceivedActor();
		if(PerceivedActor != None)
		{
			// Draw a colored line indicating how much the bot wants to engage the target
			EngagementScore = BotPerception.GetPerceivedActorEngagementScore();
			if(ParameterVisualizer != None)
			{	// Push score to param visualizer if it's enabled
				ParameterVisualizer.Push(EngagementScore);
			}
			EngagementColor = Utilities.Static.LerpColor(EngagementColor_Minimum, EngagementColor_Maximum, EngagementScore);

			Utilities.Static.ColorToFloats(EngagementColor, RGBEngagement[0], RGBEngagement[1], RGBEngagement[2]);
			CanvasLib.Static.DrawLine3D(C, PP.Location, PerceivedActor.Location, RGBEngagement[0], RGBEngagement[1], RGBEngagement[2]);

			// Draw a circle around the bot's target, indicating combat state
			CombatState = BotPerception.GetPerceivedActorCombatState();
			switch(CombatState)
			{
			case CombatState_Idle:					Utilities.Static.ColorToFloats(PerceptionColor_Idle, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);					break;
			case CombatState_Attacking:				Utilities.Static.ColorToFloats(PerceptionColor_Attacking, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);				break;
			case CombatState_Defending:				Utilities.Static.ColorToFloats(PerceptionColor_Defending, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);				break;
			case CombatState_VulnerableMoving:		Utilities.Static.ColorToFloats(PerceptionColor_VulnerableMoving, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);		break;
			case CombatState_VulnerableStationary:	Utilities.Static.ColorToFloats(PerceptionColor_VulnerableStationary, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);	break;
			}
			CanvasBaseLib.Static.DrawCircle3D(C, PerceivedActor.Location, Vect(0.0,0.0,1.0), PerceivedActor.CollisionRadius, 32, RGBCombatState[0], RGBCombatState[1], RGBCombatState[2]);
		}
	}
}

// Draw debug information specific to DebugBots
simulated function DrawDebugTaret_DebugBot(Canvas C, R_RBotsDebug_StringManager StringManager, R_RBotsDebug_DebugBot DebugBotDebugTarget)
{
	StringManager.AddActor(DebugRBotsCategory, "CurrentPathingTarget", DebugBotDebugTarget.GetCurrentPathingTarget());
}

simulated function DrawDebugTarget_MovementInput(Canvas C, R_Bot BotDebugTarget)
{
	local float MovementRGB[3];
	local PlayerPawn P;
	local Vector InputVector;
	local Vector DrawVector;

	P = BotDebugTarget.GetOwnedPlayerPawn();
	if(P != None)
	{
		InputVector = BotDebugTarget.GetLastInputVector();
		DrawVector = InputVector * 64.0;

		Utilities.Static.ColorToFloats(MovementInputColor, MovementRGB[0], MovementRGB[1], MovementRGB[2]);
		CanvasLib.Static.DrawLine3D(C, P.Location, (P.Location + DrawVector), MovementRGB[0], MovementRGB[1], MovementRGB[2]);
	}
}

function DrawDebugTarget_Navigation(Canvas C, R_RBotsDebug_StringManager StringManager, R_Bot BotDebugTarget)
{
	local R_IndexCache RecentlyVisitedNodes;
	local R_IndexCache RecentlyVisitedPolyGroups;
	local int MaxArrayIndicesToDraw;
	local int IndexCount;
	local int Index;
	local int i;

	MaxArrayIndicesToDraw = 8;

	// Recently Visited Nodes
	RecentlyVisitedNodes = BotDebugTarget.GetRecentlyVisitedNodes();
	if(RecentlyVisitedNodes == None)
	{
		StringManager.AddWarning(DebugNavigation, "RecentlyVisitedNodes IndexCache is None");
	}
	else
	{
		IndexCount = RecentlyVisitedNodes.GetNumIndices();
		StringManager.AddInt(DebugNavigation, "RecentNodes Count", IndexCount);

		IndexCount = Clamp(IndexCount, 0, MaxArrayIndicesToDraw);
		for(i = 0; i < IndexCount; ++i)
		{
			Index = RecentlyVisitedNodes.Get(i);
			StringManager.AddInt(DebugNavigation, "RecentNodes[" $ i $ "]", Index);
		}
		for(i = i; i < MaxArrayIndicesToDraw; ++i)
		{
			StringManager.AddName(DebugNavigation, "RecentNodes[" $ i $ "]", 'Empty');
		}
	}

	// Recently Visited Poly Groups
	RecentlyVisitedPolyGroups = BotDebugTarget.GetRecentlyVisitedPolyGroups();
	if(RecentlyVisitedPolyGroups == None)
	{
		StringManager.AddWarning(DebugNavigation, "RecentlyVisitedPolyGroups IndexCache is None");
	}
	else
	{
		IndexCount = RecentlyVisitedPolyGroups.GetNumIndices();
		StringManager.AddInt(DebugNavigation, "RecentPolyGroups Count", IndexCount);

		IndexCount = Clamp(IndexCount, 0, MaxArrayIndicesToDraw);
		for(i = 0; i < IndexCount; ++i)
		{
			Index = RecentlyVisitedPolyGroups.Get(i);
			StringManager.AddInt(DebugNavigation, "RecentPolyGroups[" $ i $ "]", Index);
		}
		for(i = i; i < MaxArrayIndicesToDraw; ++i)
		{
			StringManager.AddName(DebugNavigation, "RecentPolyGroups[" $ i $ "]", 'Empty');
		}
	}
}

defaultproperties
{
	MovementInputColor=(R=214,G=38,B=38)
	PerceptionColor_Idle=(R=219,G=255,B=15)
	PerceptionColor_Attacking=(R=255,G=11,B=11)
	PerceptionColor_Defending=(R=255,G=12,B=255)
	PerceptionColor_VulnerableMoving=(R=27,G=228,B=255)
	PerceptionColor_VulnerableStationary=(R=0,G=255,B=34)
	EngagementColor_Minimum=(R=255,G=0,B=0)
	EngagementColor_Maximum=(R=0,G=255,B=0)
	bDrawPerception=true
}
//==============================================================================
//	R_RbotsDebug_View_Bots
//	Debug View for RBots Bots
//==============================================================================
class R_RbotsDebug_View_Bots extends R_RbotsDebug_View;

const Utilities = Class'RBots.R_BotUtilities';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const DebugRBotsCategory = 'DebugTarget';

var Color MovementInputColor;

simulated function DrawDebugView(Canvas C, R_RBotsDebug_StringManager StringManager)
{
	local R_RBotsDebug DebugMutator;
	local R_Bot DebugTarget;

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
	}
}

simulated function DrawDebugTarget(Canvas C, R_RBotsDebug_StringManager StringManager, R_Bot BotDebugTarget)
{
	local R_Behavior ActiveBehavior;

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
		
		// Draw movement input vector
		DrawDebugTarget_MovementInput(C, BotDebugTarget);
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

defaultproperties
{
	MovementInputColor=(R=214,G=38,B=38)
}
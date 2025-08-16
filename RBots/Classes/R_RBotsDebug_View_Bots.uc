//==============================================================================
//	R_RbotsDebug_View_Bots
//	Debug View for RBots Bots
//==============================================================================
class R_RbotsDebug_View_Bots extends R_RbotsDebug_View;

const DebugRBotsCategory = 'DebugTarget';

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

		if(R_RBotsDebug_PathBot(DebugTarget) != None)
		{	// Draw debug PathBot information
			DrawDebugTaret_PathBot(C, StringManager, R_RBotsDebug_PathBot(DebugTarget));
		}
	}
}

simulated function DrawDebugTarget(Canvas C, R_RBotsDebug_StringManager StringManager, R_Bot BotDebugTarget)
{
	StringManager.AddActor(DebugRBotsCategory, "DebugTarget", BotDebugTarget);
}

// Draw debug information specific to PathBots
simulated function DrawDebugTaret_PathBot(Canvas C, R_RBotsDebug_StringManager StringManager, R_RBotsDebug_PathBot PathBotDebugTarget)
{
	StringManager.AddActor(DebugRBotsCategory, "CurrentPathingTarget", PathBotDebugTarget.GetCurrentPathingTarget());
}
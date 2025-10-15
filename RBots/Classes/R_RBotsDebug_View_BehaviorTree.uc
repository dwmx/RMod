//==============================================================================
//	R_RBotsDebug_View_BehaviorTree
//	Debug visualization for Behavior Trees
//==============================================================================
class R_RBotsDebug_View_BehaviorTree extends R_RBotsDebug_View config(RBotsDebug);

const Utilities = Class'RBots.R_BotUtilities';

const StringCategoryBT = 'BehaviorTree';

function DrawDebugView(Canvas C, R_RbotsDebug_StringManager StringManager)
{
	StringManager.AddCategory(StringCategoryBT);
	StringManager.AddWarning(StringCategoryBT, "Waiting on implementation");
}
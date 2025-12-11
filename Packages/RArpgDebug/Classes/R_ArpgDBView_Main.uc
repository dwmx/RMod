class R_ArpgDBView_Main extends RDebugTools.R_DBView;

const DebugCategory = 'RArpg';

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	StringManager.AddWarning(DebugCategory, "Looks like we're in business fellas");
}
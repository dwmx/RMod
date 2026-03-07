//==============================================================================
//	R_ArpgDBView_UI
//	Debug view for UI
//==============================================================================
class R_ArpgDBView_UI extends R_ArpgDBView config(RArpgDebug);

const DebugCategory_UI = 'UI';

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	StringManager.AddWarning(DebugCategory_UI, "UI View is good to go");
}
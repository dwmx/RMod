//==============================================================================
//	R_ArpgDBView_Sessions
//	Draws session related info for the currently selected DebugTarget
//==============================================================================
class R_ArpgDBView_Sessions extends R_ArpgDBView config(RArpgDebug);

const DebugCategory = 'Sessions';

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	local R_ArpgDBMutator DBM;

	DBM = GetArpgDebugMutator();
	if(DBM == None)
	{
		StringManager.AddWarning(DebugCategory, "Failed to get reference to Arpg Debug Mutator");
		return;
	}

	StringManager.AddWarning(DebugCategory, "Session view is good to go!");
}
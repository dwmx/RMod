//==============================================================================
//	R_ArpgDBView_Main
//	Top level debug view class for Arpg debug mutator
//	This generally should always be enabled -- it just shows base level info
//==============================================================================
class R_ArpgDBView_Main extends R_ArpgDBView;

const DebugCategory = 'RArpgDebug';

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	local R_ArpgDBMutator DBM;
	local GameInfo GI;

	DBM = GetArpgDebugMutator();
	if(DBM == None)
	{
		StringManager.AddWarning(DebugCategory, "Failed to get reference to Arpg Debug Mutator");
		return;
	}

	DrawDebugGameInfo(C, StringManager, DBM);
}

simulated function DrawDebugGameInfo(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local GameInfo GI;
	local Class GIClass;

	GI = None;
	GIClass = None;

	if(DBM != None)
	{
		GI = DBM.Level.Game;
		if(GI != None)
		{
			GIClass = GI.Class;
		}
	}

	if(StringManager != None)
	{
		StringManager.AddClass(DebugCategory, "Game Info Class", GIClass);
		StringManager.AddActor(DebugCategory, "Game Info Actor", GI);
	}
}
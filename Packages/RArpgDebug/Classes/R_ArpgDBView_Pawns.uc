//==============================================================================
//	R_ArpgDBView_Pawns
//	Debug view for Arpg Pawns
//==============================================================================
class R_ArpgDBView_Pawns extends R_ArpgDBView config(RArpgDebug);

const DebugCategory = 'Pawns';

simulated function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	local R_ArpgDBMutator DBM;

	DBM = GetArpgDebugMutator();
	if(DBM == None)
	{
		StringManager.AddWarning(DebugCategory, "Failed to get reference to Arpg Debug Mutator");
		return;
	}

	StringManager.AddWarning(DebugCategory, "Pawn view is good to go!");
}
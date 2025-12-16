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

	DrawTopLevelStrings(C, StringManager, DBM);

	DrawDebugTarget(C, StringManager, DBM);
}

simulated function DrawTopLevelStrings(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local GameInfo GI;
	local Class GIClass;
	local Actor DBTarget;

	GI = None;
	GIClass = None;

	if(DBM != None)
	{
		GI = DBM.Level.Game;
		if(GI != None)
		{
			GIClass = GI.Class;
		}

		DBTarget = DBM.GetDebugTarget();
	}

	if(StringManager != None)
	{
		StringManager.AddClass(DebugCategory, "Game Info Class", GIClass);
		StringManager.AddActor(DebugCategory, "Game Info Actor", GI);
		StringManager.AddActor(DebugCategory, "Debug Target", DBTarget);
	}
}

simulated function DrawDebugTarget(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local Actor DebugTarget;

	if(DBM != None)
	{
		DebugTarget = DBM.GetDebugTarget();
		if(DebugTarget == None)
		{
			return;
		}

		CanvasLib.Static.DrawCylinderAxisAligned3D(
			C,
			DebugTarget.Location,
			Vect(0,0,0),
			DebugTarget.CollisionRadius,
			DebugTarget.CollisionHeight * 2.0,
			16,
			1.0, 1.0, 0.0);
	}
}
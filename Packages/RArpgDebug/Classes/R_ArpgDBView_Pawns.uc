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

	DrawAllPawns(C, StringManager, DBM);
}

simulated function DrawAllPawns(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local Pawn P;

	P = DBM.Level.PawnList;
	while(P != None)
	{
		if(R_ArpgPawn(P) != None)
		{
			DrawPawnBoundingBox(C, DBM, R_ArpgPawn(P));
		}

		P = P.NextPawn;
	}
}

simulated function DrawPawnBoundingBox(Canvas C, R_ArpgDBMutator DBM, R_ArpgPawn P)
{
	local Rotator ViewRotation;
	local Vector Extent1, Extent2;

	ViewRotation = DBM.GetDebugViewRotation();
	CanvasLib.Static.GetScreenSpaceBoundingBoxForActor(C, P, ViewRotation, Extent1, Extent2);
	CanvasLib.Static.DrawBoxOutline(C, Extent1, Extent2, 2.0, 1.0, 1.0, 0.0, 1.0);
}
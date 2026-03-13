//==============================================================================
//	R_ArpgDBMutator
//	Debug mutator class for RArpg package
//==============================================================================
class R_ArpgDBMutator extends RDebugTools.R_DBMutator config(RArpgDebug);

// Command managers
const CMClass_Main = Class'RArpgDebug.R_ArpgDBCommands_Main';
const CMNameSpace_Main = 'rarpg';

const CMClass_Sessions = Class'RArpgDebug.R_ArpgDBCommands_Sessions';
const CMNameSpace_Sessions = 'sessions';

const CMClass_Pawns = Class'RArpgDebug.R_ArpgDBCommands_Pawns';
const CMNameSpace_Pawns = 'pawns';

const CMClass_UI = Class'RArpgDebug.R_ArpgDBCommands_UI';
const CMNameSpace_UI = 'ui';

var bool bHumanDebugTargetsOnly;

//------------------------------------------------------------------------------

simulated function SelectNextDebugTarget()
{
	local Pawn PStart, PEnd;
	local Actor LocalDebugTarget;

	LocalDebugTarget = GetDebugTarget();
	PEnd = Pawn(LocalDebugTarget);

	if (PEnd == None)
		PEnd = Level.PawnList;

	if (PEnd == None)
	{
		SetDebugTarget(None);
		return;
	}

	PStart = PEnd;

	while (true)
	{
		PStart = PStart.NextPawn;

		if (PStart == None)
			PStart = Level.PawnList;

		if (R_ArpgPawn(PStart) != None)
		{
			SetDebugTarget(PStart);
			return;
		}

		if (PStart == PEnd)
			break;
	}
}

/*
simulated function SelectNextDebugTarget()
{
	local Pawn P;
	local Actor LocalDebugTarget;
	
	LocalDebugTarget = GetDebugTarget();
	if(LocalDebugTarget != None)
	{
		P = Pawn(LocalDebugTarget);
	}

	if(P == None || P.NextPawn == None)
	{
		P = Level.PawnList;
	}
	else
	{
		P = P.NextPawn;
	}

	// If only viewing humans, select only humans
	if(bHumanDebugTargetsOnly)
	{
		while(P != None && P.NextPawn != None && R_ArpgPlayerController(P) == None)
		{
			P = P.NextPawn;
		}

		if(R_ArpgPlayerController(P) != None)
		{
			P = R_ArpgPlayerController(P).GetControlledPawn();
		}
	}
	else
	{
		while(P != None && P.NextPawn != None && R_ArpgPawn(P) != None)
		{
			P = P.NextPawn;
		}
	}

	SetDebugTarget(P);
}
	*/

simulated function R_DBCommandManager InitializeCommandManagers()
{
	local R_DBCommandManager CM_Main;
	local R_DBCommandManager CM_Sessions;
	local R_DBCommandManager CM_Pawns;
	local R_DBCommandManager CM_UI;

	CM_Main = CreateCommandManager(CMClass_Main, CMNameSpace_Main);
	CM_Sessions = CreateCommandManager(CMClass_Sessions, CMNameSpace_Sessions);
	CM_Pawns = CreateCommandManager(CMClass_Pawns, CMNameSpace_Pawns);
	CM_UI = CreateCommandManager(CMClass_UI, CMNameSpace_UI);

	CM_Main.AddSubCommandManager(CM_Sessions);
	CM_Main.AddSubCommandManager(CM_Pawns);
	CM_Main.AddSubCommandManager(CM_UI);

	return CM_Main;
}

function Rotator GetDebugViewRotation()
{
	local R_ArpgPlayerController PP;

	PP = R_ArpgPlayerController(Owner);
	if(PP != None)
	{
		return PP.SavedCameraRot;
	}

	return Super.GetDebugViewRotation();
}

defaultproperties
{
	DefaultViews(0)=Class'RArpgDebug.R_ArpgDBView_Main'
	DefaultViews(1)=Class'RArpgDebug.R_ArpgDBView_Sessions'
	DefaultViews(2)=Class'RArpgDebug.R_ArpgDBView_Pawns'
	DefaultViews(3)=Class'RArpgDebug.R_ArpgDBView_UI'
	bHumanDebugTargetsOnly=false
}
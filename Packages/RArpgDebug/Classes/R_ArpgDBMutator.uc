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

//------------------------------------------------------------------------------

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

	while(P != None && P.NextPawn != None && R_ArpgRunePlayer(P) == None)
	{
		P = P.NextPawn;
	}

	SetDebugTarget(P);
}

simulated function R_DBCommandManager InitializeCommandManagers()
{
	local R_DBCommandManager CM_Main;
	local R_DBCommandManager CM_Sessions;
	local R_DBCommandManager CM_Pawns;

	CM_Main = CreateCommandManager(CMClass_Main, CMNameSpace_Main);
	CM_Sessions = CreateCommandManager(CMClass_Sessions, CMNameSpace_Sessions);
	CM_Pawns = CreateCommandManager(CMClass_Pawns, CMNameSpace_Pawns);

	CM_Main.AddSubCommandManager(CM_Sessions);
	CM_Main.AddSubCommandManager(CM_Pawns);

	return CM_Main;
}

defaultproperties
{
	DefaultViews(0)=Class'RArpgDebug.R_ArpgDBView_Main'
	DefaultViews(1)=Class'RArpgDebug.R_ArpgDBView_Sessions'
	DefaultViews(2)=Class'RArpgDebug.R_ArpgDBView_Pawns'
}
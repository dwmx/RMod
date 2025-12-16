//==============================================================================
//	R_ArpgDBMutator
//	Debug mutator class for RArpg package
//==============================================================================
class R_ArpgDBMutator extends RDebugTools.R_DBMutator config(RArpgDebug);

// Command managers
const CMClass_Main = Class'RArpgDebug.R_ArpgDBCommandMain';
const CMNameSpace_Main = 'rarpg';

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

	CM_Main = CreateCommandManager(CMClass_Main, CMNameSpace_Main);

	return CM_Main;
}

defaultproperties
{
	DefaultViews=Class'RArpgDebug.R_ArpgDBView_Main'
}
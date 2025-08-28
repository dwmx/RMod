//==============================================================================
//	R_RBotsDebug_CommandManager_NavMesh
//	Debug commands for NavMesh
//==============================================================================
class R_RBotsDebug_CommandManager_NavMesh extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_ToggleNormals = "ToggleNormals";
const Command_ToggleVertices = "ToggleVertices";
const Command_ToggleEdges = "ToggleEdges";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_ToggleNormals);
	RegisterCommand(Command_ToggleVertices);
	RegisterCommand(Command_ToggleEdges);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:				HandleCommand_Show(DebugMutator, Sender);			return true;
		case Command_Hide:				HandleCommand_Hide(DebugMutator, Sender);			return true;
		case Command_Toggle:			HandleCommand_Toggle(DebugMutator, Sender);			return true;
		case Command_ToggleNormals:		HandleCommand_ToggleNormals(DebugMutator, Sender);	return true;
		case Command_ToggleVertices:	HandleCommand_ToggleVertices(DebugMutator, Sender);	return true;
		case Command_ToggleEdges:		HandleCommand_ToggleEdges(DebugMutator, Sender);	return true;
	}

	return false;
}

function R_RBotsDebug_View_NavMesh GetDVNavMesh(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_NavMesh(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_NavMesh'));
}

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_NavMesh');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_NavMesh');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_NavMesh');
	}
}

function HandleCommand_ToggleNormals(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleNormals();
		}
	}
}

function HandleCommand_ToggleVertices(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleVertices();
		}
	}
}

function HandleCommand_ToggleEdges(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleEdges();
		}
	}
}
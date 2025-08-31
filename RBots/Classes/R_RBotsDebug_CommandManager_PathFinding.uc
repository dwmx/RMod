//==============================================================================
//	R_RBotsDebug_CommandManager_PathFinding
//	Debug commands for PathFinding
//==============================================================================
class R_RBotsDebug_CommandManager_PathFinding extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_PathPoints = "Points";
const Command_PathNodes = "Nodes";
const Command_PathPortals = "Portals";
const Command_BoundaryPushDirs = "PushDirs";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_PathPoints);
	RegisterCommand(Command_PathNodes);
	RegisterCommand(Command_PathPortals);
	RegisterCommand(Command_BoundaryPushDirs);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:				HandleCommand_Show(DebugMutator, Sender);			return true;
		case Command_Hide:				HandleCommand_Hide(DebugMutator, Sender);			return true;
		case Command_Toggle:			HandleCommand_Toggle(DebugMutator, Sender);			return true;
		case Command_PathPoints:		HandleCommand_PathPoints(DebugMutator, Sender);		return true;
		case Command_PathNodes:			HandleCommand_PathNodes(DebugMutator, Sender);		return true;
		case Command_PathPortals:		HandleCommand_PathPortals(DebugMutator, Sender);	return true;
		case Command_BoundaryPushDirs:	HandleCommand_BoundaryPushDirs(DebugMutator, Sender);	return true;
	}

	return false;
}

function R_RBotsDebug_View_PathFinding GetDVPathFinding(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_PathFinding(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_PathFinding'));
}

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_PathFinding');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_PathFinding');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_PathFinding');
	}
}

function HandleCommand_PathPoints(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_PathFinding DVPathFinding;

	DVPathFinding = GetDVPathFinding(DebugMutator);
	if(DVPathFinding != None)
	{
		DVPathFinding.TogglePathPoints();
	}
}

function HandleCommand_PathNodes(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_PathFinding DVPathFinding;

	DVPathFinding = GetDVPathFinding(DebugMutator);
	if(DVPathFinding != None)
	{
		DVPathFinding.TogglePathNodes();
	}
}

function HandleCommand_PathPortals(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_PathFinding DVPathFinding;

	DVPathFinding = GetDVPathFinding(DebugMutator);
	if(DVPathFinding != None)
	{
		DVPathFinding.TogglePathPortals();
	}
}

function HandleCommand_BoundaryPushDirs(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_PathFinding DVPathFinding;

	DVPathFinding = GetDVPathFinding(DebugMutator);
	if(DVPathFinding != None)
	{
		DVPathFinding.ToggleBoundaryPushDirs();
	}
}
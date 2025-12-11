//==============================================================================
//	R_RBotsDebug_CommandManager_NavQuery
//	Debug commands for NavQuery systems
//==============================================================================
class R_RBotsDebug_CommandManager_NavQuery extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_DrawBounds = "Bounds";
const Command_DrawCells = "Cells";
const Command_DrawIndexCount = "IndexCount";
const Command_CycleDrawMode = "DrawMode";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_DrawBounds);
	RegisterCommand(Command_DrawCells);
	RegisterCommand(Command_DrawIndexCount);
	RegisterCommand(Command_CycleDrawMode);
}

function bool TryHandleCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:				HandleCommand_Show(DebugMutator, Sender);				return true;
		case Command_Hide:				HandleCommand_Hide(DebugMutator, Sender);				return true;
		case Command_Toggle:			HandleCommand_Toggle(DebugMutator, Sender);				return true;
		case Command_DrawBounds:		HandleCommand_DrawBounds(DebugMutator, Sender);			return true;
		case Command_DrawCells:			HandleCommand_DrawCells(DebugMutator, Sender);			return true;
		case Command_DrawIndexCount:	HandleCommand_DrawIndexCount(DebugMutator, Sender);		return true;
		case Command_CycleDrawMode:		HandleCommand_CycleDrawMode(DebugMutator, Sender);		return true;
	}

	return false;
}

//------------------------------------------------------------------------------

final function R_RBotsDebug_View_NavMeshSpatialQuery GetDVSpatialQuery(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_NavMeshSpatialQuery(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery'));
}

//------------------------------------------------------------------------------

function HandleCommand_Show(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.EnableDebugView(Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery');
	}
}

function HandleCommand_Hide(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.DisableDebugView(Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery');
	}
}

function HandleCommand_Toggle(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	if(DebugMutator != None)
	{
		DebugMutator.ToggleDebugView(Class'RBots.R_RBotsDebug_View_NavMeshSpatialQuery');
	}
}

function HandleCommand_DrawBounds(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMeshSpatialQuery DVSQ;

	DVSQ = GetDVSpatialQuery(DebugMutator);
	if(DVSQ != None)
	{
		DVSQ.ToggleDrawBounds();
	}
}

function HandleCommand_DrawCells(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMeshSpatialQuery DVSQ;

	DVSQ = GetDVSpatialQuery(DebugMutator);
	if(DVSQ != None)
	{
		DVSQ.ToggleDrawCells();
	}
}

function HandleCommand_DrawIndexCount(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMeshSpatialQuery DVSQ;

	DVSQ = GetDVSpatialQuery(DebugMutator);
	if(DVSQ != None)
	{
		DVSQ.ToggleDrawCellIndexCount();
	}
}

function HandleCommand_CycleDrawMode(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMeshSpatialQuery DVSQ;

	DVSQ = GetDVSpatialQuery(DebugMutator);
	if(DVSQ != None)
	{
		DVSQ.CycleTestDrawMode();
	}
}
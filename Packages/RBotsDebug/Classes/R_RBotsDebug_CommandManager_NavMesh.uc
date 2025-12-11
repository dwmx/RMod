//==============================================================================
//	R_RBotsDebug_CommandManager_NavMesh
//	Debug commands for NavMesh
//==============================================================================
class R_RBotsDebug_CommandManager_NavMesh extends R_RBotsDebug_CommandManager;

const Command_Show = "Show";
const Command_Hide = "Hide";
const Command_Toggle = "Toggle";
const Command_ToggleNormals = "Normals";
const Command_ToggleVertices = "Vertices";
const Command_ToggleEdges = "Edges";
const Command_ToggleEdgeOrientations = "EdgeOrientations";
const Command_ToggleTriangles = "Triangles";
const Command_ToggleNeighbors = "Neighbors";
const Command_ToggleCosts = "Costs";
const Command_ToggleAdjacents = "Adjacents";
const Command_ToggleProximity = "Proximity";
const Command_TogglePlayerBorders = "PlayerBorders";
const Command_TogglePolyGroups = "PolyGroups";
const Command_TogglePortals = "Portals";

function RegisterCommandList()
{
	RegisterCommand(Command_Show);
	RegisterCommand(Command_Hide);
	RegisterCommand(Command_Toggle);
	RegisterCommand(Command_ToggleNormals);
	RegisterCommand(Command_ToggleVertices);
	RegisterCommand(Command_ToggleEdges);
	RegisterCommand(Command_ToggleEdgeOrientations);
	RegisterCommand(Command_ToggleTriangles);
	RegisterCommand(Command_ToggleNeighbors);
	RegisterCommand(Command_ToggleCosts);
	RegisterCommand(Command_ToggleAdjacents);
	RegisterCommand(Command_ToggleProximity);
	RegisterCommand(Command_TogglePlayerBorders);
	RegisterCommand(Command_TogglePolyGroups);
	RegisterCommand(Command_TogglePortals);
}

function bool TryHandleRBotsCommand(String CommandString, R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	switch(CommandString)
	{
		case Command_Show:						HandleCommand_Show(DebugMutator, Sender);					return true;
		case Command_Hide:						HandleCommand_Hide(DebugMutator, Sender);					return true;
		case Command_Toggle:					HandleCommand_Toggle(DebugMutator, Sender);					return true;
		case Command_ToggleNormals:				HandleCommand_ToggleNormals(DebugMutator, Sender);			return true;
		case Command_ToggleVertices:			HandleCommand_ToggleVertices(DebugMutator, Sender);			return true;
		case Command_ToggleEdges:				HandleCommand_ToggleEdges(DebugMutator, Sender);			return true;
		case Command_ToggleEdgeOrientations:	HandleCommand_ToggleEdgeOrientations(DebugMutator, Sender);	return true;
		case Command_ToggleTriangles:			HandleCommand_ToggleTriangles(DebugMutator, Sender);		return true;
		case Command_ToggleNeighbors:			HandleCommand_ToggleNeighbors(DebugMutator, Sender);		return true;
		case Command_ToggleCosts:				HandleCommand_ToggleCosts(DebugMutator, Sender);			return true;
		case Command_ToggleAdjacents:			HandleCommand_ToggleAdjacents(DebugMutator, Sender);		return true;
		case Command_ToggleProximity:			HandleCommand_ToggleProximity(DebugMutator, Sender);		return true;
		case Command_TogglePlayerBorders:		HandleCommand_TogglePlayerBorders(DebugMutator, Sender);	return true;
		case Command_TogglePolyGroups:			HandleCommand_TogglePolyGroups(DebugMutator, Sender);		return true;
		case Command_TogglePortals:				HandleCommand_TogglePortals(DebugMutator, Sender);			return true;
	}

	return false;
}

//------------------------------------------------------------------------------

final function R_RBotsDebug_View_NavMesh GetDVNavMesh(R_RBotsDebug DebugMutator)
{
	if(DebugMutator == None)
	{
		return None;
	}

	return R_RBotsDebug_View_NavMesh(DebugMutator.GetDebugView(Class'RBots.R_RBotsDebug_View_NavMesh'));
}

//------------------------------------------------------------------------------

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

function HandleCommand_ToggleEdgeOrientations(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleEdgeOrientations();
		}
	}
}

function HandleCommand_ToggleTriangles(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleTriangles();
		}
	}
}

function HandleCommand_ToggleNeighbors(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleNeighbors();
		}
	}
}

function HandleCommand_ToggleCosts(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleCosts();
		}
	}
}

function HandleCommand_ToggleAdjacents(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleAdjacents();
		}
	}
}

function HandleCommand_ToggleProximity(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.ToggleProximity();
		}
	}
}

function HandleCommand_TogglePlayerBorders(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.TogglePlayerBorders();
		}
	} 
}

function HandleCommand_TogglePolyGroups(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.TogglePolyGroupInfo();
		}
	} 
}

function HandleCommand_TogglePortals(R_RBotsDebug DebugMutator, PlayerPawn Sender)
{
	local R_RBotsDebug_View_NavMesh DVNavMesh;

	if(DebugMutator != None)
	{
		DVNavMesh = GetDVNavMesh(DebugMutator);
		if(DVNavMesh != None)
		{
			DVNavMesh.TogglePortals();
		}
	} 
}
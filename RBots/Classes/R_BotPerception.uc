//==============================================================================
//	R_BotPerception
//	Bot sub-object which perceives other Actors in the level
//==============================================================================
class R_BotPerception extends R_BotObject;

const LogCategory = 'BotPerception';

const NavLib = Class'RBots.R_NavLibrary';

var private Actor PerceivedActor;

var private int BorderEdgeIndices[32];
var private float BorderEdgeDistances[32];
var private int NumBorderEdges;

const BorderAvoidanceMaxDist = 32.0;
const BorderAvoidanceMinDist = 4.0;

function SetPerceivedActor(Actor NewPerceivedActor)
{
	PerceivedActor = NewPerceivedActor;
}

function Actor GetPerceivedActor()
{
	return PerceivedActor;
}

function TickBotObject(float DeltaSeconds)
{
	local PlayerPawn PP, PPIterator;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		PerceivedActor = None;
		return;
	}

	foreach PP.AllActors(Class'Engine.PlayerPawn', PPIterator)
	{
		if(PPIterator == PP)
		{
			continue;
		}
		else
		{
			SetPerceivedActor(PPIterator);
			break;
		}
	}

	UpdateBorderEdges();
}

function UpdateBorderEdges()
{
	local R_Bot Bot;
	local R_NavMesh NavMesh;
	local PlayerPawn PP;
	local Vector Location;

	NavMesh = None;
	Bot = GetBot();
	if(Bot != None)
	{
		NavMesh = Bot.GetNavMesh();
		PP = Bot.GetOwnedPlayerPawn();
	}
	if(NavMesh == None || PP == None)
	{
		NumBorderEdges = 0;
		return;
	}

	Location = PP.Location;
	NavMesh.FindRelevantBorderEdgesInRadius2D(Location, BorderAvoidanceMaxDist, BorderEdgeIndices, BorderEdgeDistances, NumBorderEdges);
}

function Vector GetBorderAvoidanceDir(optional out float OutInfluence)
{
	local R_Bot Bot;
	local R_NavMesh NavMesh;
	local PlayerPawn PP;
	local Vector Location;
	local Vector Result;

	Bot = GetBot();
	if(Bot != None)
	{
		NavMesh = Bot.GetNavMesh();
		PP = Bot.GetOwnedPlayerPawn();
	}
	if(NavMesh == None || PP == None)
	{
		return Vect(0,0,0);
	}

	Location = PP.Location;
	Result = NavLib.Static.CalcBorderAvoidanceDirection(
		NavMesh,
		BorderEdgeIndices,
		BorderEdgeDistances,
		NumBorderEdges,
		Location,
		BorderAvoidanceMinDist, BorderAvoidanceMaxDist,
		OutInfluence);
	
	return Result;
}
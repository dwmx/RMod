//==============================================================================
//	R_BotBehavior_Wander
//	Wander around, aimlessly
//==============================================================================
class R_BotBehavior_Wander extends R_BotBehavior;

var private Vector WanderDirection;

struct R_RecentlyVisitedNode
{
	var int NodeIndex;
	var float TimeStampSeconds;
};
var private R_RecentlyVisitedNode RecentlyVisitedNodes[32];
var private int RecentlyVisitedNodeIndex;

function BehaviorActivated()
{
	local PlayerPawn PP;
	local PlayerReplicationInfo PRI;

	WanderDirection = Vect(1,0,0) * FRand() + Vect(0,1,0) * FRand();
	WanderDirection.Z = 0.0;
	WanderDirection = Normal(WanderDirection);
}

function InitRecentlyVisitedNodes()
{
	local int i;

	for(i = 0; i < ArrayCount(RecentlyVisitedNodes); ++i)
	{
		RecentlyVisitedNodes[i].NodeIndex = NavLib.Static.InvalidIndex();
		RecentlyVisitedNodes[i].TimeStampSeconds = 0.0;
	}
}

function String GetDescriptiveString()
{
	return "Wander";
}

function BehaviorTick(float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BotPawnController Controller;
	local R_NavMesh NavMesh;
	local PlayerPawn PP;
	local Vector Location;
	local int NewNodeIndex;

	local R_BotPerception BotPerception;
	local Vector AvoidanceDir;
	local float AvoidanceInfluence;

	Bot = GetBot();
	if(Bot == None)	return;

	Controller = GetBotPawnController();
	if(Controller == None)	return;

	NavMesh = Bot.GetNavMesh();
	if(NavMesh == None)	return;

	PP = Bot.GetOwnedPlayerPawn();
	if(PP == None)	return;


	if(Bot != None)
	{
		BotPerception = R_BotPerception(Bot.GetBotObjectByClass(Class'RBots.R_BotPerception'));
		if(BotPerception != None)
		{
			AvoidanceDir = BotPerception.GetBorderAvoidanceDir(AvoidanceInfluence);
			WanderDirection = AdjustWanderForAvoidance(WanderDirection, AvoidanceDir, AvoidanceInfluence);
		}
		//Bot.AddMovementInput(Vect(1,0,0) * Cos(Bot.Level.TimeSeconds) + Vect(0,1,0) * Sin(Bot.Level.TimeSeconds));
		//Bot.AddMovementInput(WanderDirection);
		Controller.AddMovementInput_WorldSpace(WanderDirection);
	}

	if(PP.Physics == PHYS_Walking)
	{
		PP.DodgeDir = PP.eDodgeDir.DODGE_Forward;
		PP.aBaseX += 300.0;
	}
}

function Vector AdjustWanderForAvoidance(Vector WanderDir, Vector AvoidanceDir, float Influence)
{
	local Vector ClippedWanderDir;
	local Vector Result;

	ClippedWanderDir = WanderDir - (AvoidanceDir * (AvoidanceDir Dot WanderDir));

	Result.X = Lerp(Influence, ClippedWanderDir.X, AvoidanceDir.X);
	Result.Y = Lerp(Influence, ClippedWanderDir.Y, AvoidanceDir.Y);
	Result.Z = 0.0;

	return Normal(Result);
}

function OnNavMeshNodeIndexChanged(int OldNavMeshNodeIndex, int NewNavMeshNodeIndex)
{
	local R_Bot Bot;
	local R_NavMesh NavMesh;
	local R_NavNeighborSet NeighborSet;
	local PlayerPawn PP;
	local float BestScore, CurrentScore;
	local int BestNode;
	local Vector VLoc[3], Center;
	local int i;

	Bot = GetBot();
	if(Bot == None)
		return;

	RecentlyVisitedNodeIndex = (RecentlyVisitedNodeIndex + 1) % ArrayCount(RecentlyVisitedNodes);
	RecentlyVisitedNodes[RecentlyVisitedNodeIndex].NodeIndex = NewNavMeshNodeIndex;
	RecentlyVisitedNodes[RecentlyVisitedNodeIndex].TimeStampSeconds = Bot.Level.TimeSeconds;

	NavMesh = Bot.GetNavMesh();
	if(NavMesh == None)
		return;
	
	// Find a new neighbor to travel towards
	BestScore = 0.0;
	BestNode = NavLib.Static.InvalidIndex();
	NavMesh.GetTriangleNeighborSetUnchecked(NewNavMeshNodeIndex, NeighborSet);
	for(i = 0; i < NeighborSet.NumNeighbors; ++i)
	{
		if(NeighborSet.Neighbors[i].NeighborType != NeighborType_Adjacent)
			continue;
		
		CurrentScore = ScoreNode(NavMesh, NeighborSet.Neighbors[i].NeighborIndex);
		if(CurrentScore > BestScore
		|| (CurrentScore == BestScore && FRand() > 0.5)) // If all neighbors score the same, take a random one
		{
			BestScore = CurrentScore;
			BestNode = NeighborSet.Neighbors[i].NeighborIndex;
		}
	}

	if(BestNode != NavLib.Static.InvalidIndex())
	{
		NavMesh.GetTriangleVertexLocationsUnchecked(BestNode, VLoc);
		Center = (VLoc[0] + VLoc[1] + VLoc[2]) * (1.0/3.0);
		PP = Bot.GetOwnedPlayerPawn();
		if(PP != None)
		{
			WanderDirection = Vect(1,1,0) * (Center - PP.Location);
		}
	}
}

function float ScoreNode(R_NavMesh NavMesh, int NodeIndex)
{
	local R_Bot Bot;
	local float TimeScore;
	local float TimeDelta;
	local float t;
	local int i;

	TimeScore = 1.0; // Perfect time score
	Bot = GetBot();
	for(i = 0; i < ArrayCount(RecentlyVisitedNodes); ++i)
	{
		if(RecentlyVisitedNodes[i].NodeIndex == NodeIndex)
		{
			TimeDelta = Bot.Level.TimeSeconds - RecentlyVisitedNodes[i].TimeStampSeconds;
			TimeDelta = FClamp(TimeDelta, 0.0, 15.0);
			t = TimeDelta / 15.0;
			TimeScore = Lerp(t, 0.0, 1.0);
		}
	}

	return TimeScore;
}

defaultproperties
{
	RecentlyVisitedNodeIndex=0
}
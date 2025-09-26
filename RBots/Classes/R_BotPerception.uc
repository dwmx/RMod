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

// Values returned from GetPerceivedActorCombatState
const CombatState_None = 0;
const CombatState_Idle = 1;
const CombatState_Attacking = 2;
const CombatState_Defending = 3;
const CombatState_VulnerableMoving = 4;
const CombatState_VulnerableStationary = 5;

enum R_CombatState
{
	CombatState_Idle,
	CombatState_Vulnerable,
	CombstState_Attacking
};

function SetPerceivedActor(Actor NewPerceivedActor)
{
	PerceivedActor = NewPerceivedActor;
}

function Actor GetPerceivedActor()
{
	return PerceivedActor;
}

function int GetPerceivedActorCombatState()
{
	local Pawn P;
	local AnimationProxy AP;

	P = Pawn(PerceivedActor);
	if(P == None)
	{
		return CombatState_None;
	}

	AP = P.AnimProxy;
	if(AP == None)
	{
		return CombatState_None;
	}

	switch(AP.GetStateName())
	{
	case 'Idle':		return CombatState_Idle;
	case 'Defending':	return CombatState_Defending;

	case 'Switching':
	case 'Throwing':
	case 'Pain':
		return CombatState_VulnerableMoving;
	
	case 'Uninterrupted':
	case 'PickingUp':
		return CombatState_VulnerableStationary;
	}

	if(AP.GetStateName() == 'Attacking')
	{	// Attacking needs special handling, since recovery and attacking happens
		// in the same state -- AP needs to be attacking AND weapon needs to be swinging
		if(P.Weapon != None && P.Weapon.GetStateName() == 'Swinging')
		{
			return CombatState_Attacking;
		}
		else
		{
			return CombatState_VulnerableMoving;
		}
	}

	return CombatState_None;
}

function float CalcEngagementScore_Distance(Pawn P)
{
	local PlayerPawn BotPawn;
	local Vector LocationDelta;
	local float t;
	local float Result;

	BotPawn = GetPlayerPawn();
	if(P != None && BotPawn != None)
	{
		LocationDelta = P.Location - BotPawn.Location;
		t = Utilities.Static.RemapFloatToRange(VSize(LocationDelta), 64.0, 1024.0, 1.0, 0.0);
		return t;
	}
	return 0.0;
}

// Returns the desire to engage with perceived actor, [0.0,1.0]
// where 0.0 = no desire, 1.0 = max desire
function float GetPerceivedActorEngagementScore()
{
	local PlayerPawn PP;
	local PlayerPawn BotPawn;
	local AnimationProxy AP;
	local int CombatState;
	local float CombatScore, CombatWeight;
	local float WeaponScore, WeaponWeight;
	local float DistanceScore, DistanceWeight;
	local float WeightNorm;
	local float AnimFrame;
	local float t, u;
	local Vector Delta;
	local float Result;

	if(PerceivedActor == None)
	{
		return 0.0;
	}

	PP = PlayerPawn(PerceivedActor);
	if(PP == None)
	{
		return 0.0;
	}

	AP = PP.AnimProxy;

	CombatState = GetPerceivedActorCombatState();
	CombatScore = 0.0;
	switch(CombatState)
	{
	case CombatState_Defending:				CombatScore = 0.25;	break;
	case CombatState_VulnerableMoving:		CombatScore = 0.75;	break;
	case CombatState_VulnerableStationary:	CombatScore = 1.0;	break;
	}

	// If attacking, fall off over time
	if(CombatState == CombatState_Attacking)
	{
		CombatScore = 0.5;

		if(AP != None)
		{
			AnimFrame = FClamp(AP.AnimFrame, 0.0, AP.AnimLast);
			t = AnimFrame / AP.AnimLast;
			u = 1.0 - t;
			CombatScore = (u/3);
		}
	}
	else if(CombatState == CombatState_Idle)
	{	// Idle is generally dangerous, unless they have no weapon at all
		CombatScore = 0.5;
		if(PP.Inventory == None)
		{
			CombatScore = 0.8;
		}
	}

	// Determine weapon score based on target's weapon
	if(PP.Weapon == None)
	{
		WeaponScore = 1.0;
	}
	else
	{
		// Use weapon tier for now
		WeaponScore = 1.0 - (float(Clamp(PP.Weapon.Rating + 1, 0, 5)) / 5.0);
	}

	//// Distance score
	//BotPawn = GetPlayerPawn();
	//DistanceScore = 0.0;
	//if(BotPawn != None)
	//{
	//	Delta = PP.Location - BotPawn.Location;
	//	DistanceScore = 1.0 - FClamp(VSize(Delta) / 768.0, 0.0, 1.0);
	//}
	DistanceScore = CalcEngagementScore_Distance(PP);
	if(DistanceScore <= 0.0)
	{
		return 0.0;
	}

	WeaponWeight = 1.0;
	CombatWeight = 1.6;
	DistanceWeight = 3.0;
	WeightNorm = (WeaponWeight + CombatWeight + DistanceWeight);

	WeaponWeight /= WeightNorm;
	CombatWeight /= WeightNorm;
	DistanceWeight /= WeightNorm;

	Result = WeaponScore * WeaponWeight + CombatScore * CombatWeight + DistanceScore * DistanceWeight;

	return FClamp(Result, 0.0, 1.0);
}

function bool IsValidPerceptionTarget(Actor A)
{
	local PlayerPawn PP;
	local Name StateName;

	PP = PlayerPawn(A);
	if(PP != None)
	{
		StateName = PP.GetStateName();
		if(StateName == 'Dying' || StateName == 'PlayerSpectating')
		{
			return false;
		}
		return true;
	}

	return false;
}

function TickBotObject(float DeltaSeconds)
{
	local PlayerPawn PP, PPIterator;
	local PlayerReplicationInfo PRI, TargetPRI;
	local bool bTeamGame;
	local byte BotTeamID;
	local PlayerPawn PPBest;
	local float BestScore, CurrentScore;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		PerceivedActor = None;
		return;
	}

	bTeamGame = false;
	PRI = PP.PlayerReplicationInfo;
	if(PRI != None)
	{
		if(PP.Level != None && PP.Level.Game != None)
		{
			bTeamGame = PP.Level.Game.bTeamGame;
			BotTeamID = PRI.Team;
		}
	}

	SetPerceivedActor(None);
	BestScore = 0.0;
	PPBest = None;
	foreach PP.AllActors(Class'Engine.PlayerPawn', PPIterator)
	{
		if(PPIterator == PP)
		{
			continue;
		}
		else if(IsValidPerceptionTarget(PPIterator))
		{
			// Ignore teammates if it's a team game
			if(bTeamGame)
			{
				TargetPRI = PPIterator.PlayerReplicationInfo;
				if(TargetPRI != None && TargetPRI.Team == BotTeamID)
				{
					continue;
				}
			}

			// Score just based on distance
			CurrentScore = Utilities.Static.RemapFloatToRange(VSize(PPIterator.Location - PP.Location), 32.0, 1024.0, 1.0, 0.0);
			if(CurrentScore > BestScore)
			{
				BestScore = CurrentScore;
				PPBest = PPIterator;
			}
		}
	}
	SetPerceivedActor(PPBest);

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
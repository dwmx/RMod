//==============================================================================
//	R_Bot
//	The brains and controller for bots
//==============================================================================
class R_Bot extends Actor;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'Bot';

const NavLib = Class'RBots.R_NavLibrary';

var private bool bBotInitialized;

var private R_RBotsServerActor RBots;

// Index caches to remember recently visited polygroups and nodes
const IndexCacheClass = Class'RBots.R_IndexCache_Circular';
var private R_IndexCache RecentlyVisitedNodes;
var private R_IndexCache RecentlyVisitedPolyGroups;

//------------------------------------------------------------------------------
//	Bot Objects
var private R_BotObject BotObjects[16];

// Perception
const BotObjectClass_Perception = Class'RBots.R_BotPerception';
var private R_BotPerception Perception;

// PawnController
const BotObjectClass_PawnController = Class'RBots.R_BotPawnController';
var private R_BotPawnController PawnController;

// BlackBoard
const BotObjectClass_BlackBoard = Class'RBots.R_BlackBoard_Implementation';
const BotObjectClass_BlackBoardReadInterface = Class'RBots.R_BlackBoardReadInterface';
const BotObjectClass_BlackBoardWriteInterface = Class'RBots.R_BlackBoardWriteInterface';
var private R_BlackBoard BlackBoard;
var private R_BlackBoardReadInterface BlackBoardReadInterface;
var private R_BlackBoardWriteInterface BlackBoardWriteInterface;

// BlackBoard Keys
const BBKey_InventoryTarget 	= 'InventoryTarget';	// Actor
const BBKey_WantWeapon 			= 'WantWeapon';			// Float
const BBKey_WantShield			= 'WantShield';			// Float
const BBKey_WantHealth			= 'WantHealth';			// Float
const BBKey_WantStrength		= 'WantStrength';		// Float
const BBKey_WantRunePower		= 'WantRunePower';		// Float

//------------------------------------------------------------------------------
// Behaviors
var private Class<R_BotBehavior> InitialBehaviorClass;
var private R_BotBehavior ActiveBehavior;

const Behavior_Fight = Class'RBots.R_BotBehavior_Fight';
const Behavior_FindWeapon = Class'RBots.R_BotBehavior_FindWeapon';
const Behavior_Wander = Class'RBots.R_BotBehavior_Wander';
const Behavior_Avoid = Class'RBots.R_BotBehavior_Avoid';

//------------------------------------------------------------------------------
// Player
var private PlayerPawn OwnedPlayerPawn;
var private Name OwnedPlayerPawnStateName; // Need this to respond to state changes (respawns)
var private PlayerReplicationInfo OwnedPRI;

// Navigation
var private R_NavQueryInterface CachedNavQueryInterface;
var private R_NavMesh CachedNavMesh;
var private R_NavContext NavContext;
var private R_NavContextObserver AttachedNavContextObserver;
const PATH_DISTANCE_TOLERANCE = 16.0;

// Control
var private Vector AccumulatedInputVector;
var private Vector LastInputVector;

function R_IndexCache GetRecentlyVisitedNodes()	{ return RecentlyVisitedNodes; }
function R_IndexCache GetRecentlyVisitedPolyGroups() { return RecentlyVisitedPolyGroups; }

event BeginPlay()
{
	bBotInitialized = false;
}

function R_RBotsServerActor GetRBotsServerActor()
{
	local R_RBotsServerActor LocalRBots;

	if(RBots == None)
	{
		foreach AllActors(Class'RBots.R_RBotsServerActor', LocalRBots)
		{
			break;
		}
		if(LocalRBots != None)
		{
			RBots = LocalRBots;
		}
	}
	return RBots;
}

function R_NavQueryInterface GetNavQueryInterface()
{
	local R_RBotsServerActor LocalRBots;

	if(CachedNavQueryInterface == None)
	{
		LocalRBots = GetRBotsServerActor();
		if(LocalRBots != None)
		{
			CachedNavQueryInterface = LocalRBots.GetNavQueryInterface();
		}
	}
	return CachedNavQueryInterface;
}

function R_NavMesh GetNavMesh()
{
	local R_DynamicMapData MapData;

	if(CachedNavMesh == None)
	{
		foreach AllActors(Class'RBots.R_DynamicMapData', MapData)
		{
			CachedNavMesh = MapData.GetNavMesh();
			break;
		}
	}
	
	return CachedNavMesh;
}

function R_NavContext GetNavContext()
{
	return NavContext;
}

function R_BlackBoard GetBlackBoard()
{
	return R_BlackBoard(GetBotObjectByClass(Class'RBots.R_BlackBoard'));
}

// Attaches NavContextObserver object to collect additional data from FindPath
function AttachNavContextObserver(R_NavContextObserver NewNavContextObserver)
{
	DetachNavContextObserver();
	AttachedNavContextObserver = NewNavContextObserver;
}

// Detaches, but does not destroy, current NavContextObserver object
function DetachNavContextObserver()
{
	if(AttachedNavContextObserver != None)
	{
		AttachedNavContextObserver = None;
	}
}

// Get the currently attached NavContextObserver, or None
function R_NavContextObserver GetNavContextObserver()
{
	return AttachedNavContextObserver;
}

// Attempts to find a path between Start and End, and if successful, updates the Bot's path vars
// Returns true if path was found and updated
function bool TryUpdatePath(Vector Start, Vector End)
{
	local R_NavQueryInterface NavQuery;

	NavQuery = GetNavQueryInterface();
	if(NavQuery != None)
	{
		return NavQuery.FindPath(Start, End, NavContext, AttachedNavContextObserver);
	}

	return false;
}

// Clears this Bot's current path
function ClearPath()
{
	NavContext.ClearPath();
}

// Called by RBots when granted a PlayerPawn
function PossessedPlayerPawn(PlayerPawn NewPlayerPawn)
{
	local PlayerReplicationInfo PRI;

	if(NewPlayerPawn == None)
	{
		Utilities.Static.RLog("Attempted to possess bad pawn:" @ NewPlayerPawn, LogCategory);
		return;
	}
	
	OwnedPlayerPawn = NewPlayerPawn;
	OwnedPlayerPawn.GotoState('PlayerWalking');
	Utilities.Static.RLog("Possessed player pawn" @ NewPlayerPawn, LogCategory);

	if(OwnedPlayerPawn.PlayerReplicationInfo != None)
	{
		OwnedPRI = OwnedPlayerPawn.PlayerReplicationInfo;
	}
	else
	{
		Utilities.Static.RLog("Failed to acquire reference to PRI", LogCategory);
	}

	//InitPlayerReplicationInfo(OwnedPRI);
}

function InitPlayerReplicationInfo(PlayerReplicationInfo NewPRI)
{
	NewPRI.PlayerName = "IAmABot";
}

function InitializeBot()
{
	local Actor TestActor;
	if(bBotInitialized)
	{
		return;
	}
	bBotInitialized = true;
	
	Utilities.Static.RLog("Initializing bot" @ Self, LogCategory);

	//--------------------------------------------------------------------------
	// Create BotObjects
	Perception 					= R_BotPerception(CreateBotObject(BotObjectClass_Perception));
	PawnController 				= R_BotPawnController(CreateBotObject(BotObjectClass_PawnController));
	BlackBoard 					= R_BlackBoard(CreateBotObject(BotObjectClass_BlackBoard));
	BlackBoardReadInterface 	= R_BlackBoardReadInterface(CreateBotObject(BotObjectClass_BlackBoardReadInterface));
	BlackBoardWriteInterface	= R_BlackBoardWriteInterface(CreateBotObject(BotObjectClass_BlackBoardWriteInterface));

	// BlackBoard Keys
	BlackBoard.AddActor(BBKey_InventoryTarget);
	BlackBoard.AddFloat(BBKey_WantWeapon);
	BlackBoard.AddFloat(BBKey_WantShield);
	BlackBoard.AddFloat(BBKey_WantHealth);
	BlackBoard.AddFloat(BBKey_WantStrength);
	BlackBoard.AddFloat(BBKey_WantRunePower);

	// BlackBoard Read/Write Interface
	BlackBoardReadInterface.SetBlackBoard(BlackBoard);
	BlackBoardWriteInterface.SetBlackBoard(BlackBoard);

	//--------------------------------------------------------------------------
	// Spawn NavContext
	if(NavContext == None)
	{
		NavContext = new(None) Class'RBots.R_NavContext';
		NavContext.InitializeNavContext();
	}

	// Create index caches for tracking navigation
	RecentlyVisitedNodes = new(None) IndexCacheClass;
	RecentlyVisitedNodes.InitIndexCache();

	RecentlyVisitedPolyGroups = new(None) IndexCacheClass;
	RecentlyVisitedPolyGroups.InitIndexCache();

	if(InitialBehaviorClass != None)
	{
		SetBehavior(InitialBehaviorClass);
	}
}

function PlayerPawn GetOwnedPlayerPawn()
{
	return OwnedPlayerPawn;
}

function PlayerReplicationInfo GetOwnedPRI()
{
	return OwnedPRI;
}

function R_BotBehavior GetActiveBehavior()
{
	return ActiveBehavior;
}

//	CreateBotObject
//	Main function for creating, initializating, and auto-managing bot subobjects
function R_BotObject CreateBotObject(Class<R_BotObject> BotObjectClass)
{
	local int i;

	if(BotObjectClass == None)
	{
		Utilities.Static.RLog("CreateBotObject failed -- BotObjectClass:" @ BotObjectClass, LogCategory);
		return None;
	}

	Utilities.Static.RLog("Creating BotObject from class" @ BotObjectClass, LogCategory);

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] == None)
		{
			break;
		}
	}

	if(i >= ArrayCount(BotObjects))
	{
		Utilities.Static.RLog("CreateBotObject failed -- BotObjects array overflow", LogCategory);
		return None;
	}

	BotObjects[i] = new(Self) BotObjectClass;
	if(BotObjects[i] == None)
	{
		Utilities.Static.RLog("CreateBotObject failed -- Failed to instantiate from BotObjectClass:" @ BotObjectClass, LogCategory);
		return None;
	}

	BotObjects[i].BaseInitBotObject(Self);
	return BotObjects[i];
}

function R_BotObject GetBotObjectByClass(Class<R_BotObject> BotObjectClass)
{
	local int i;

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] != None && BotObjects[i].Class == BotObjectClass)
		{
			return BotObjects[i];
		}
	}

	return None;
}

function SetBehavior(Class<R_BotBehavior> BehaviorClass)
{
	if(ActiveBehavior != None)
	{
		ActiveBehavior.BehaviorTerminated();
	}

	if(BehaviorClass != None)
	{
		ActiveBehavior = new(None) BehaviorClass;
		if(ActiveBehavior == None)
		{
			Utilities.Static.RLog("Failed to instantiate new active behavior from class" @ BehaviorClass, LogCategory);
		}
		else
		{
			ActiveBehavior.InitializeBehavior(Self, OwnedPlayerPawn);
			ActiveBehavior.BehaviorActivated();
		}
	}
}

function Class<R_BotBehavior> DetermineDesiredBehavior()
{
	local PlayerPawn P;
	local R_BotPerception Perception;
	local Actor TargetActor;
	local bool bWillingToFight;
	local R_BlackBoard BlackBoard;

	return Class'RBots.R_BotBehavior_Main';

	P = GetOwnedPlayerPawn();
	if(P == None)
	{
		return None;
	}

	bWillingToFight = false;
	if(P.Weapon != None && P.Weapon.Rating > 0)
	{
		bWillingToFight = true;
	}

	// If target is in range, fight or avoid
	Perception = R_BotPerception(GetBotObjectByClass(Class'RBots.R_BotPerception'));
	if(Perception != None)
	{
		TargetActor = Perception.GetPerceivedActor();
		if(TargetActor != None)
		{
			if(VSize(TargetActor.Location - P.Location) <= 256.0)
			{
				if(bWillingToFight)
				{	// Engage target
					return Behavior_Fight;
				}
				else
				{	// Don't want to fight, avoid target
					return Behavior_Avoid;
				}
			}
		}
	}

	// If not happy with weapon, find a weapon
	if(P.Weapon == None || P.Weapon.Rating == 0)
	{
		return Behavior_FindWeapon;
	}

	// By default just wander around until something interesting happens
	return Behavior_Wander;
}

event Tick(float DeltaSeconds)
{
	local Class<R_BotBehavior> DesiredBehavior;
	local Name NewStateName;

	Super.Tick(DeltaSeconds);

	if(OwnedPlayerPawn != None)
	{
		// Spawn fire to respawn, for now
		if(OwnedPlayerPawn.Health <= 0)
		{
			ClearPath();
			OwnedPlayerPawn.Fire();
		}
	}

	// Check for state changes
	if(OwnedPlayerPawn != None)
	{
		NewStateName = OwnedPlayerPawn.GetStateName();
		if(OwnedPlayerPawnStateName != NewStateName)
		{
			if(NewStateName == 'Dying')
			{
				OnOwnedPlayerPawnDied();
			}
			else if(OwnedPlayerPawnStateName == 'Dying')
			{
				OnOwnedPlayerPawnRespawned();
			}
			OwnedPlayerPawnStateName = NewStateName;
		}
	}

	// Update navigation context
	UpdateNavContext(DeltaSeconds);

	// Tick BotObjects
	TickBotObjects(DeltaSeconds);

	//// Update desired inventories
	//UpdateInventoryTarget(DeltaSeconds);

	// Tick Behavior
	DesiredBehavior = DetermineDesiredBehavior();
	if(DesiredBehavior != ActiveBehavior.Class)
	{
		SetBehavior(DesiredBehavior);
	}

	if(ActiveBehavior != None)
	{
		ActiveBehavior.BehaviorTick(DeltaSeconds);
	}

	TickMovement(DeltaSeconds);
}

function UpdateInventoryTarget(float DeltaSeconds)
{
	local R_RBotsServerActor LocalRBots;
	local R_DynamicMapData MapData;
	local R_NavMeshActorTracker ActorTracker;
	local Inventory Inv;
	local PlayerPawn PP;
	local int BestOwnedWeaponRating;
	local float HealthWeight, WeaponWeight, RuneWeight;
	local Actor PolyGroupActors[32];
	local int NumPolyGroupActors;
	local int i;
	local float CurrentScore, BestScore;
	local Inventory BestInventory;
	local R_BlackBoard BlackBoard;

	if(NavContext == None)
	{
		return;
	}

	PP = GetOwnedPlayerPawn();
	if(PP == None)
	{
		return;
	}

	ActorTracker = None;
	LocalRBots = GetRBotsServerActor();
	if(LocalRBots != None)
	{
		MapData = LocalRBots.GetLoadedMapData();
		if(MapData != None)
		{
			ActorTracker = MapData.GetNavMeshActorTracker();
		}
	}

	if(ActorTracker == None)
	{	// For now, only find inventory targets from the tracker
		return;
	}

	// Determine what the bot needs most (weapon, health, shield, rune, etc)
	HealthWeight = CalcHealthNeed();
	WeaponWeight = CalcWeaponNeed();
	RuneWeight = 0.3;

	// Find the best inventory in the current poly group
	BestInventory = None;
	ActorTracker.GetActorsByPolyGroupIndex(NavContext.GetNavMeshPolyGroupIndex(), PolyGroupActors, NumPolyGroupActors);
	for(i = 0; i < NumPolyGroupActors; ++i)
	{
		Inv = Inventory(PolyGroupActors[i]);
		if(Inv != None)
		{
			CurrentScore = 0.0;
			if(Weapon(Inv) != None)		CurrentScore = WeaponWeight * ScoreInventory_Weapon(Weapon(Inv));
			else if(Food(Inv) != None)	CurrentScore = HealthWeight * ScoreInventory_Food(Food(Inv));
			else if(Runes(Inv) != None)	CurrentScore = RuneWeight * ScoreInventory_Rune(Runes(Inv));

			if(CurrentScore > BestScore)
			{
				BestInventory = Inv;
				BestScore = CurrentScore;
			}
		}
	}

	// Update the target inventory in blackboard
	if(BlackBoardWriteInterface != None)
	{
		BlackBoardWriteInterface.SetActor(BBKey_InventoryTarget, BestInventory);
	}
}

function float CalcWeaponNeed()
{
	local PlayerPawn PP;
	local int BestOwnedWeaponRating;
	local Inventory Inv;

	PP = GetOwnedPlayerPawn();
	if(PP == None)
	{
		return 0.0;
	}

	BestOwnedWeaponRating = 0;
	for(Inv = PP.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if(Weapon(Inv) != None && Weapon(Inv).Rating > BestOwnedWeaponRating)
		{
			BestOwnedWeaponRating = Weapon(Inv).Rating;
		}
	}

	return Utilities.Static.RemapFloatToRange(float(BestOwnedWeaponRating), 0.0, 4.0, 1.0, 0.0);
}

function float CalcHealthNeed()
{
	local PlayerPawn PP;

	PP = GetOwnedPlayerPawn();
	if(PP != None)
	{
		return Utilities.Static.RemapFloatToRange(float(PP.Health), 0.0, float(PP.MaxHealth), 1.0, 0.0);
	}

	return 0.0;
}

function float ScoreInventory_Weapon(Weapon WeaponInv)
{
	return Utilities.Static.RemapFloatToRange(float(WeaponInv.Rating), 0.0, 4.0, 0.2, 1.0);
}

function float ScoreInventory_Food(Food FoodInv)
{
	return Utilities.Static.RemapFloatToRange(float(FoodInv.Nutrition), 0.0, 35.0, 0.0, 1.0);
}

function float ScoreInventory_Rune(Runes RuneInv)
{
	return 1.0;
}

function UpdateNavContext(float DeltaSeconds)
{
	local int NodeIndex, PolyGroupIndex;
	local int OldNodeIndex, OldPolyGroupIndex;
	local R_NavMesh NavMesh;
	local R_BotBehavior Behavior;
	local int i;

	if(NavContext != None)
	{
		NavContext.GetNavMeshIndices(OldNodeIndex, OldPolyGroupIndex);

		NodeIndex = NavLib.Static.InvalidIndex();
		PolyGroupIndex = NavLib.Static.InvalidIndex();
		if(OwnedPlayerPawn != None)
		{
			NavMesh = GetNavMesh();
			if(NavMesh != None)
			{
				NodeIndex = NavMesh.FindContainingNodeIndex(OwnedPlayerPawn.Location);
				if(NodeIndex != NavLib.Static.InvalidIndex())
				{
					NavMesh.GetTrianglePolyGroupIndexUnchecked(NodeIndex, PolyGroupIndex);
				}
			}
		}

		NavContext.SetNavMeshNodeIndex(NodeIndex, PolyGroupIndex);

		// Fire events if necessary
		if(ActiveBehavior != None)
		{
			if(NodeIndex != OldNodeIndex)
			{
				OnNavMeshNodeIndexChanged(OldNodeIndex, NodeIndex);
			}
			if(PolyGroupIndex != OldPolyGroupIndex)
			{
				OnNavMeshPolyGroupIndexChanged(OldPolyGroupIndex, PolyGroupIndex);
			}
		}
	}
}

// Called from UpdateNavContext when a node index change is sensed
function OnNavMeshNodeIndexChanged(int OldNodeIndex, int NewNodeIndex)
{
	if(RecentlyVisitedNodes != None)
	{
		RecentlyVisitedNodes.Push(NewNodeIndex);
	}

	if(ActiveBehavior != None)
	{
		ActiveBehavior.OnNavMeshNodeIndexChanged(OldNodeIndex, NewNodeIndex);
	}
}

// Called from UpdateNavContext when a poly group index change is sensed
function OnNavMeshPolyGroupIndexChanged(int OldPolyGroupIndex, int NewPolyGroupIndex)
{
	if(RecentlyVisitedPolyGroups != None)
	{
		RecentlyVisitedPolyGroups.Push(NewPolyGroupIndex);
	}

	if(ActiveBehavior != None)
	{
		ActiveBehavior.OnNavMeshPolyGroupIndexChanged(OldPolyGroupIndex, NewPolyGroupIndex);
	}
}

// Called from Tick when a death is sensed from PlayerPawn state change
function OnOwnedPlayerPawnDied()
{
	ClearPath();
	if(ActiveBehavior != None)
	{
		ActiveBehavior.OnOwnedPlayerPawnDied();
	}
}

// Called from Tick when a respawn is sensed from PlayerPawn state change
function OnOwnedPlayerPawnRespawned()
{
	if(ActiveBehavior != None)
	{
		ActiveBehavior.OnOwnedPlayerPawnRespawned();
	}
}

//	TickBotObjects
//	Tick all bot objects created via CreateBotObject
//	BotObjects can disable their tick via SetTickBotObjectEnabled
function TickBotObjects(float DeltaSeconds)
{
	local int i;

	for(i = 0; i < ArrayCount(BotObjects); ++i)
	{
		if(BotObjects[i] != None)
		{
			BotObjects[i].BaseTickBotObject(DeltaSeconds);
		}
	}
}

function TickMovement(float DeltaSeconds)
{
	local Vector MovementVector;

	// Consume accumulated input vector
	MovementVector = Normal(AccumulatedInputVector) * FClamp(VSize(AccumulatedInputVector), 0.0, 1.0);
	AccumulatedInputVector = Vect(0,0,0);

	if(OwnedPlayerPawn != None)
	{
		//OwnedPlayerPawn.Acceleration = OwnedPlayerPawn.AccelRate * MovementVector;
		LastInputVector = MovementVector;
	}
}

// Returns the movement input vector which will best follow the current path
function Vector GetPathFollowMovementInputVector()
{
	local Vector PawnLocation, PathLocation;
	local Vector P0, P1;
	local int ClosestIndex;
	local int NumPathLocations;
	local float EndDistance;
	local int i;
	local Vector Result;
	
	if(NavContext == None || OwnedPlayerPawn == None)
	{
		return Vect(0,0,0);
	}

	PawnLocation = OwnedPlayerPawn.Location;
	ClosestIndex = NavContext.GetClosestPathLocationIndex2D(PawnLocation);

	if(ClosestIndex == NavLib.Static.InvalidIndex())
	{
		return Vect(0,0,0);
	}

	NumPathLocations = NavContext.GetNumPathLocations();

	if(ClosestIndex == NumPathLocations - 1)
	{
		NavContext.GetPathLocation(NumPathLocations - 2, P0);
		NavContext.GetPathLocation(NumPathLocations - 1, P1);
	}
	else
	{
		NavContext.GetPathLocation(ClosestIndex, P0);
		NavContext.GetPathLocation(ClosestIndex + 1, P1);
	}

	NavContext.GetPathLocation(NumPathLocations - 1, PathLocation);
	EndDistance = VSize(Vect(1,1,0) * PathLocation - Vect(1,1,0) * PawnLocation);
	if(EndDistance <= PATH_DISTANCE_TOLERANCE)
	{
		return Vect(0,0,0);
	}

	if(NavLib.Static.DistanceLocationToLineSegment2D(PawnLocation, P0, P1) > PATH_DISTANCE_TOLERANCE)
	{
		Result = P0 - PawnLocation;
	}
	else
	{
		Result = P1 - P0;
	}

	Result = Result * Vect(1,1,0);	// XY Input only
	return Normal(Result);
}

function Vector GetLastInputVector()
{
	return LastInputVector;
}

defaultproperties
{
	//InitialBehaviorClass=Class'RBots.R_BotBehavior_Wander'
	InitialBehaviorClass=Class'RBots.R_BotBehavior_FindWeapon'
}
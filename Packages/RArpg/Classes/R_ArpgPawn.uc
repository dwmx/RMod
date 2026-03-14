//==============================================================================
//	R_ArpgPawn
//	Base Pawn class for RArpg
//==============================================================================
class R_ArpgPawn extends PlayerPawn abstract;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const ArpgLib = Class'RArpgCore.R_ArpgLibrary';
const TagLib = Class'RArpgCore.R_ArpgTagLibrary';

const AIControllerClass = Class'RArpg.R_ArpgAIController';
var private R_ArpgAIController AIController;

var private R_ArpgEntity Entity;

var private Class<R_ArpgAnimationController> AnimationControllerClass;
var private R_ArpgAnimationController AnimationController;

var private Vector MovementInput;
var private Vector LookDirection;

struct R_ArpgSkillInstance
{
	var R_ArpgSkill Skill;
	var Name SkillName;
};
var private R_ArpgSkillInstance Skills[8];

var private float Experience;
//var private int Level;

var private int LockDirectionCount;
var private int LockMovementCount;

var private Class<R_ArpgInteractionProxy> InteractionProxyClass;

var private byte TeamIndex;
var private bool bIsDead;

// Movement Direction consts for PlayMoving
const MOVEDIR_NEUTRAL			= 0x0000;
const MOVEDIR_FORWARD 			= 0x0001;
const MOVEDIR_BACKWARD			= 0x0010;
const MOVEDIR_RIGHT				= 0x0100;
const MOVEDIR_LEFT				= 0x1000;
const MOVEDIR_FORWARD_RIGHT		= 0x0101;
const MOVEDIR_FORWARD_LEFT		= 0x1001;
const MOVEDIR_BACKWARD_RIGHT	= 0x0110;
const MOVEDIR_BACKWARD_LEFT		= 0x1010;

//------------------------------------------------------------------------------
//	Inventory events received from ItemContainerSets
//	These must match what are in R_ArpgItemContainerSet.uc
const EVENT_INVENTORY_SLOT_CHANGED = 'InventorySlotChanged';

//------------------------------------------------------------------------------

var private R_ArpgObserver_Collision Observer_Collision;

//------------------------------------------------------------------------------
//	Functions to be defined in subclasses
function SpawnAnimationProxy();
//------------------------------------------------------------------------------

function byte GetTeamIndex() { return TeamIndex; }
function SetTeamIndex(byte NewTeamIndex)
{
	if(TeamIndex != NewTeamIndex)
	{
		TeamIndex = NewTeamIndex;
		OnTeamIndexChanged();
	}
}
function OnTeamIndexChanged();

function bool IsDead()
{
	return bIsDead;
}

function SetObserver_Collision(R_ArpgObserver_Collision NewObserver_Collision)
{
	Observer_Collision = NewObserver_Collision;
}

function R_ArpgObserver_Collision GetObserver_Collision()
{
	return Observer_Collision;
}

function R_ArpgEntity GetEntity() { return Entity; }

function R_ArpgItemContainerSet GetInventorySet() { return None; }
function bool TryAddItem(R_ArpgItem Item) { return false; }

function ReceiveInventoryEvent(Name EventName, Name InventoryContainerName, R_ArpgItemContainerSet Sender, R_ArpgItem Items[2]);

function IncrementExperience(float Amount)
{
	SetExperience(Experience + Amount);
}

function SetExperience(float NewExperience)
{
	Experience = NewExperience;
}

function float GetExperience()
{
	return Experience;
}

function AddSkill(Class<R_ArpgSkill> SkillClass, Name SkillName)
{
	local R_ArpgSkill Skill;
	local int i;
	
	for(i = 0; i < ArrayCount(Skills); ++i)
	{
		if(Skills[i].Skill == None)
		{
			Skill = Spawn(SkillClass, Self);
			Skills[i].Skill = Skill;
			Skills[i].SkillName = SkillName;
			return;
		}
	}
}

function R_ArpgSkill GetSkill(int Index)
{
	return Skills[Index].Skill;
}

function SetLookDirection(Vector NewLookDirection)
{
	local Rotator NewRotation;

	// Skills (mainly) can lock the Pawn's rotation control
	// via SetLockDirection
	if(IsDirectionLocked())
	{
		return;
	}

	// Animation controller will not directly set the rotation, but it
	// may request a rotation value
	if(AnimationController != None
	&& AnimationController.IsRequestingRotationControl(NewRotation))
	{
		SetRotation(NewRotation);
		return;
	}

	// Otherwise, look where the player's mouse is pointing
	LookDirection = NewLookDirection;

	NewRotation = Rotator(LookDirection);
	NewRotation.Pitch = 0;
	NewRotation.Roll = 9000;

	SetRotation(NewRotation);
}

function Vector GetLookDirection()
{
	return LookDirection;
}

function AddMovementInput(Vector InputVector)
{
	MovementInput += InputVector;
}

event Tick(float DeltaSeconds)
{
	if(AIController != None)
	{
		AIController.TickAI(DeltaSeconds);
	}

	if(AnimationController != None)
	{
		AnimationController.Tick(DeltaSeconds);
	}

	PlayerTick(DeltaSeconds);
	if(Entity != None)
	{
		Entity.Tick(DeltaSeconds);
	}
}

function R_ArpgAnimationInterface GetAnimInterface()
{
	return AnimationController;
}

// For internal use ony
function R_ArpgAnimationController GetAnimController()
{
	return AnimationController;
}

function R_ArpgPawnAnimProxy GetAnimProxy()
{
	return R_ArpgPawnAnimProxy(AnimProxy);
}

function int GetMovementDirection()
{
	local Vector RX, RY, RZ;
	local Vector VelocityNormalized;
	local float VelocityDotForward;
	local float VelocityDotRight;
	local int Result;

	if(VSIze(Velocity) <= 32.0)
		return MOVEDIR_NEUTRAL;

	GetAxes(Rotation, RX, RY, RZ);

	VelocityNormalized = Normal(Velocity);
	VelocityDotForward = VelocityNormalized Dot RX;
	VelocityDotRight = VelocityNormalized Dot RY;

	Result = MOVEDIR_NEUTRAL;
	
	if(VelocityDotForward >= 0.2)		Result = Result | MOVEDIR_FORWARD;
	else if(VelocityDotForward <= -0.2)	Result = Result | MOVEDIR_BACKWARD;

	if(VelocityDotRight >= 0.2)			Result = Result | MOVEDIR_RIGHT;
	else if(VelocityDotRight <= -0.2)	Result = Result | MOVEDIR_LEFT;

	return Result;
}

function PlayWaiting(optional float Tween) {}
function PlayMoving(optional float Tween) {}

//------------------------------------------------------------------------------

function SetPawnAnim(
	Name AnimSequence,
	optional bool bUpperBody,
	optional bool bLowerBody,
	optional float Frame,
	optional float Rate)
{
	if(bLowerBody)
	{
		AnimSequence = AnimSequence;
		AnimFrame = Frame;
		AnimRate = Rate;
	}

	if(bUpperBody && AnimProxy != None)
	{
		AnimProxy.AnimSequence = AnimSequence;
		AnimProxy.AnimFrame = Frame;
		AnimProxy.AnimRate = Rate;
	}
}

function ClearPawnAnim(
	optional bool bUpperBody,
	optional bool bLowerBody)
{
}

function FrameNotify(int FramePassed)
{
}

function AnimProxyFrameNotify(int FramePassed)
{
}

//------------------------------------------------------------------------------
// Locks
// Skills call these functions to increment and decrement the lock counts

function LockMovement()
{
	if(LockMovementCount == 0)
	{
		Acceleration = Vect(0,0,0);
	}
	LockMovementCount++;
}

function UnlockMovement()
{
	LockMovementCount--;
}

function bool IsMovementLocked()
{
	return LockMovementCount > 0;
}

function bool CanMoveWhileAttacking()
{
	return false;
}

function LockDirection()
{
	LockDirectionCount++;
}

function UnlockDirection()
{
	LockDirectionCount--;
}

function bool IsDirectionLocked()
{
	return LockDirectionCount > 0;
}

//------------------------------------------------------------------------------

function UpdateRotation(float DeltaTime, float maxPitch)
{}

function Input_Skill(Name SkillName)
{
	local int i;

	for(i = 0; i < ArrayCount(Skills); ++i)
	{
		if(Skills[i].Skill != None && Skills[i].SkillName == SkillName)
		{
			Skills[i].Skill.ActivateSkill();
		}
	}
}

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		if(!IsMovementLocked())
		{
			NewAccel = MovementInput * 300.0;
			NewAccel.Z = 0.0;
		}
		else
		{
			NewAccel = Acceleration;
			NewAccel.Z = 0.0;
		}
		MovementInput = Vect(0,0,0);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
	}
}

simulated function DrawInWorldHUD(Canvas C)
{
	DrawHealthBar(C);
}

simulated function DrawHealthBar(Canvas C)
{
	local Vector ScreenSpaceLocation;
	local Vector Extent1, Extent2;
	local float Width, Height;
	local float HealthRatio;
	local float HealthBase, HealthAggregate;
	local float MaxHealthBase, MaxHealthAggregate;

	if(!GetAttributeValue('Health', HealthBase, HealthAggregate)
	|| !GetAttributeValue('MaxHealth', MaxHealthBase, MaxHealthAggregate))
	{
		return;
	}

	// This is the height and width at desired resolution 1920x1080
	// Bar size will scale linearly as resolution increases or decreases
	Width = 64.0 * (C.ClipX / 1920.0);
	Height = 4.0 * (C.ClipY / 1080.0);

	HealthRatio = HealthAggregate / MaxHealthAggregate;

	C.Reset();
	CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, Self, ScreenSpaceLocation, 16.0);

	Extent1 = ScreenSpaceLocation;
	Extent2 = ScreenSpaceLocation;

	Extent1.X -= Width / 2.0;
	Extent1.Y -= Height / 2.0;
	Extent2.Y += Height / 2.0;

	// Backdrop
	Extent2.X = Extent1.X + Width;
	CanvasLib.Static.DrawBoxSolid(C, Extent1, Extent2, 0.0, 0.0, 0.0, 1.0);

	// Health
	Extent2.X = Extent1.X + Width * HealthRatio;
	CanvasLib.Static.DrawBoxSolid(C, Extent1, Extent2, 1.0, 0.0, 0.0, 1.0);
}

function ArpgTakeDamage(float Damage)
{
	local R_ArpgEntity LocalEntity;
	local R_ArpgAttributeSet LocalAttributeSet;
	
	LocalEntity = GetEntity();
	if(LocalEntity != None)
	{
		LocalAttributeSet = LocalEntity.GetEntityAttributeSet();
	}
	if(LocalAttributeSet != None)
	{
		LocalAttributeSet.IncrementAttributeBaseValue('Health', -1.0 * Damage);
	}
}

function ArpgDie()
{
	bIsDead = true;
	GotoState('ArpgDying');
}

//------------------------------------------------------------------------------
//	Attributes
//	These are passed up from AttributeSet, through Entity, and to this Pawn

// ReceiveAttributeEvent
function ReceiveAttributeEvent(
	Name EventName,
	Name AttributeName,
	float PreviousBaseValue, float PreviousAggregateValue,
	float NewBaseValue, float NewAggregateValue)
{
	if(AttributeName == 'Health')
	{
		if(NewAggregateValue <= 0.0)
		{
			ArpgDie();
		}
	}
}

//	GetAttributeValue
//	Helper function for getting the current Base and Aggregate value of the
//	specified attribute
function bool GetAttributeValue(
	Name AttributeName,
	optional out float OutBaseValue,
	optional out float OutAggregateValue)
{
	local R_ArpgEntity LocalEntity;
	local R_ArpgAttributeSet LocalAttributeSet;
	local float BaseValue, AggregateValue;

	LocalEntity = GetEntity();
	if(LocalEntity != None)
	{
		LocalAttributeSet = LocalEntity.GetEntityAttributeSet();
	}
	if(LocalAttributeSet == None)
	{
		return false;
	}

	if(LocalAttributeSet.GetAttributeValue(AttributeName, BaseValue, AggregateValue))
	{
		OutBaseValue = BaseValue;
		OutAggregateValue = AggregateValue;
		return true;
	}

	return false;
}

//------------------------------------------------------------------------------
//	Pawn and PlayerPawn overrides

event PreBeginPlay()
{
	AddPawn();
	// Skip Pawn.PreBeginPlay because it spawns a PRI
	// Skip PlayerPawn.PreBeginPlay because it modifies the PRI
	Super(Actor).PreBeginPlay();
}

event PostBeginPlay()
{
	// Skip all Super.PostBeginPlay calls, they set up human player stuff
	bIsPlayer = false;

	// Create ArpgEntity object
	Entity = R_ArpgEntity(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgEntity', Self));
	Entity.SetOwnerPawn(Self);
	Entity.CreateAttributeSet(Class'RArpg.R_ArpgAttributeSet_Pawn');

	// Create AnimationController object
	if(AnimationControllerClass != None)
	{
		AnimationController = R_ArpgAnimationController(ArpgLib.Static.CreateArpgObject(AnimationControllerClass, Self));
	}

	Spawn(InteractionProxyClass, Self);
	SpawnAnimationProxy();

	if(Owner == None)
	{
		InitializeAIController();
	}
}

function InitializeAIController()
{
	if(AIController == None)
	{
		AIController = R_ArpgAIController(ArpgLib.Static.CreateArpgObject(AIControllerClass, Self));
		AIController.SetControlledPawn(Self);
	}
}

simulated event Destroyed()
{
	local Inventory Inv, NextInv;

	if(Shadow != None)	Shadow.Destroy();

	if(Role < ROLE_Authority)
	{
		return;
	}

	RemovePawn();

	// Remove all inventory
	// This should never get populated in the first place, but just in
	// case it somehow does
	for(Inv = Inventory; Inv != None; Inv = NextInv)
	{
		NextInv = Inv.Inventory;
		Inv.Destroy();
	}
	Weapon = None;
	Shield = None;
	Inventory = None;

	// Pawn.Destroy makes a call to GameInfo.Logout here -- avoid that

	// None of these should be initialized to begin with, but just in case
	// they somehow do
	if(PlayerReplicationInfo != None)	PlayerReplicationInfo.Destroy();
	if(MyHud != None)					MyHud.Destroy();
	if(Scoring != None)					Scoring.Destroy();

	while(FreeMoves != None)
	{
		FreeMoves.Destroy();
		FreeMoves = FreeMoves.NextMove;
	}

	while(SavedMoves != None)
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}
}

function ServerRestartGame(){}
function ServerRestartPlayer(){}

// Inventory functions
// These need to do nothing -- Arpg uses completely different inventory system
function bool AddInventory(Inventory NewItem) { return false; }
function bool DeleteInventory(Inventory Item) { return false; }
function AcquireInventory(Inventory Item) {}

// Gameplay functions
function Died(pawn Killer, name damageType, vector HitLocation) {}

//------------------------------------------------------------------------------

state ArpgDying
{
	event BeginState()
	{
		Acceleration = Vect(0,0,0);
		if(AnimProxy != None)
		{
			AnimProxy.Destroy();
			AnimProxy = None;
		}

		SetCollision(false, false, false);
	}

	function ReplaceWithCarcass()
	{
		local R_ArpgCarcass LocalCarcass;

		AnimRate = 0.0;
		LocalCarcass = Spawn(Class'RArpg.R_ArpgCarcass',,, Self.Location, Self.Rotation);
		if(LocalCarcass != None)
		{
			LocalCarcass.InitCarcassFromPawn(Self);
		}
	}

Begin:
	AnimationController.TryPlayStandardAnim('Death', 'FullBody', 1.0, 0.1);
	AnimationController.SetControllerEnabled(false);
	FinishAnim();
	ReplaceWithCarcass();
	Destroy();
}

//------------------------------------------------------------------------------

defaultproperties
{
	//RemoteRole=ROLE_AutonomousProxy
	RemoteRole=ROLE_SimulatedProxy
	InitialState=PlayerWalking
	DrawType=DT_SkeletalMesh
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	Mass=50.000000
    Buoyancy=35.000000
	InteractionProxyClass=Class'RArpg.R_ArpgInteractionProxy'
	AccelRate=2000.0
	TeamIndex=255
	bIsDead=false
	AnimationControllerClass=Class'RArpg.R_ArpgAnimationController_Pawn'
	LockMovementCount=0
	LockRotationCount=0
}
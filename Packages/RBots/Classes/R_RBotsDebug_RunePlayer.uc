//==============================================================================
//	R_RBotsDebug_RunePlayer
//	Special RunePlayer class for debugging bots
//	The purpose of this class is just to research how to perform generic control
//	of a RunePlayer without having to subclass one in the long run
//
//	Notes:
//	- Tick() will always be called
//	- PlayerTick() will not be called unless it is an actual player
//		- The movement and move animation code is all tied to this function
//		- Bot will need to assign the input axis values and call PlayerTick itself
//==============================================================================
class R_RBotsDebug_RunePlayer extends RunePlayer;

var float TimeAccumulator;
var float TimeRemaining;

var bool bIsCurrentlyAttacking;
var bool bStartedAttacking;

// Possible directions of attack inputs
enum R_AttackDirection
{
	AD_None,
	AD_Neutral,
	AD_Forward,
	AD_Backward,
	AD_Left,
	AD_Right
};

var R_AttackDirection PendingAttackDirection;
var int PendingAttackCombo;

// When a normal player moves with WASD, this is the magnitude assigned to aForward or aStrafe
// prior to PlayerMove being called
const MovementInputValue = 6000;

event BeginPlay()
{
	Super.BeginPlay();
	PendingAttackDirection = AD_None;
	bIsCurrentlyAttacking = false;
	bStartedAttacking = false;
}

// If the bot were to input Fire right now, what directional attack input would it get
function R_AttackDirection GetCurrentAttackDirectionIfFired()
{
	local Vector RX, RY, RZ;
	local Vector Velocity2D;
	local float DPForward, DPRight;

	GetAxes(Rotation, RX, RY, RZ);

	// This is laid out in RunePlayerProxy.Idle(State).Attack
	// This function chooses the initial attack direction based on velocity
	// That direction picking is copied here
	Velocity2D = Vect(1,1,0) * Velocity;
	if(Velocity2D Dot Velocity2D < 1000.0)
	{	// Neutral -- This is accurate for normal RunePlayer, but not R_RunePlayer because R_RunePlayer bases it on accel
		return AD_Neutral;
	}
	else
	{
		DPForward = RX Dot Normal(Acceleration);
		if(DPForward > 0.9)
		{	// Distinctly forward
			return AD_Forward;
		}
		if(DPForward < -0.9)
		{	// Distinctly backward
			return AD_Backward;
		}

		DPRight = RY Dot Normal(Acceleration);
		if(DPRight >= 0.0)
		{
			return AD_Right;
		}
		else
		{
			return AD_Left;
		}
	}

	return AD_Neutral;
}

function R_AttackDirection GetRandomAttackDirection()
{
	return AD_Forward;
	//local R_AttackDirection Options[5];
//
	//Options[0] = AD_Neutral;
	//Options[1] = AD_Forward;
	//Options[2] = AD_Backward;
	//Options[3] = AD_Right;
	//Options[4] = AD_Left;
//
	//return Options[Rand(5)];
}

function int GetRandomAttackCombo()
{
	return 2;
	//return Rand(2) + 1;
}

function bool IsCurrentlyAttacking()
{
	if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
	{
		return true;
	}
	return false;
}

function TickAttacking(float DeltaSeconds)
{
	local float t;
	local bool bNewIsCurrentlyAttacking;

	// Init movement input
	aForward = 0;
	aStrafe = 0;

	bNewIsCurrentlyAttacking = IsCurrentlyAttacking();
	if(bNewIsCurrentlyAttacking != bIsCurrentlyAttacking)
	{
		bIsCurrentlyAttacking = bNewIsCurrentlyAttacking;
		OnIsAttackingChanged(bIsCurrentlyAttacking);
	}
	//if(!IsCurrentlyAttacking())
	//{
	//	OnDoThingStarted();
	//}

	// After 3 seconds, do an attack, and then repeat it over and over
	TimeAccumulator += DeltaSeconds;
	if(TimeAccumulator >= 3.0)// && !bStartedAttacking)
	{
		bStartedAttacking = true;
		TimeAccumulator = 0.0;
		TimeRemaining = 1.0;
		OnDoThingStarted();
	}

	OnDoThingTick_PrePlayerTick(DeltaSeconds);
	//if(TimeRemaining > 0.0)
	//{
	//	TimeRemaining -= DeltaSeconds;
	//	TimeRemaining = FMax(0.0, TimeRemaining);
//
	//	OnDoThingTick_PrePlayerTick(DeltaSeconds);
	//	//// Do something, apply input example
	//	//aForward = MovementInputValue;
//
//
	//}
}

function OnIsAttackingChanged(bool bNewIsAttacking)
{
	if(bNewIsAttacking)
	{
		OnDoThingStarted();
	}
}

// Initialize the do thing state
function OnDoThingStarted()
{
	// Select a random attack direction
	PendingAttackDirection = GetRandomAttackDirection();
	PendingAttackCombo = GetRandomAttackCombo();

	//Say("I will do:" @ GetEnum(Enum'R_AttackDirection', PendingAttackDirection) @ "combo:" @ PendingAttackCombo);
}

// Do a thing, return true when done doing the thing
// This gets called before PlayerTick, so valid place to set input params
// Basically this just inputs the desired attack direction until pressing fire input will perform the correct attack
function OnDoThingTick_PrePlayerTick(float DeltaSeconds)
{
	local R_AttackDirection AttackDirIfFired;

	if(AnimProxy != None)
	{
		if(AnimProxy.GetStateName() == 'Attacking' && PendingAttackCombo > 0)
		{
			if(AnimProxy.AnimFrame > 0.2)
			{
				Fire();
				PendingAttackCombo = Max(PendingAttackCombo - 1, 0);
				if(PendingAttackCombo == 0)
				{
					PendingAttackDirection = AD_None;
				}
			}
			
			return;
		}
	}

	if(PendingAttackDirection == AD_None)
	{
		return;
	}

	AttackDirIfFired = GetCurrentAttackDirectionIfFired();

	if(AttackDirIfFired == PendingAttackDirection)
	{
		//BroadcastMessage("I think I did:" @ GetEnum(Enum'R_AttackDirection', AttackDirIfFired));
		Fire();
		PendingAttackCombo = Max(PendingAttackCombo - 1, 0);
		if(PendingAttackCombo == 0)
		{
			PendingAttackDirection = AD_None;
		}
		
		return;
	}

	switch(PendingAttackDirection)
	{
	case AD_Forward:	aForward = MovementInputValue;	break;
	case AD_Backward:	aForward = -MovementInputValue;	break;
	case AD_Right:		aStrafe = MovementInputValue;	break;
	case AD_Left:		aStrafe = -MovementInputValue;	break;
	}
}

function SetupPawnVariablesForDodge(EDodgeDir PerformDodgeDir)
{
	if(PerformDodgeDir == DODGE_None || PerformDodgeDir == DODGE_Active || PerformDodgeDir == DODGE_Done)
	{
		return;
	}

	bWasLeft = false;
	bEdgeLeft = false;
	bWasRight = false;
	bEdgeRight = false;
	bWasForward = false;
	bEdgeForward = false;
	bWasBack = false;
	bEdgeBack = false;

	switch(PerformDodgeDir)
	{
	case DODGE_Left:
		bWasLeft = true;
		bEdgeLeft = true;
		break;
	case DODGE_Right:
		bWasRight = true;
		bEdgeRight = true;
		break;
	case DODGE_Forward:
		bWasForward = true;
		bEdgeForward = true;
		break;
	case DODGE_Back:
		bWasBack = true;
		bEdgeBack = true;
		break;
	}

	DodgeDir = PerformDodgeDir;
	DodgeClickTime = 1.0;
}

function EDodgeDir GetRandomDodgeDir()
{
	local int Index;

	Index = Rand(5);
	switch(Index)
	{
	case 0:	return DODGE_Left;
	case 1: return DODGE_Right;
	case 2: return DODGE_Forward;
	case 3: return DODGE_Back;
	}

	return DODGE_None;
}

event Tick(float DeltaSeconds)
{
	super.Tick(DeltaSeconds);

	// Uncomment thins to perform some attacks
	//TickAttacking(DeltaSeconds);

	TimeAccumulator += DeltaSeconds;
	if(TimeAccumulator >= 3.0)
	{
		//TimeAccumulator = 0.0;
		SetupPawnVariablesForDodge(GetRandomDodgeDir());	// This sets the vars that will trigger a dodge in PlayerMove()
	}
	
	PlayerTick(DeltaSeconds);
	//DodgeClickTime = -3.0;
}
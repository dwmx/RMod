//==============================================================================
//	R_BotPawnController
//	The control interface between Bot and Pawn
//==============================================================================
class R_BotPawnController extends R_BotObject;

// Attack directions
const AttackDir_None = 0;
const AttackDir_Forward = 1;
const AttackDir_Backward = 2;
const AttackDir_Right = 3;
const AttackDir_Left = 4;
const AttackDir_Neutral = 5;

const AttackDir_MinIndex = 0;
const AttackDir_MaxIndex = 5;

// Dodge directions
const DodgeDir_None = 0;
const DodgeDir_Forward = 1;
const DodgeDir_Backward = 2;
const DodgeDir_Right = 3;
const DodgeDir_Left = 4;

const DodgeDir_MinIndex = 0;
const DodgeDir_MaxIndex = 4;

// This is the value that needs to be applied to a PlayerPawn's movement
// axes (aForward, aStrafe) in order to mimmick keyboard input
const MovementInputMagnitude = 6000.0;

var private int PendingAttackDir;
var private int PendingAttackComboCount;
var private float PendingAttackComboAnimFrame; // Used for keeping track of when combo attacks were processed
var private int PendingDodgeDir;
var private bool bPendingJump;

var private Vector AccumulatedMovementInput;
var private Vector ViewDirection;
var private float DodgeCooldownTimerSeconds; // Must be 0 for bot to dodge

var private float AccumulatedTime; // For testing

function InitBotObject()
{
	PendingAttackDir = AttackDir_None;
}

function String GetAttackDirString(int AttackDir)
{
	switch(AttackDir)
	{
	case AttackDir_None:		return "AttackDir_None";
	case AttackDir_Forward:		return "AttackDir_Forward";
	case AttackDir_Backward:	return "AttackDir_Backward";
	case AttackDir_Right:		return "AttackDir_Right";
	case AttackDir_Left:		return "AttackDir_Left";
	case AttackDir_Neutral:		return "AttackDir_Neutral";
	}
	return "AttackDir_Invalid";
}

function TickBotObject(float DeltaSeconds)
{
	local PlayerPawn PP;
	local AnimationProxy AP;
	local Rotator NewRotation;
	local float DPX, DPY;
	local Vector RX, RY, RZ;
	local int AttackRand;
	local Vector MovementInput;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return;
	}

	// Update view and pawn rotation
	ViewDirection = Normal(ViewDirection);
	PP.ViewRotation = Rotator(ViewDirection);
	pp.TargetViewRotation = Rotator(ViewDirection);
	PP.DesiredRotation = Rotator(ViewDirection);
	PP.SetRotation(Rotator(Vect(1,1,0) * ViewDirection));

	GetAxes(NewRotation, RX, RY, RZ);

	// Always consume the movement input, even though attack movement may override the movement
	MovementInput = ConsumeMovementInput();

	// If an attack needs to be performed, and we're free to attack, then move in the
	// direction that will allow us to perform the attack
	if(HasPendingAttack() && CanPerformAttack())
	{	// When there is a pending attack, then attack-required movement overrides input
		PP.aForward = 0.0;
		PP.aStrafe = 0.0;
		switch(PendingAttackDir)
		{
		case	AttackDir_Forward:	PP.aForward = MovementInputMagnitude;	break;
		case	AttackDir_Backward:	PP.aForward = -MovementInputMagnitude;	break;
		case	AttackDir_Right:	PP.aStrafe	= MovementInputMagnitude;	break;
		case	AttackDir_Left:		PP.aStrafe	= -MovementInputMagnitude;	break;
		}
		if(GetCurrentAttackDirIfFired() == PendingAttackDir)
		{
			PendingAttackDir = AttackDir_None;
			PendingAttackComboAnimFrame = 100.0;
			PP.Fire();
		}
	}
	else if(HasPendingAttackCombo() && CanPerformAttackCombo())
	{
		AP = GetAnimProxy();
		if(AP != None && AP.AnimFrame < PendingAttackComboAnimFrame)
		{
			PendingAttackComboAnimFrame = 0.0;
			PendingAttackComboCount = Max(0, PendingAttackComboCount - 1);
			PP.Fire();
		}
	}
	else
	{	// If no attack input, then move in the input direction
		DPX = RX Dot MovementInput;
		DPY = RY Dot MovementInput;
		PP.aForward = MovementInputMagnitude * DPX;
		PP.aStrafe = MovementInputMagnitude * DPY;
	}

	// Jump if requested
	if(bPendingJump)
	{
		bPendingJump = false;
		PP.Jump();
	}

	// Tick dodging and dodge if requested
	DodgeCooldownTimerSeconds -= DeltaSeconds;
	DodgeCooldownTimerSeconds = FMax(0.0, DodgeCooldownTimerSeconds);
	if(PendingDodgeDir != DodgeDir_None)
	{
		SetPawnVarsToTriggerDodge(PendingDodgeDir);
		PendingDodgeDir = DodgeDir_None;
	}

	// PlayerTick is the main update function for PlayerPawns, but it's only called if the owner is a
	// human player -- Needs to be called directly from here
	PP.PlayerTick(DeltaSeconds);
	SetPawnVarsToTriggerDodge(DodgeDir_None);
}

// Sets the required dodge variables on player pawn so that the dodge will be triggered on the next
// call to PlayerPawn.PlayerMove()
function SetPawnVarsToTriggerDodge(int DodgeDir)
{
	local PlayerPawn PP;

	if(DodgeDir < DodgeDir_MinIndex || DodgeDir > DodgeDir_MaxIndex)
	{
		return;
	}

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return;
	}

	PP.bWasLeft = false;		PP.bEdgeLeft = false;
	PP.bWasRight = false;		PP.bEdgeRight = false;
	PP.bWasForward = false;		PP.bEdgeForward = false;
	PP.bWasBack = false;		PP.bEdgeBack = false;

	switch(DodgeDir)
	{
	case DodgeDir_Forward:	PP.bWasForward = true;	PP.bEdgeForward = true;		PP.DodgeDir = DODGE_Forward;	break;
	case DodgeDir_Backward:	PP.bWasBack = true;		PP.bEdgeBack = true;		PP.DodgeDir = DODGE_Back;		break;
	case DodgeDir_Left:		PP.bWasLeft = true;		PP.bEdgeLeft = true;		PP.DodgeDir = DODGE_Left;		break;
	case DodgeDir_Right:	PP.bWasRight = true;	PP.bEdgeRight = true;		PP.DodgeDir = DODGE_Right;		break;
	}
	PP.DodgeClickTime = 1.0;
}

// Sets the pending attack direction which will be processed next Tick
// Overwrites the pending attack direction if one is already set
// Use HasPendingAttack to avoid overwriting
function Attack(int AttackDir, optional int ComboCount)
{
	if(AttackDir < AttackDir_MinIndex || AttackDir > AttackDir_MaxIndex)
	{
		return;
	}
	PendingAttackDir = AttackDir;
	PendingAttackComboCount = ComboCount;
}

// Returns true if this Bot's Pawn can perform an attack in the next
// Tick after this function is called
function bool CanPerformAttack()
{
	local PlayerPawn PP;
	local AnimationProxy AP;

	// Pawn must be valid and must have a weapon
	PP = GetPlayerPawn();
	if(PP == None || PP.Weapon == None)
	{
		return false;
	}

	// AnimProxy must be valid and in Idle state
	AP = GetAnimProxy();
	if(AP == None || AP.GetStateName() != 'Idle')
	{
		return false;
	}

	return true;
}

// Returns true if there is already a pending attack set
// from a previous call to Attack()
// Main purpose is to allow callers to avoid over-writing or
// accidentally spamming the Attack function
function bool HasPendingAttack()
{
	return PendingAttackDir >= AttackDir_MinIndex
		&& PendingAttackDir <= AttackDir_MaxIndex
		&& PendingAttackDir != AttackDir_None;
}

// Returns true if an attack combo can be performed in the Pawn's
// current state
function bool CanPerformAttackCombo()
{
	local AnimationProxy AP;

	AP = GetAnimProxy();
	if(AP == None)
	{
		return false;
	}

	return AP.GetStateName() == 'Attacking' && AP.AnimFrame > 0.0;
}

// Returns true if there is still a combo attack waiting
// to be processed
function bool HasPendingAttackCombo()
{
	return PendingAttackComboCount > 0;
}

function Dodge(int DodgeDir)
{
	if(DodgeDir < DodgeDir_MinIndex || DodgeDir > DodgeDir_MaxIndex)
	{
		return;
	}

	if(!CanPerformDodge())
	{
		return;
	}

	PendingDodgeDir = DodgeDir;
	DodgeCooldownTimerSeconds = 1.0; // Need to match this to DodgeClickTime -- but i think it is 1
}

function bool CanPerformDodge()
{
	local PlayerPawn PP;

	if(PendingDodgeDir != DodgeDir_None)
	{
		return false;
	}

	PP = GetPlayerPawn();
	if(PP == None || PP.Physics != PHYS_Walking)
	{
		return false;
	}

	return DodgeCooldownTimerSeconds <= 0.0;
}

// This functions returns the directional attack that would be triggered if the bot were to call
// PlayerPawn.Fire in this Tick
// Keep in mind that RunePlayer and R_RunePlayer are slightly different here, because R_RunePlayer
// is entirely accel based -- may need to subclass this controll for different pawns
function int GetCurrentAttackDirIfFired()
{
	local PlayerPawn PP;
	local Vector RX, RY, RZ;
	local Vector Velocity2D;
	local float DPForward, DPRight;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return AttackDir_None;
	}

	GetAxes(PP.Rotation, RX, RY, RZ);

	// This is laid out in RunePlayerProxy.Idle(State).Attack
	// This function chooses the initial attack direction based on velocity
	// That direction picking is copied here
	Velocity2D = Vect(1,1,0) * PP.Velocity;
	if(Velocity2D Dot Velocity2D < 1000.0)
	{	// Neutral -- This is accurate for normal RunePlayer, but not R_RunePlayer because R_RunePlayer bases it on accel
		return AttackDir_Neutral;
	}
	else
	{
		DPForward = RX Dot Normal(PP.Acceleration);
		if(DPForward > 0.9)
		{	// Distinctly forward
			return AttackDir_Forward;
		}
		if(DPForward < -0.9)
		{	// Distinctly backward
			return AttackDir_Backward;
		}

		DPRight = RY Dot Normal(PP.Acceleration);
		if(DPRight >= 0.0)
		{
			return AttackDir_Right;
		}
		else
		{
			return AttackDir_Left;
		}
	}

	return AttackDir_Neutral;
}

function AddMovementInput_WorldSpace(Vector MovementInput)
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return;
	}

	AccumulatedMovementInput += (MovementInput << PP.Rotation);
}

function Vector ConsumeMovementInput()
{
	local Vector Result;

	Result = Normal(AccumulatedMovementInput);
	AccumulatedMovementInput = Vect(0,0,0);
	return Result;
}

// Update rotation to look at the provided location
function LookAt_WorldSpace(Vector Location)
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return;
	}

	ViewDirection = Normal(Location - PP.Location);
}

function Jump()
{
	bPendingJump = true;
}

function bool CanPerformJump()
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return false;
	}

	return PP.Physics == PHYS_Walking;
}

function SwitchWeapon(byte InventoryCode)
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP != None)
	{
		PP.SwitchWeapon(InventoryCode);
	}
}
function StowWeapon()				{ SwitchWeapon(1); }
function SwitchWeapon_NextSword()	{ SwitchWeapon(2); }
function SwitchWeapon_NextHammer()	{ SwitchWeapon(3); }
function SwitchWeapon_NextAxe()		{ SwitchWeapon(4); }

function bool CanPerformSwitchWeapon()
{
	local PlayerPawn PP;
	local AnimationProxy AP;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return false;
	}

	AP = PP.AnimProxy;
	if(AP == None)
	{
		return false;
	}

	return AP.GetStateName() == 'Idle';
}

// Call use on owned PlayerPawn and return whether or not a UseActor was selected
function bool TryUse()
{
	local PlayerPawn PP;

	PP = GetPlayerPawn();
	if(PP != None)
	{
		PP.Use();
		return PP.UseActor != None;
	}
	
	return false;
}
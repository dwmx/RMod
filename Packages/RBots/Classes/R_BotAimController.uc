//==============================================================================
//	R_BotAimController
//	Manages all aiming for R_Bot
//==============================================================================
class R_BotAimController extends R_BotObject;

enum R_AimMode
{
	AimMode_Forward,	// Aim straight forward always
	AimMode_Perfect		// Perfect aimbot style aiming
};
var private R_AimMode AimMode;

function InitBotObject()
{}

function bool IsBotAttacking()
{
	local PlayerPawn PP;
	local AnimationProxy AP;
	local Name StateName;

	PP = GetPlayerPawn();
	if(PP != None)
	{
		AP = PP.AnimProxy;
		if(AP != None)
		{
			StateName = AP.GetStateName();
			if(StateName == 'Attacking' || StateName == 'Recovering')
			{
				return true;
			}
		}
	}

	return false;
}

function Vector GetAimLocationForTargetActor(Actor TargetActor)
{
	if(TargetActor == None)
	{
		return Vect(0,0,0);
	}
	return TargetActor.Location;
}

function Vector GetAimDirection_Forward(Vector TargetLocation)
{
	local PlayerPawn PP;
	local Vector Delta;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		return Vect(0,0,0);
	}

	Delta = TargetLocation - PP.Location;
	return Normal(Vect(1,1,0) * Delta);
}

function Vector GetAimDirection_Perfect(Vector TargetLocation)
{
	local PlayerPawn PP;
	local Weapon W;
	local Rotator AimRot;
	local Vector WeaponDir, TargetDir, AimDir;

	 PP = GetPlayerPawn();
	 if(PP == None)
	 {
		return Vect(0,0,0);
	 }

	 // Direction towards target
	 TargetDir = Normal(Vect(1,1,0) * (TargetLocation - PP.Location));

	 // Direction towards weapon
	 W = PP.Weapon;
	 if(W != None)
	 {
		WeaponDir = Normal(Vect(1,1,0) * (W.GetJointPos(W.SweepJoint2) - PP.Location));
	 }
	 else
	 {
		WeaponDir = TargetDir;
	 }

	 AimRot.Yaw = Rotator(TargetDir).Yaw - (Rotator(WeaponDir).Yaw - PP.Rotation.Yaw);
	 AimDir = Vector(Normalize(AimRot));

	 return AimDir;
}

function UpdatePlayerPawnAim(Vector AimDirection)
{
	local PlayerPawn PP;
	local Rotator NewRotation;

	PP = GetPlayerPawn();
	if(PP == None || AimDirection == Vect(0,0,0))
	{
		return;
	}

	NewRotation = Rotator(AimDirection);
	PP.ViewRotation = NewRotation;
	PP.TargetViewRotation = NewRotation;
	PP.DesiredRotation = NewRotation;
	PP.SetRotation(NewRotation);
}

function TickBotObject(float DeltaSeconds)
{
	local bool bIsBotAttacking;
	local R_BotPerception BotPerception;
	local Vector AimLocation;
	local Vector AimDirection;

	bIsBotAttacking = IsBotAttacking();

	if(!bIsBotAttacking)
	{	// For now, just return if not attacking
		return;
	}

	// Get aim target
	AimLocation = Vect(0,0,0);
	BotPerception = GetBotPerception();
	if(BotPerception != None)
	{
		AimLocation = GetAimLocationForTargetActor(BotPerception.GetPerceivedActor());
	}

	// Get aim direction
	switch(AimMode)
	{
		case AimMode_Forward:	AimDirection = GetAimDirection_Forward(AimLocation);	break;
		case AimMode_Perfect:	AimDirection = GetAimDirection_Perfect(AimLocation);	break;
	}

	// Update player pawn's aim
	UpdatePlayerPawnAim(AimDirection);
}

defaultproperties
{
	//AimMode=AimMode_Forward
	AimMode=AimMode_Perfect
}
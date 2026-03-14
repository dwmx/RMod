class R_ArpgSkill extends Actor abstract;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

var private float CooldownDurationSeconds;

function R_ArpgPawn GetArpgPawnOwner()
{
	return R_ArpgPawn(Owner);
}

function R_ArpgObserver_Collision GetObserver_Collision()
{
	local R_ArpgPawn PawnOwner;

	PawnOwner = GetArpgPawnOwner();
	if(PawnOwner != None)
	{
		return PawnOwner.GetObserver_Collision();
	}
	return None;
}

function InitializeSkill()
{}

function ActivateSkill()
{}

//------------------------------------------------------------------------------
// Helpers

function TryPlayStandardAnim(
	Name StandardName,
	Name Slot,
	float Rate,
	float Tween,
	optional R_ArpgObject CallbackObject)
{
	local R_ArpgPawn LocalPawn;
	local R_ArpgAnimationInterface LocalAnimInterface;

	LocalPawn = R_ArpgPawn(Owner);
	if(LocalPawn != None)
	{
		LocalAnimInterface = LocalPawn.GetAnimInterface();
		if(LocalAnimInterface != None)
		{
			LocalAnimInterface.TryPlayStandardAnim(StandardName, Slot, Rate, Tween, CallbackObject);
		}
	}
}

//------------------------------------------------------------------------------

auto state Idle
{}

state Cooldown
{
	event BeginState()
	{
		if(CooldownDurationSeconds <= 0.0)
		{
			GotoState('Idle');
		}
	}

Begin:
	Sleep(CooldownDurationSeconds);
	GotoState('Idle');
}

defaultproperties
{
	CooldownDurationSeconds=0.0
}
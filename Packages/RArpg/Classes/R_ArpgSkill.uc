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
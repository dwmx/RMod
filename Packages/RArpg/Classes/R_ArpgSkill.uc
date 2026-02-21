class R_ArpgSkill extends Actor abstract;

var private float CooldownDurationSeconds;

function R_ArpgPawn GetOwnerPawn()
{
	return R_ArpgPawn(Owner);
}

function InitializeSkill()
{}

function ActivateSkill()
{
}

function OwnerFrameNotify(int framepassed)
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
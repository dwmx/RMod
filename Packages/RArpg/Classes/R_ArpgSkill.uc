class R_ArpgSkill extends Actor abstract;

var private float CooldownDurationSeconds;

function R_ArpgPawn GetOwnerPawn()
{
	return R_ArpgPawn(Owner);
}

function InitializeSkill()
{}

function ActivateSkill()
{}

function OwnerFrameNotify(int framepassed)
{}

function SetFullBodyAnim(Name AnimSequence, optional float Rate, optional float Frame)
{
	local R_ArpgPawn Pawn;
	local R_ArpgPawnAnimProxy AnimProxy;

	Pawn = GetOwnerPawn();
	if(Pawn != None)
	{
		Pawn.AnimSequence = AnimSequence;
		Pawn.AnimRate = Rate;
		Pawn.AnimFrame = Frame;

		AnimProxy = Pawn.GetAnimProxy();
		if(AnimProxy != None)
		{
			AnimProxy.AnimSequence = AnimSequence;
			AnimProxy.AnimRate = Rate;
			AnimProxy.AnimFrame = Frame;
		}
	}
}

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
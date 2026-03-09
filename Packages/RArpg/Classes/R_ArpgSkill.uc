class R_ArpgSkill extends Actor abstract;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

var private float CooldownDurationSeconds;

var private R_ArpgObserver_Collision Observer_Collision;

function R_ArpgObserver_Collision GetObserver_Collision()	{ return Observer_Collision; }
function SetObserver_Collision(R_ArpgObserver_Collision NewObserver_Collision)
{
	Observer_Collision = NewObserver_Collision;
}

function R_ArpgPawn GetArpgPawnOwner()
{
	return R_ArpgPawn(Owner);
}

function InitializeSkill()
{}

function ActivateSkill()
{}

function DrawDebug(Canvas C)
{
	// TODO: Move this to debug package
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
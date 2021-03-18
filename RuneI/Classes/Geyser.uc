//=============================================================================
// Geyser.
//=============================================================================
class Geyser expands Effects;

//
// To do:
//
// - Add sounds
//

// EDITABLE INSTANCE VARIABLES ------------------------------------------------

// INSTANCE VARIABLES ---------------------------------------------------------

var ParticleSystem PSSteam;
var float GStateTime;
var() class<ParticleSystem>	SpawnSystem;

// FUNCTIONS ------------------------------------------------------------------

function PostBeginPlay()
{
	Super.PostBeginPlay();

//	PSSteam = Spawn(class'SteamGeyser');
	PSSteam = Spawn(SpawnSystem);
	if(PSSteam == None)
		return;
//	PSSteam.ParticleCount = 1;
	PSSteam.bHidden = true;
	PSSteam.AlphaStart = 0;
	SoundVolume = 0;
}

// STATES ---------------------------------------------------------------------

auto state GeyserDelay
{
	event BeginState()
	{
		if(PSSteam == None)
			GotoState('');
		PSSteam.bHidden = true;
	}

begin:
	Sleep(4+FRand()*4);
	GotoState('BeginEmission');
}

state BeginEmission
{
	event BeginState()
	{
		//slog("BeginEmission");
		GStateTime = 0.0;
		PSSteam.bHidden = false;
	}

	event Tick(float deltaTime)
	{
		GStateTime += deltaTime;

		PSSteam.ParticleCount = 1+GStateTime*100;
		PSSteam.AlphaStart = GStateTime*125;
		SoundVolume = Clamp(GStateTime*425, 0, 255);
		if(PSSteam.ParticleCount > 59)
			GotoState('ContinuousEmission');
	}
}

state ContinuousEmission
{
	//event BeginState()
	//{
	//	slog("ContinuousEmission");
	//}

begin:
	Sleep(5+FRand()*6);
	GotoState('EndEmission');
}

state EndEmission
{
	event BeginState()
	{
		//slog("EndEmission");
		GStateTime = 0.0;
	}

	event Tick(float deltaTime)
	{
		GStateTime += deltaTime;

		PSSteam.ParticleCount = 60-(GStateTime*20);
		PSSteam.AlphaStart = 75-(GStateTime*25);
		SoundVolume = Clamp(254 - (GStateTime*85), 0, 255);
		if(PSSteam.ParticleCount < 2)
		{
			PSSteam.AlphaStart = 0;
			GotoState('GeyserDelay');
		}
	}
}

defaultproperties
{
     bHidden=True
     DrawType=DT_Sprite
     SoundRadius=48
}

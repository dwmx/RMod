class R_ArenaLight extends Actor;

var() bool bInitiallyOn;
var() R_ArenaLight Next;
var R_ArenaLight Last;
var Actor LightActor;
var float TimeStamp;
var bool bOn;

simulated event PostBeginPlay()
{
	//if(Role < ROLE_Authority)
	//{
		if(Next != None)
		{
			Next.Last = Self;
		}
		
		LightActor = Spawn(class'RuneI.DanglerLight', Self,, Location);
		LightActor.LightRadius = 4;
		LightActor.LightSaturation = 100;
		
		if(bInitiallyOn)
		{
			TurnOn();
		}
		else
		{
			TurnOff();
		}
	//}
}

simulated event Tick(float DeltaSeconds)
{
	if(bOn)
	{
		if(Level.TimeSeconds - TimeStamp >= 0.1)
		{
			TurnOff();
			if(Next != None)
			{
				Next.TurnOn();
			}
		}
	}
	//local float t;
	//
	//if(LightActor != None)
	//{
	//	t = (sin(Level.TimeSeconds) + 1.0) / 2.0;
	//	LightActor.LightBrightness = byte((1.0 - t) * 25 + t * 250);
	//	LightActor.LightRadius = byte((1.0 - t) * 2.0 + t * 4.0);
	//}
}

simulated function TurnOn()
{
	bOn = true;
	TimeStamp = Level.TimeSeconds;
	LightActor.LightHue = 150;
	//LightActor.LightRadius = 4;
	LightActor.LightBrightness = 250;
	//LightActor.LightSaturation = 100;
}

simulated function TurnOff()
{
	bOn = false;
	LightActor.LightHue = 0;
	//LightActor.LightRadius = 0;
	LightActor.LightBrightness = 0;
	//LightActor.LightSaturation = 0;
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	TurnOn();
}

defaultproperties
{
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'objects.Plate'
}

//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

var private Vector TargetLocation;
var private Actor TargetActor;

auto state ChasePlayer
{
	event BeginState()
	{
		SetPhysics(PHYS_Walking);
	}

	event Tick(float DeltaSeconds)
	{
		//Velocity = Vect(0,100,0);
		/*
		local Pawn P;

		Target = None;
		TargetLocation = Self.Location;
		for(P = Level.PawnList; P != None; P = P.NextPawn)
		{
			if(R_ArpgRunePlayer(P) != None)
			{
				TargetActor = P;
				TargetLocation = P.Location;
				break;
			}
		}
			*/
	}

//Begin:
//Chase:
//	MoveTo(TargetLocation, 220.0);
//	Sleep(0.01);
//	GoTo('Chase');
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	Mass=50.000000
    Buoyancy=35.000000
	InitialState=ChasePlayer
}
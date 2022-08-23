//=============================================================================
// Rope.
//=============================================================================
//NOTES FOR SWAYING EFFECT:
//To disable swaying, set bDisableSway to true.
//If Swaying is enabled, you can adjust the MaxSway and the IdleSway to suit your needs.
//Be carefull of setting MaxSway too high, as it will cause the rope to look bent almost...

class Rope extends BeamSystem;

var private vector RopeTop;		// Top of visual rope as defined by Collision Height
var private vector RopeBottom;	// Bottom of visual rope as defined by Collision Height
var vector RopeClimbTop;		// Top of climbable portion of rope (determined by a trace)
var vector RopeClimbBottom;		// Bottom of climbable portion of rope (determined by a trace)

var bool bActorAttached;		// Whether there's a pawn hanging on me
var vector LocationAttached;	// position of attached actor
var Actor AttachedActor;

var float ElapsedTime;
var float CurMultiplier;
var int ValidControlPoint;

var (Rope) bool bDisableSway;
var (Rope) float MaxSway;
var (Rope) float IdleSway; 

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Precompute some constants
	RopeTop = Location + vect(0,0,1)*CollisionHeight;
	RopeBottom = Location - vect(0,0,1)*CollisionHeight;

	//LocationAttached = Location;
	OriginOffset = vect(0,0,1)*CollisionHeight;
	TargetLocation = RopeBottom;

	ComputeClimbingEndpoints(Location.Z);

	LocationAttached = Location + vect(0,0,-1) * CollisionHeight;
 
  	if(bDisableSway)
 		bEventSystemTick = False;
	else
	{
		bEventSystemTick = True;
		CurMultiplier = IdleSway;
 		ValidControlPoint = 0;
 	}
}

// This is done everytime it get's touched because designers might put in breakable geometry (polyobjs)
// between the top and bottom, messing with the trace
simulated function ComputeClimbingEndpoints(float tracestartz)
{
	local vector HitLocation, HitNormal;
	local actor A;
	local vector TraceStart;

	TraceStart = Location;
	TraceStart.Z = tracestartz;

	A = Trace(HitLocation, HitNormal, RopeTop, TraceStart, false, vect(1,1,1)*20);
	if (A!=None)
		RopeClimbTop = HitLocation;
	else
		RopeClimbTop = RopeTop;

	A = Trace(HitLocation, HitNormal, RopeBottom, TraceStart, false, vect(1,1,1)*20);
	if (A!=None)
		RopeClimbBottom = HitLocation;
	else
		RopeClimbBottom = RopeBottom;
}


function AttachedToRope(actor Other)
{
	if (!bActorAttached)		// Disallow if someone using rope already
	{
		bActorAttached = true;
		AttachedActor = Other;
		LocationAttached = AttachedActor.Location + vect(0,0,1) * AttachedActor.CollisionHeight;
		CurMultiplier = MaxSway;
	}
}

function DetachFromRope(actor Other)
{
	bActorAttached = false;
	LocationAttached = Location + vect(0,0,-1) * CollisionHeight;
	AttachedActor = None;
	ValidControlPoint = 0;
	CurMultiplier = MaxSway;

	//LocationAttached = Location;
}

function int GetValidPoint()
{
	local int i;
	
 	for(i = 1; i < NumConPts; i++)
 	{
 		if(ConnectionPoint[i].Z < LocationAttached.Z) 
 			return i;
 	}
 	
 	return NumConPts;
}


//=============================================================================
//
// SystemTick 
//
// Update the rope to sway it (if allowed)
//=============================================================================
event SystemTick(float DeltaSeconds)
{
	/*
	local int i;
	local vector Delta;

	// Locations of rope
	Delta = Normal(LocationAttached-RopeTop)*(2*CollisionHeight)/(NumConPts-1);

	for(i = 0; i < NumConPts; i++)
	{
		ConnectionPoint[i] = RopeTop + i * Delta;
	}
	*/
	
	local int i;
	local vector tempVect;
	ElapsedTime += DeltaSeconds;
	
	if(bActorAttached)
	{						
		tempVect = AttachedActor.Location + vect(0,0,-1) * AttachedActor.CollisionHeight;
		if(tempVect != LocationAttached) 		//Actor has moved....
		{
			LocationAttached = tempVect;
			CurMultiplier = MaxSway;			//Put some power back into the sway...
			ValidControlPoint = GetValidPoint();		//Find the point below the actor..
		}
	}
	
		for(i = 1; i < NumConPts; i++)
		{
			if(i > ValidControlPoint)
			{
				ConnectionOffset[i].X = ConnectionOffset[i-1].X + CurMultiplier * Sin(ElapsedTime * 2 + ((ValidControlPoint - i)/4)) * (ValidControlPoint - i);
				ConnectionOffset[i].Y = ConnectionOffset[i-1].Y + CurMultiplier * Cos(ElapsedTime * 2 + ((ValidControlPoint - i/4))) * (ValidControlPoint - i);
			}
			else
			{
				ConnectionOffset[i] = vect(0,0,0);
			}	
		}
	
	if(CurMultiplier > (IdleSway + 0.003))		//Slowly decrement the sway amount to let the rope's velocity die out..
		CurMultiplier -= 0.003;
}


simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;
	local int i;

	Super.Debug(canvas, mode);

	Canvas.DrawText("Rope:");
	Canvas.CurY -= 8;
	
	Canvas.DrawText("Current Multiplier: " @curMultiplier);
	Canvas.CurY -= 8;
	Canvas.DrawText("ValidControlPoint: " @ValidControlPoint);
 	Canvas.CurY -= 8;
 	Canvas.DrawText("bDisableSway: " @bDisableSway);
	Canvas.CurY -= 8; 		
 	Canvas.DrawText("bEventSystemTick: " @bEventSystemTick);
 	Canvas.CurY -= 8;


	Canvas.DrawLine3D(RopeClimbTop + vect(20, 0, 0), RopeClimbTop + vect(-20, 0, 0), 255, 0, 0);
	Canvas.DrawLine3D(RopeClimbTop + vect(0, 20, 0), RopeClimbTop + vect(0, -20, 0), 255, 0, 0);	
	Canvas.DrawLine3D(RopeClimbTop + vect(0, 0, 20), RopeClimbTop + vect(0, 0, -20), 255, 0, 0);

	Canvas.DrawLine3D(RopeClimbBottom + vect(20, 0, 0), RopeClimbBottom + vect(-20, 0, 0), 0, 255, 0);
	Canvas.DrawLine3D(RopeClimbBottom + vect(0, 20, 0), RopeClimbBottom + vect(0, -20, 0), 0, 255, 0);	
	Canvas.DrawLine3D(RopeClimbBottom + vect(0, 0, 20), RopeClimbBottom + vect(0, 0, -20), 0, 255, 0);
	
	Canvas.DrawLine3D(LocationAttached + vect(15,15,0), LocationAttached + vect(-15,-15,0),0,255,0);
	Canvas.DrawLine3D(LocationAttached + vect(15,-15,0), LocationAttached + vect(-15,15,0),0,255,0);

/*
	// Locations of rope
	for(i = 0; i < NumConPts; i++)
	{
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(10, 0, 0), ConnectionPoint[i] + vect(-10, 0, 0), 0, 255, 0);
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(0, 10, 0), ConnectionPoint[i] + vect(0, -10, 0), 0, 255, 0);	
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(0, 0, 10), ConnectionPoint[i] + vect(0, 0, -10), 0, 255, 0);
	}
*/
}

defaultproperties
{
     MaxSway=0.800000
     IdleSway=0.100000
     ParticleCount=45
     ParticleTexture(0)=Texture'RuneFX.chain1'
     NumConPts=15
     BeamThickness=2.500000
     BeamTextureScale=0.040000
     bUseTargetLocation=True
     bNet=False
     Texture=Texture'Engine.S_Rope'
     CollisionRadius=15.000000
     CollisionHeight=500.000000
     bCollideActors=True
}

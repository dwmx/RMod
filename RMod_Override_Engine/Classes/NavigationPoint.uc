//=============================================================================
// NavigationPoint.
//=============================================================================
class NavigationPoint extends Actor
	native;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off Flags=2

#exec Texture Import File=Textures\S_Point.pcx Name=S_Point Mips=Off Flags=2


//------------------------------------------------------------------------------
// NavigationPoint variables
var() name ownerTeam;	//creature clan owning this area (area visible from this point)
var bool taken; //set when a creature is occupying this spot
var int upstreamPaths[16];
var int Paths[16]; //index of reachspecs (used by C++ Navigation code)
var int PrunedPaths[16];
var NavigationPoint VisNoReachPaths[16]; //paths that are visible but not directly reachable
var int visitedWeight;
var actor routeCache;
var const int bestPathWeight;
var const NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;
var const NavigationPoint prevOrdered;
var const NavigationPoint startPath;
var const NavigationPoint previousPath;
var int cost; //added cost to visit this pathnode
var() int ExtraCost;
var() bool bPlayerOnly;	//only players should use this path

var bool bEndPoint; //used by C++ navigation code
var bool bEndPointOnly; //only used as an endpoint in routing network
var bool bSpecialCost;	//if true, navigation code will call SpecialCost function for this navigation point
var() bool bOneWayPath;	//reachspecs from this path only in the direction the path is facing (180 degrees)
var() bool bNeverUseStrafing; // shouldn't use bAdvancedTactics going to this point
var bool bAutoBuilt;	// placed during execution of "PATHS BUILD"
var bool bTwoWay;	// hacked here to fix CTF problems post release (used by Botpack.AlternatePath)
 
native(519) final function describeSpec(int iSpec, out Actor Start, out Actor End, out int ReachFlags, out int Distance, out int Radius, out int Height); 
event int SpecialCost(Pawn Seeker);

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming, actor Source )
{
	// Move the actor here.
	taken = Incoming.SetLocation( Location + vect (0,0,20));
	if (taken)
	{
		Incoming.Velocity = vect(0,0,0);
		Incoming.SetRotation(Rotation);
	}
	// Play teleport-in effect.
	PlayTeleportEffect(Incoming, true);
	return taken;
}

function PlayTeleportEffect(actor Incoming, bool bOut)
{
	Level.Game.PlayTeleportEffect(Incoming, bOut, false);
}

final function int NumPaths()
{
	local int count;

	count = 0;
	while (Paths[count] != -1)
	{
		count++;
	}
	return count;
}

function actor PathEndPoint(int i)
{
	local actor Start,End;
	local int flags, dist;
	local int Radius, Height;
	
	if (Paths[i] == -1)
		return None;
	
	DescribeSpec(Paths[i], Start, End, flags, dist, Radius, Height);
	
	return End;
}

simulated function Debug(canvas Canvas, int mode)
{
	local int i, num,flags,dist,R,G,B,sx,sy;
	local actor Start,End;
	local bool bNear;
	local int Radius, Height;
	local Pawn P;
	local vector work;

	if (ROLE < ROLE_Authority)	// Nav point info unavailable on clients
		return;

	num = NumPaths();

	// Find the player
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer )
			break;

	bNear = (VSize(P.Location - Location) < 500);

	// Show paths
	switch(mode)
	{
		case HUD_ACTOR:			// Normal paths
			for (i=0; i<num; i++)
			{
				if (Paths[i] == -1)
					continue;
				DescribeSpec(Paths[i], Start, End, flags, dist, radius, height);
				if (Start==None || End==None)
					continue;
				DrawSpec(Canvas, Start.Location, End.Location, flags);
				if (bNear)
				{
					if (Radius < 50 || Height < 50)
					{	R = 255;  G = 255;  B =   0;	}
					else
					{	R =   0;  G = 255;  B =   0;	}
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, start.Location, End.Location, "R="$Radius@"H="$Height);
				}
			}
			break;
		case HUD_SKELETON:		// VisNoReach paths
			if (bNear)
			{
				for (i=0; i<num; i++)
				{
					if (VisNoReachPaths[i] != None)
					{
						DrawSpec(Canvas, Location, VisNoReachPaths[i].Location, 1);
					}
				}
			}
			break;
			
		case HUD_SKELNAMES:		// Pruned paths
			if (bNear)
			{
				for (i=0; i<num; i++)
				{
					if (PrunedPaths[i] == -1)
						continue;
					DescribeSpec(PrunedPaths[i], Start, End, flags, dist, radius, height);
					DrawSpec(Canvas, Start.Location, End.Location, flags);
				}
			}
			break;
			
		case HUD_SKELJOINTS:	// Radii/Height Tubes
			if (bNear)
			{
				for (i=0; i<num; i++)
				{
					if (Paths[i] == -1)
						continue;
					DescribeSpec(Paths[i], Start, End, flags, dist, radius, height);
					DrawTube(Canvas, Start.Location, End.Location, Radius, Height);
					if (Radius < 50 || Height < 50)
					{	R = 255;  G = 255;  B =   0;	}
					else
					{	R =   0;  G = 255;  B =   0;	}
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, start.Location, End.Location, "R="$Radius@"H="$Height);
				}
			}
			break;
			
		case HUD_SKELAXES:		// End point info
			if (bEndPoint)
			{
				work.X = Location.X + 5;
				work.Y = Location.Y + 5;
				work.Z = Location.Z + 200;
				Canvas.DrawLine3D(Location, work, 255, 255, 0);
				Canvas.TransformPoint(work, sx, sy);
				Canvas.SetPos(sx,sy);
				Canvas.DrawText("bEndPoint");
			}
			if (bEndPointOnly)
			{
				work.X = Location.X - 5;
				work.Y = Location.Y - 5;
				work.Z = Location.Z + 200;
				Canvas.DrawLine3D(Location, work, 0, 0, 255);
				Canvas.TransformPoint(work, sx, sy);
				Canvas.SetPos(sx,sy);
				Canvas.DrawText("bEndPointOnly");
			}
			for (i=0; i<num; i++)
			{
				if (Paths[i] == -1)
					continue;
				DescribeSpec(Paths[i], Start, End, flags, dist, radius, height);
				DrawSpec(Canvas, Start.Location, End.Location, flags);
			}
			break;
		case HUD_LOD:
			if (bNear)
			{
				if (nextOrdered != None)
				{
					R = 255;  G =   0;  B = 255;
					work = nextOrdered.Location;
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, Location, work, "NextOrdered");
					Canvas.DrawLine3D(Location, work, R, G, B);
				}
	
				if (prevOrdered != None)
				{
					R =   0;  G = 255;  B = 255;
					work = prevOrdered.Location;
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, Location, work, "PrevOrdered");
					Canvas.DrawLine3D(Location, work, R, G, B);
				}
			}
			break;
		case HUD_POV:
			if (bNear)
			{
				if (startPath != None)
				{
					R = 255;  G = 255;  B =   0;
					work = startPath.Location;
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, Location, work, "StartPath");
					Canvas.DrawLine3D(Location, work, R, G, B);
				}
	
				if (previousPath != None)
				{
					R = 255;  G = 255;  B = 255;
					work = previousPath.Location;
					Canvas.SetColor(R,G,B);
					DrawTextOnLine(Canvas, Location, work, "previousPath");
					Canvas.DrawLine3D(Location, work, R, G, B);
				}
			}
			break;
	}		
}

function DrawTextOnLine(canvas Canvas, vector start, vector end, string text)
{
	local int sx,sy;
	Canvas.TransformPoint(Start + ((end-start) * 0.2), sx, sy);
	Canvas.SetOrigin(sx,sy);
	Canvas.SetPos(0, 0);
	Canvas.DrawText(text);
}

function DrawSpec(canvas Canvas, vector start, vector end, int flags)
{
	local int R,G,B;
	R = 0;
	G = 0;
	B = 0;
	if ((flags & 1)>0) R = 255; else R = 0;
	if ((flags & 2)>0) G = 255; else G = 0;
	if ((flags & 4)>0) B = 255; else B = 0;
	Canvas.DrawLine3D(Start, End, R, G, B);
}

function DrawTube(canvas Canvas, vector v1, vector v2, int Radius, int Height)
{
	local vector p1, p2, X, Y, Z, tocorner1, tocorner2, tocorner3, tocorner4;
	local float R,G,B;
	local rotator toend;

	if (Radius < 50 || Height < 50)
	{	R = 255;  G = 255;  B =   0;	}
	else
	{	R =   0;  G = 255;  B =   0;	}

	toend = rotator(v2 - v1);
	GetAxes(toend, X, Y, Z);

	tocorner1 =  Y*Radius + Z*Height;
	tocorner2 =  Y*Radius - Z*Height;
	tocorner3 = -Y*Radius - Z*Height;
	tocorner4 = -Y*Radius + Z*Height;

	// Length of box
	Canvas.DrawLine3D( v1 + tocorner1, v2 + tocorner1, R, G, B);
	Canvas.DrawLine3D( v1 + tocorner2, v2 + tocorner2, R, G, B);
	Canvas.DrawLine3D( v1 + tocorner3, v2 + tocorner3, R, G, B);
	Canvas.DrawLine3D( v1 + tocorner4, v2 + tocorner4, R, G, B);

	// End cap 1
	Canvas.DrawLine3D( v1+tocorner1, v1+tocorner2, R, G, B);
	Canvas.DrawLine3D( v1+tocorner2, v1+tocorner3, R, G, B);
	Canvas.DrawLine3D( v1+tocorner3, v1+tocorner4, R, G, B);
	Canvas.DrawLine3D( v1+tocorner4, v1+tocorner1, R, G, B);

	// End cap 2
	Canvas.DrawLine3D( v2+tocorner1, v2+tocorner2, R, G, B);
	Canvas.DrawLine3D( v2+tocorner2, v2+tocorner3, R, G, B);
	Canvas.DrawLine3D( v2+tocorner3, v2+tocorner4, R, G, B);
	Canvas.DrawLine3D( v2+tocorner4, v2+tocorner1, R, G, B);
}

defaultproperties
{
     upstreamPaths(0)=-1
     upstreamPaths(1)=-1
     upstreamPaths(2)=-1
     upstreamPaths(3)=-1
     upstreamPaths(4)=-1
     upstreamPaths(5)=-1
     upstreamPaths(6)=-1
     upstreamPaths(7)=-1
     upstreamPaths(8)=-1
     upstreamPaths(9)=-1
     upstreamPaths(10)=-1
     upstreamPaths(11)=-1
     upstreamPaths(12)=-1
     upstreamPaths(13)=-1
     upstreamPaths(14)=-1
     upstreamPaths(15)=-1
     Paths(0)=-1
     Paths(1)=-1
     Paths(2)=-1
     Paths(3)=-1
     Paths(4)=-1
     Paths(5)=-1
     Paths(6)=-1
     Paths(7)=-1
     Paths(8)=-1
     Paths(9)=-1
     Paths(10)=-1
     Paths(11)=-1
     Paths(12)=-1
     Paths(13)=-1
     Paths(14)=-1
     Paths(15)=-1
     PrunedPaths(0)=-1
     PrunedPaths(1)=-1
     PrunedPaths(2)=-1
     PrunedPaths(3)=-1
     PrunedPaths(4)=-1
     PrunedPaths(5)=-1
     PrunedPaths(6)=-1
     PrunedPaths(7)=-1
     PrunedPaths(8)=-1
     PrunedPaths(9)=-1
     PrunedPaths(10)=-1
     PrunedPaths(11)=-1
     PrunedPaths(12)=-1
     PrunedPaths(13)=-1
     PrunedPaths(14)=-1
     PrunedPaths(15)=-1
     bStatic=True
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=23.000000
     CollisionHeight=25.000000
}

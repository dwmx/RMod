//=============================================================================
// MudBubble.
//=============================================================================
class MudBubble expands Effects;

var() float		DelayMin;
var() float		DelayMax;
var() float		ScaleMin;
var() float		ScaleMax;
var() byte		BubbleRadius;

var bool		bBubbleActive;
var vector		BaseLocation;
var float		RandPosSize;

// FUNCTIONS ------------------------------------------------------------------

//=============================================================================
//
// BeginPlay
//
//=============================================================================

function BeginPlay()
{
	Super.BeginPlay();

	bHidden = true;
	bBubbleActive = false;
	BaseLocation = Location;
	BaseLocation.x -= BubbleRadius;
	BaseLocation.y -= BubbleRadius;
	RandPosSize = float(BubbleRadius) * 2;
}

//=============================================================================
//
// Trigger
//
//=============================================================================

function Trigger(actor Other, pawn EventInstigator)
{
	if(bBubbleActive)
	{ // Turn the bubble off... it will set itself into a NULL state after the next burst
		bBubbleActive = false;
	}		
	else
	{
		bBubbleActive = true;
		GotoState('Bubbling');
	}
}

//=============================================================================
//
// Burst
//
//=============================================================================

function Burst()
{
	local int i, globCount;
	local MudGlob glob;
	local actor a;

	Spawn(class'MudRipple');
	Spawn(class'SteamBlast',,, Location+Vect(0, 0, 8));

//	PlaySound(Sound'EnvironmentalSnd.Mud.MudBurst',, 0.2+FRand()*0.2,,
//		1024, 0.8+FRand()*0.4);

	a = Spawn(class'MudSplat');
	if(a != None)
	{
		a.DrawScale = 0.4;
		a.SetRotation(Rotator(Vect(0, 0, 1)));
	}

	globCount = 1+Rand(3);
	for(i = 0; i < globCount; i++)
	{
		if(FRand() < 0.5)
			glob = Spawn(class'MudGlob');
		else
			glob = Spawn(class'MudGlob2');
		if(glob == None)
			continue;
		glob.Velocity = VRand()*65;
		glob.Velocity.Z = 90+FRand()*90;
		glob.MudZ = Location.Z;
	}
}

//=============================================================================
//
// BubbleDelay
//
//=============================================================================

function float BubbleDelay()
{
	return FMin(DelayMin, DelayMax)+Abs(DelayMax-DelayMin)*FRand();
}

//=============================================================================
//
// SetNewLocation
//
//=============================================================================

function SetNewLocation()
{
	local vector v;

	if(BubbleRadius > 0)
	{
		v = VRand()*RandPosSize;
		v.z = 0;
		SetLocation(BaseLocation+v);
	}
}

// STATES ---------------------------------------------------------------------

state Bubbling
{
	event Tick(float deltaTime)
	{
		if(DrawScale < ScaleMax)
			DrawScale += 0.8 * deltaTime;
	}

begin:
	Sleep(BubbleDelay() * 0.5);
	while(bBubbleActive)
	{
		DrawScale = ScaleMin;
		SetNewLocation();
		bHidden = false;
		PlayAnim('bubble',, 0);
		FinishAnim();
		bHidden = true;
		Burst();
		Sleep(BubbleDelay());
	}
	GotoState('');
}

defaultproperties
{
     DelayMin=2.000000
     DelayMax=8.000000
     ScaleMin=0.100000
     ScaleMax=2.500000
     DrawType=DT_SkeletalMesh
     LODCurve=LOD_CURVE_NONE
     bShadowCast=False
     Skeletal=SkelModel'objects.MudBubble'
}

//=============================================================================
// Movie.
//=============================================================================
class Movie extends Cinematography;

var() SkelModel CameraMesh;
var() SkelModel PerformerMeshes[10];
var() int SceneNumber;
var() name SceneName;
var bool bMovieActive;
var Performer PerfHead; // The head of the list is the camera performer
var Performer CameraDummy;
var float MovieTime;
var PlayerPawn MovieInstigator;

// Make loop-able or not
// Make interactive or not
// Make fade in / fade out mode for camera transition (from Ragnar)
// Make smooth camera move from Ragnar to camera position

var bool bLoopMovie;
var bool bInteractiveMovie;


function BeginPlay()
{
	bMovieActive = FALSE;
	Disable( 'Tick' );
}

function trigger( Actor other, Pawn EventInstigator )
{
	local int i;
	local Performer perf;
	local Performer lastPerf;
	local int perfCount;

	if( bMovieActive )
	{
		return;
	}

	if( EventInstigator.bIsPlayer == False )
	{
		return;
	}
	MovieInstigator = PlayerPawn( EventInstigator );

	// Spawn the camera performer
	if( CameraMesh == None )
	{
		return;
	}
	perf = Spawn( class 'Performer' );
	if( perf == None )
	{
		return;
	}
	PerfHead = perf;
	PerfHead.Skeletal = CameraMesh;
	PerfHead.SkelGroupFlags[0] = 1;
	PerfHead.LoopAnim( SceneName, 2.0 );
	lastPerf = PerfHead;

	perfCount = 0;
	for( i = 0; i < 10; i++ )
	{
		if( PerformerMeshes[i] == None )
		{ // Empty slot
			continue;
		}
		// Spawn a performer
		perf = Spawn( class 'Performer' );
		if( perf != None )
		{
			// Initialize performer mesh and animation
			perf.Skeletal = PerformerMeshes[i];
			perf.LoopAnim( SceneName, 2.0 );

			// Add to linked list
			lastPerf.Next = perf;
			lastPerf = perf;
			perfCount++;
		}
	}
	if( lastPerf == PerfHead )
	{ // Nothing to watch
		PerfHead.Destroy();
		return;
	}

	// Terminate linked list
	lastPerf.Next = None;

	// Create the dummy camera actor
	CameraDummy = Spawn( class 'Performer' );
	if( CameraDummy == None )
	{
		TerminateMovie();
		return;
	}
	CameraDummy.bHidden = True;
	CameraDummy.SetPhysics( PHYS_None );
	MovieInstigator.ViewTarget = CameraDummy;

	// Disable the player
	//MovieInstigator.SetPhysics( PHYS_None );

	bMovieActive = true;
	MovieTime = 0.0;
	Enable( 'Tick' );
}

function Tick( float DeltaTime )
{
	local vector camPos;
	local rotator camRot;
	local vector offset;
	local vector X,Y,Z,X2,Y2,Z2;
	local vector jointpos;
	local rotator jointrot;
	local int i;
	local rotator pitchandyaw, wholedeal;
	local vector lookat;
	local float cosroll;

	local vector camFocus;
	local vector camDir;

	if( !bMovieActive )
	{
		return;
	}
	MovieTime += DeltaTime;

	offset = Location - PerfHead.Location;
	camPos = PerfHead.GetJointPos( 1 );
	camPos += offset;
	CameraDummy.SetLocation( camPos );
	PerfHead.SetLocation( camPos );

	camRot = PerfHead.GetJointRot( 1 );

	// Hack for X oriented camera
	GetAxes(camRot,X,Y,Z);
	lookat = -Y;
	pitchandyaw = rotator(lookat);
	GetAxes(pitchandyaw, X2,Y2,Z2);
	cosroll = X dot Y2;
	wholedeal = pitchandyaw;
	wholedeal.Roll = cosroll;	//TODO: Make Acos() intrinsic to deal with this

	CameraDummy.SetRotation( wholedeal );

	//camFocus = Location;
	//camDir = camFocus - camPos;
	//camRot = Rotator( camDir );
	//slog( "rot=" $ camRot );
	//CameraDummy.SetRotation( camRot );

	//CameraDummy.SetRotation( MovieInstigator.Rotation );

	if( MovieTime > 20 )
	{
		TerminateMovie();
	}
}

simulated function Debug(canvas Canvas, int mode)
{
	local rotator camrot;
	local vector campos,X,Y,Z;
	
	camPos = PerfHead.GetJointPos( 1 );
	camRot = PerfHead.GetJointRot( 1 );
	GetAxes(camrot,X,Y,Z);
	Y *= -1000;
	
	Canvas.DrawLine3D(campos, campos+Y, 10, 0, 0);
}


function TerminateMovie()
{
	local Performer perf;
	local Performer perfNext;

	// Return camera to player
	MovieInstigator.ViewTarget = None;

	// Destroy performers and dummy camera actor
	perf = PerfHead;
	while( perf != None )
	{
		perfNext = perf.Next;
		perf.Destroy();
		perf = perfNext;
	}	
	if( CameraDummy != None )
	{
		CameraDummy.Destroy();
	}

	// Stop Movie activity
	Disable( 'Tick' );
	bMovieActive = False;

	// Enable the player
}

defaultproperties
{
     bHidden=True
}

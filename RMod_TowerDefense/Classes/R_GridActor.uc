//==============================================================================
//	R_GridActor
//	This class is used to represent the appearance of a grid, usually shown
//	when the player is attempting to place a buildable actor via builderbrush
//
//	BuilderBrush is responsible for performing the logic necessary to see what
//	grid cells can and cannot be built on, and it updates this class to reflect
//	that appearance
//==============================================================================
class R_GridActor extends ParticleSystem;

const CanvasLibrary = Class'RBase.R_ACanvasLibrary';
const GridLibrary = Class'RMod_TowerDefense.R_AGridLibrary';

var int ActiveCellsX;			// The number of cells on the X axis this is looking for
var int ActiveCellsY; 			// The number of cells on the Y axis this is looking for
var Vector EmphasisLocation; 	// Where the 'desired' location is (mouse cursor world hit)
var Vector ConstrainedLocation; // Where the grid-snapped location is

var int TestRows;
var int TestCols;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Log(Self @ "spawned");

	TestRows = 1;
	TestCols = 1;
}

event SystemInit()
{
}

event Tick(float DeltaSeconds)
{
	local Vector ParticleLocation;
	local int i;
	local Vector ParticleAlpha;
	local float AlphaLerp;

	SetLocation(Owner.Location);

	for(i = 0; i < ParticleCount; ++i)
	{
		ParticleLocation = Location + Vect(1,0,0) * 64.0 * i;

		// Note: A more dramatic fall-off would look much better for this
		// Calculate particle alpha -- alpha falls off as the particle location gets farther away from the emphasis location
		// Calc [0.0, 1.0] particle alpha interpolant
		AlphaLerp = VSize(ParticleLocation - EmphasisLocation);
		AlphaLerp = FClamp((AlphaLerp / 512.0), 0.0, 1.0);
		AlphaLerp = 1.0 - AlphaLerp;
		// Quadratic falloff
		//AlphaLerp = Class'R_AUtilities'.Static.InterpQuadratic(AlphaLerp, 0.0, 1.0, 1.0);
		AlphaLerp = Smerp(AlphaLerp, 0.0, 1.0);
		ParticleAlpha = Vect(1,1,1) * AlphaLerp;

		ParticleArray[i].Valid = true;

		//ParticleArray[i].Alpha = ((Sin(Level.TimeSeconds) + 1) / 2) * Vect(1, 1, 1);//Vect(255,255,255);
		ParticleArray[i].Alpha = ParticleAlpha;

		ParticleArray[i].Points[0] = ParticleLocation + Vect(0,0,0);
		ParticleArray[i].Points[1] = ParticleLocation + Vect(1,0,0) * 64.0;
		ParticleArray[i].Points[2] = ParticleLocation + Vect(1,1,0) * 64.0;
		ParticleArray[i].Points[3] = ParticleLocation + Vect(0,1,0) * 64.0;

		//ParticleArray[i].Location = Location + Vect(1,0,0) * 64.0 * i;
		//Log(Location);

		ParticleArray[i].U0 = 0.01;
		ParticleArray[i].V0 = 0.01;
		ParticleArray[i].U1 = 0.99;
		ParticleArray[i].V1 = 0.99;
	}
}

function GridActorPostRender(Canvas C)
{
	DrawGridActorDebug(C);
}

/**
*	DrawGridActorDebug
*	Draws the following information:
*	- Actual world grid: World grid drawn (grey)
*	- An area being tested for grid snapping and what its snapping to (green)
*	- Nearest grid point snapping location (red)
*	- Emphasis point: Basically the mouse cursor, (yellow)
*/
function DrawGridActorDebug(Canvas C)
{
	local int TestGridCellSize;
	local int TestAreaX, TestAreaY;
	local Vector DrawLocation;
	
	TestGridCellSize = 64;
	TestAreaX = TestRows;
	TestAreaY = TestCols;

	// Draw the actual world grid
	DrawLocation = EmphasisLocation;
	GridLibrary.Static.DrawGridLines(
		C, TestGridCellSize, DrawLocation,
		100, 100, Vect(0.5,0.5,0.0),
		0.35, 0.35, 0.35);

	// Draw the area we are testing
	DrawLocation = EmphasisLocation + Vect(0,0,1) * 2.0; // no z fighting
	GridLibrary.Static.DrawAreaSnappedToGrid(
		C, TestGridCellSize, DrawLocation,
		TestAreaX, TestAreaY,
		0.0, 1.0, 0.0);

	// Draw where the point is snapping
	DrawLocation = EmphasisLocation + Vect(0,0,1) * 2.0;
	GridLibrary.Static.DrawLocationSnappedToGrid(
		C, TestGridCellSize, DrawLocation,
		1.0, 0.0, 0.0);
	
	// Draw emphasis location - where the cursor is hitting in world space
	CanvasLibrary.Static.DrawCircle3D(
		C, EmphasisLocation, Vect(0,0,1), 8.0, 16, 1.0, 1.0, 0.0);
	CanvasLibrary.Static.DrawRay3D(
		C, EmphasisLocation, Vect(0,0,1), 48.0, 1.0, 1.0, 0.0);
}

defaultproperties
{
    RemoteRole=ROLE_None
    ParticleCount=0
    ParticleType=PART_Generic
    ParticleSpriteType=PSPRITE_QuadUV
    AlphaStart=255
    AlphaEnd=255
    Style=STY_Translucent
    ParticleTexture(0)=Texture'RuneI.sb_horizramp'
	ParticleTexture(1)=Texture'RuneFX.swipe_blue'
}
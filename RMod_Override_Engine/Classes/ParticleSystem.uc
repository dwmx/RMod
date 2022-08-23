//=============================================================================
// ParticleSystem.
//=============================================================================
class ParticleSystem expands Actor
	intrinsic;

#exec Texture Import File=Textures\ParticleSystem.pcx Name=S_Particle Mips=Off Flags=2
#exec Texture Import File=Textures\RopeSymbol.pcx Name=S_Rope Mips=Off Flags=2

/* TODO:
		- Reorganize vars into a more logical structure
			* Group BOOLS
			* Group Specific system vars
*/	

const MAX_PARTICLE_COUNT = 64;

var transient bool IsLoaded;
var() bool bSpriteInEditor;			// Whether to draw as sprite within editor

enum EParticleType
{
	PART_Emitter,
	PART_SwipeEffect,
	PART_Generic,
	PART_Beam,
};

enum EParticleSpriteType
{
	PSPRITE_Normal,
	PSPRITE_Vertical,
	PSPRITE_Flat,
	PSPRITE_QuadUV,
};

enum EParticleSpawnShape
{
	PSHAPE_Ellipsoid,  // Ellipsoid defined by ShapeVector
	PSHAPE_Line, // Line defined by the vector ShapeVector
};

// Basic Particle Definition -- MUST be mirrored in UnObj.h
// TODO:  Majorly optimize this structure!
struct Particle
{
	var vector Location;
	var vector Velocity;
	var FLOAT LifeSpan;
	var FLOAT XScale;
	var FLOAT YScale;
	var FLOAT ScaleStartX;
	var FLOAT ScaleStartY;
	var vector Alpha;		// Use a byte (or a float?)
	var FLOAT U0, V0;		// WeaponSwipe
	var FLOAT U1, V1;
	var vector Points[4];
	var BYTE Style;
	var BYTE TextureIndex;
	var BOOL Valid;
};

// System Variables
var() bool bSystemOneShot;
var() bool bSystemTicks;  // If true, the system ticks based upon the level tick, NOT based upon rendering
var() bool bRelativeToSystem;
var() bool bEventDeath;

var() byte ParticleCount;
var() Texture ParticleTexture[4];
var() bool bRandomTexture;
var() EParticleType ParticleType;
var() EParticleSpriteType ParticleSpriteType;
var() EParticleSpawnShape SpawnShape;
var() float RandomDelay;

var() float SystemLifeSpan;

// Internal System Variables
var float CurrentDelay;
var byte OldParticleCount;
var coords SystemCoords;
var bool HasValidCoords;
var float LastTime;
var float CurrentTime;
var Particle ParticleArray[64]; // MAX_PARTICLE_COUNT

// Emitter Variables
var() vector OriginOffset; // Spawn particles offset from the origin by this vector
var() vector ShapeVector; // Defines the volume that the particles are spawned
var() vector VelocityMin;
var() vector VelocityMax;
var() float ScaleMin;
var() float ScaleMax;
var() float ScaleDeltaX;
var() float ScaleDeltaY;
var() float LifeSpanMin;
var() float LifeSpanMax;
var() byte AlphaStart;
var() byte AlphaEnd;
var() byte PercentOffset;

var() bool bAlphaFade;
var() bool bApplyGravity;
var() float GravityScale;
var() bool bApplyZoneVelocity;
var() float ZoneVelocityScale;
var() bool bWaterOnly;
var() bool bOneShot;
var() bool bConvergeX;
var() bool bConvergeY;
var() bool bConvergeZ;
var() bool bConstrainToBounds;

var() float SpawnDelay; // Delay before particles begin to spawn
var() float SpawnOverTime;
var() float TextureChangeTime; // TEST

// Swipe Variables
var byte BaseJointIndex;
var byte OffsetJointIndex;
var vector OldBaseLocation;
var vector OldOffsetLocation;
var() float SwipeSpeed;	// Speed at which the swipe fades out

// Beam Variables
var() byte NumConPts; // Number of connection points in the beam
var() float BeamThickness;
var() float BeamTextureScale; // If Non-zero, uses this value to maintain the beam texture coordinates
var() int TargetJointIndex;
var vector ConnectionPoint[32]; // Beam connection points -- NO MORE THAN 32 connection pts!
var vector ConnectionOffset[32]; // Beam connection points -- NO MORE THAN 32 connection pts!
var() bool bUseTargetLocation;
var() vector TargetLocation;
var() bool bEventSystemInit;
var() bool bEventSystemTick;
var() bool bEventParticleTick;
var() bool bTaperStartPoint;
var() bool bTaperEndPoint;


replication
{
	unreliable if( Role==ROLE_Authority )
		bSystemTicks, bRelativeToSystem, bEventDeath,
		ParticleType, ParticleSpriteType, SpawnShape,
		bEventSystemInit, bEventSystemTick, bEventParticleTick,
		ParticleCount, ParticleTexture, bRandomTexture,
		RandomDelay, SystemLifeSpan,
		OriginOffset, ShapeVector, VelocityMin, VelocityMax,
		ScaleMin, ScaleMax, ScaleDeltaX, ScaleDeltaY,
		LifeSpanMin, LifeSpanMax, AlphaStart, AlphaEnd,
		PercentOffset, bAlphaFade, bApplyGravity, GravityScale,
		bApplyZoneVelocity, ZoneVelocityScale, bWaterOnly,
		bSystemOneShot, bOneShot,
		bConvergeX, bConvergeY, bConvergeZ,
		bConstrainToBounds,
		SpawnDelay, SpawnOverTime, TextureChangeTime;

		// Swipes
	unreliable if (Role==ROLE_Authority && ParticleType==PART_SwipeEffect)
		BaseJointIndex, OffsetJointIndex,
		OldBaseLocation, OldOffsetLocation,
		SwipeSpeed;

		// Beam
	unreliable if (Role==ROLE_Authority && ParticleType==PART_Beam)
		NumConPts, BeamThickness, BeamTextureScale,
		TargetJointIndex, ConnectionPoint, ConnectionOffset,
		bUseTargetLocation, TargetLocation,
		bTaperStartPoint, bTaperEndPoint;
}


event SystemInit()
{
}

event SystemTick(float DeltaSeconds)
{
}

event ParticleTick(float DeltaSeconds)
{ // ParticleTick ticks ALL particles in a given ParticleSystem
}


simulated function debug(canvas Canvas, int mode)
{
	Super.Debug(Canvas, mode);

	Canvas.DrawText("ParticleSystem:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  IsLoaded:      "$IsLoaded);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ParticleCount: "$ParticleCount);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bStasis:      "$bStasis);
	Canvas.CurY -= 8;

	switch(ParticleType)
	{
	case PART_Emitter:
		Canvas.DrawText("  ParticleType:    "@"PART_Emitter");
		Canvas.CurY -= 8;
		break;
	case PART_Generic:
		Canvas.DrawText("  ParticleType:    "@"PART_Emitter");
		Canvas.CurY -= 8;
		break;
	case PART_SwipeEffect:
		Canvas.DrawText("  ParticleType:    "@"PART_SwipeEffect");
		Canvas.CurY -= 8;
		Canvas.DrawText("  BaseJointIndex:  "@BaseJointIndex);
		Canvas.CurY -= 8;
		Canvas.DrawText("  OffsetJointIndex:"@OffsetJointIndex);
		Canvas.CurY -= 8;
		Canvas.DrawText("  OldBaseLocation: "@OldBaseLocation);
		Canvas.CurY -= 8;
		Canvas.DrawText("  OldOffsetLocation"@OldOffsetLocation);
		Canvas.CurY -= 8;
		Canvas.DrawText("  SwipeSpeed:      "@SwipeSpeed);
		Canvas.CurY -= 8;
		break;
	case PART_Beam:
		Canvas.DrawText("  ParticleType:    "@"PART_Beam");
		Canvas.CurY -= 8;
		Canvas.DrawText("  NumConPts:       "@NumConPts);
		Canvas.CurY -= 8;
		Canvas.DrawText("  TargetJointIndex:"@TargetJointIndex);
		Canvas.CurY -= 8;
		Canvas.DrawText("  bUseTargetLocation:"@bUseTargetLocation);
		Canvas.CurY -= 8;
		Canvas.DrawText("  TargetLocation:    "@TargetLocation);
		Canvas.CurY -= 8;
		break;
	}
}

defaultproperties
{
     bStasis=True
     DrawType=DT_ParticleSystem
     Texture=Texture'Engine.S_Particle'
}

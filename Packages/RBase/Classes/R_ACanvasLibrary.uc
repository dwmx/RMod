//==============================================================================
//  R_ACanvasLibrary
//  Library class
//
//  Provides various utility functions for the Canvas class.
//
//  Note that the Canvas object which is passed to an owning player's PlayerPawn
//  during the PostRender event is ONLY valid during PostRender, and the
//  instantiated canvas class cannot be modified.
//==============================================================================
class R_ACanvasLibrary extends R_ALibrary abstract;

const WhiteTexture = Texture'UWindow.WhiteTexture';

//==============================================================================
// Screen space functions
//==============================================================================

/**
*   ConstrainExtentsInPlace
*   Given two extents in any order, this function will clamp them to the
*   current Canvas region and output as Min and Max
*/
static function ConstrainExtentsInPlace(
    Canvas C,
    out Vector MinimumExtent, out Vector MaximumExtent)
{
    local Vector TempVector;
    
    MinimumExtent.X = FClamp(MinimumExtent.X, 0.0, C.CLipX);
    MinimumExtent.Y = FClamp(MinimumExtent.Y, 0.0, C.ClipY);
    MinimumExtent.Z = 0.0;
    
    MaximumExtent.X = FClamp(MaximumExtent.X, 0.0, C.CLipX);
    MaximumExtent.Y = FClamp(MaximumExtent.Y, 0.0, C.ClipY);
    MaximumExtent.Z = 0.0;
    
    TempVector.X = FMin(MinimumExtent.X, MaximumExtent.X);
    TempVector.Y = FMin(MinimumExtent.Y, MaximumExtent.Y);
    TempVector.Z = 0.0;
    
    MaximumExtent.X = FMax(MinimumExtent.X, MaximumExtent.X);
    MaximumExtent.Y = FMax(MinimumExtent.Y, MaximumExtent.Y);
    MinimumExtent = TempVector;
}

/**
*   DrawBoxOutline
*   Draws a box with the specified thickness and color on the screen
*   Extents mark the opposite corners of the box in pixels, in range [0,C.Clip] (Z ignored)
*   RGBA colors should be in range [0,1]
*/
static function DrawBoxOutline(
    Canvas C,
    Vector Extent1, Vector Extent2,
    float Thickness,
    float R, float G, float B, float A)
{
    local float MinX, MinY, MaxX, MaxY;
    
    ConstrainExtentsInPlace(C, Extent1, Extent2);
    
    MinX = FMin(Extent1.X, Extent2.X);
    MaxX = FMax(Extent1.X, Extent2.X);
    MinY = FMin(Extent1.Y, Extent2.Y);
    MaxY = FMax(Extent1.Y, Extent2.Y);
    
    R = FClamp(R, 0.0, 1.0);
    G = FClamp(G, 0.0, 1.0);
    B = FClamp(B, 0.0, 1.0);
    A = FClamp(A, 0.0, 1.0);
    
    C.Style = 5; // STY_AlphaBlend
    C.AlphaScale = A;
    C.SetColor(R * 255.0, G * 255.0, B * 255.0);
    
    // Bottom edge
    C.SetPos(MinX, MinY);
    C.DrawRect(WhiteTexture, MaxX - MinX, Thickness);
    
    // Right edge
    C.SetPos(MaxX, MinY);
    C.DrawRect(WhiteTexture, Thickness, MaxY - MinY);
    
    // Top edge
    C.SetPos(MinX, MaxY);
    C.DrawRect(WhiteTexture, MaxX - MinX, Thickness);
    
    // Left edge
    C.SetPos(MinX, MinY);
    C.DrawRect(WhiteTexture, Thickness, MaxY - MinY);
}

/**
*   DrawBoxSolid
*   Draws a box with the specified extents and color on the screen
*   Extents mark the opposite corners of the box in pixels, in range [0,C.Clip] (Z ignored)
*   RGBA colors should be in range [0,1]
*/
static function DrawBoxSolid(
    Canvas C,
    Vector Extent1, Vector Extent2,
    float R, float G, float B, float A)
{
    ConstrainExtentsInPlace(C, Extent1, Extent2);
    
    R = FClamp(R, 0.0, 1.0);
    G = FClamp(G, 0.0, 1.0);
    B = FClamp(B, 0.0, 1.0);
    A = FClamp(A, 0.0, 1.0);
    
    C.Style = 5; // STY_AlphaBlend
    C.AlphaScale = A;
    C.SetColor(R * 255.0, G * 255.0, B * 255.0);
    
    // Solid rect
    C.SetPos(Extent1.X, Extent1.Y);
    C.DrawRect(WhiteTexture, Extent2.X - Extent1.X, Extent2.Y - Extent1.Y);
}

/**
*   GetScreenSpaceBoundingBoxForActor
*   Given an actor, returns a screen-space AABB based on the actor's
*   collision radius and collision height
*/
static function GetScreenSpaceBoundingBoxForActor(
    Canvas C,
    Actor InActor, Rotator ViewRotation,
    out Vector Extent1, out Vector Extent2)
{
    local Vector ViewX, ViewY, ViewZ;
    local Vector WorldUp;
    local Vector WorldLeft, WorldRight, WorldTop, WorldBottom;
    local int ScreenLeftX, ScreenLeftY;
    local int ScreenRightX, ScreenRightY;
    local int ScreenTopX, ScreenTopY;
    local int ScreenBottomX, ScreenBottomY;
    
    GetAxes(ViewRotation, ViewX, ViewY, ViewZ);
    WorldUp.X = 0.0;
    WorldUp.Y = 0.0;
    WorldUp.Z = 1.0;
    
    WorldLeft = InActor.Location + (ViewY * InActor.CollisionRadius);
    WorldRight = InActor.Location + (ViewY * InActor.CollisionRadius * -1.0);
    WorldTop = InActor.Location + (WorldUp * InActor.CollisionHeight);
    WorldBottom = InActor.Location + (WorldUp * InActor.CollisionHeight * -1.0);
    
    C.TransformPoint(WorldLeft, ScreenLeftX, ScreenLeftY);
    C.TransformPoint(WorldRight, ScreenRightX, ScreenRightY);
    C.TransformPoint(WorldTop, ScreenTopX, ScreenTopY);
    C.TransformPoint(WorldBottom, ScreenBottomX, ScreenBottomY);
    
    Extent1.X = FMin(float(ScreenLeftX), FMin(float(ScreenRightX), FMin(ScreenTopX, ScreenBottomX)));
    Extent1.Y = FMin(float(ScreenLeftY), FMin(float(ScreenRightY), FMin(ScreenTopY, ScreenBottomY)));
    Extent2.X = FMax(float(ScreenLeftX), FMax(float(ScreenRightX), FMax(ScreenTopX, ScreenBottomX)));
    Extent2.Y = FMax(float(ScreenLeftY), FMax(float(ScreenRightY), FMax(ScreenTopY, ScreenBottomY)));
}

//==============================================================================
// World space functions
//==============================================================================

static function DrawRay3D(
	Canvas C,
	Vector WorldOrigin, Vector Direction, float Length,
	float R, float G, float B)
{
	local Vector LineStart, LineStop;

	Direction = Normal(Direction);
	LineStart = WorldOrigin;
	LineStop = WorldOrigin + Direction * Length;

	C.DrawLine3D(LineStart, LineStop, R, G, B);
}

/**
*   DrawCircle3D
*   Draws a circle at the specified world coordinates
*/
static function DrawCircle3D(
    Canvas C,
    Vector WorldOrigin, Vector Normal,
    float Radius, int NumSegments,
    float R, float G, float B)
{
    //C.DrawLine3D(WorldOrigin, WorldOrigin + Normal * 256.0, R, G, B);
    local float RadPerSegment;
    local int i;
    local Vector SegmentStart, SegmentEnd;
    
    RadPerSegment = (2.0 * Pi) / NumSegments;
    
    for(i = 0; i < NumSegments - 1; ++i)
    {
        SegmentStart.X = Cos(i * RadPerSegment) * Radius;
        SegmentStart.Y = Sin(I * RadPerSegment) * Radius;
        SegmentStart.Z = 0.0;
        
        SegmentEnd.X = Cos((i + 1) * RadPerSegment) * Radius;
        SegmentEnd.Y = Sin((i + 1) * RadPerSegment) * Radius;
        SegmentEnd.Z = 0.0;
        
        C.DrawLine3D(WorldOrigin + SegmentStart, WorldOrigin + SegmentEnd, R, G, B);
    }
}

/**
*	DrawSphere3D
*	Draws a sphere at the specified world coordinates
*/
static function DrawSphere3D(
	Canvas C,
	Vector WorldOrigin, float Radius,
	int NumSegments, int NumSlices,
	float R, float G, float B)
{
	local float Theta0, Theta1;
	local float Phi0, Phi1;
	local Vector P0, P1, P2;
	local int i, j;

	Radius = FMax(4.0, Radius);
	NumSegments = Clamp(NumSegments, 3, 24);
	NumSlices = Clamp(NumSlices, 3, 24);

	for(i = 0; i < NumSegments; ++i)
	{
		Theta0 = Pi * float(i) / float(NumSegments) - Pi * 0.5;
		Theta1 = Pi * float(i+1) / float(NumSegments) - Pi * 0.5;

		for(j = 0; j < NumSlices; ++j)
		{
			Phi0 = 2.0 * Pi * float(j) / float(NumSlices);
			Phi1 = 2.0 * Pi * float(j+1) / float(NumSlices);

			P0.X = Cos(Theta0) * Cos(Phi0);
			P0.Y = Cos(Theta0) * Sin(Phi0);
			P0.Z = Sin(Theta0);

			P1.X = Cos(Theta1) * Cos(Phi0);
			P1.Y = Cos(Theta1) * Sin(Phi0);
			P1.Z = Sin(Theta1);

			P2.X = Cos(Theta0) * Cos(Phi1);
			P2.Y = Cos(Theta0) * Sin(Phi1);
			P2.Z = Sin(Theta0);

			P0 = WorldOrigin + P0 * Radius;
			P1 = WorldOrigin + P1 * Radius;
			P2 = WorldOrigin + P2 * Radius;

			// vertical line
			C.DrawLine3D(P0, P1, R, G, B);

			// horizontal ring line
			C.DrawLine3D(P0, P2, R, G, B);
		}
	}
}

/**
*	DrawSquareAxisAligned3D
*	Draws a square aligned with the world X and Y axes
*/
static function DrawSquareAxisAligned3D(
	Canvas C,
	Vector WorldOrigin, Vector Alignment, float SideLength,
	float R, float G, float B)
{
	local Vector LineStart;
	local Vector LineEnd;

	Alignment.X = FClamp(Alignment.X, 0.0, 1.0);
	Alignment.Y = FClamp(Alignment.Y, 0.0, 1.0);

	LineStart = WorldOrigin;
	LineStart -= Vect(1,0,0) * Alignment.X * SideLength;
	LineStart -= Vect(0,1,0) * Alignment.Y * SideLength;

	LineEnd = LineStart + Vect(1,0,0) * SideLength;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineEnd = LineStart + Vect(0,1,0) * SideLength;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineStart = WorldOrigin;
	LineStart += Vect(1,0,0) * (1.0 - Alignment.X) * SideLength;
	LineStart += Vect(0,1,0) * (1.0 - Alignment.Y) * SideLength;

	LineEnd = LineStart + Vect(-1,0,0) * SideLength;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineEnd = LineStart + Vect(0,-1,0) * SideLength;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);
}

/**
*	DrawRectAxisAligned3D
*	Draws a rectangle aligned with the world X and Y axes
*/
static function DrawRectAxisAligned3D(
	Canvas C,
	Vector WorldOrigin, Vector Alignment, float SideLengthX, float SideLengthY,
	float R, float G, float B)
{
	local Vector LineStart;
	local Vector LineEnd;

	Alignment.X = FClamp(Alignment.X, 0.0, 1.0);
	Alignment.Y = FClamp(Alignment.Y, 0.0, 1.0);

	LineStart = WorldOrigin;
	LineStart -= Vect(1,0,0) * Alignment.X * SideLengthX;
	LineStart -= Vect(0,1,0) * Alignment.Y * SideLengthY;

	LineEnd = LineStart + Vect(1,0,0) * SideLengthX;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineEnd = LineStart + Vect(0,1,0) * SideLengthY;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineStart = WorldOrigin;
	LineStart += Vect(1,0,0) * (1.0 - Alignment.X) * SideLengthX;
	LineStart += Vect(0,1,0) * (1.0 - Alignment.Y) * SideLengthY;

	LineEnd = LineStart + Vect(-1,0,0) * SideLengthX;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);

	LineEnd = LineStart + Vect(0,-1,0) * SideLengthY;
	C.DrawLine3D(LineStart, LineEnd, R, G, B);
}

static function DrawCylinderAxisAligned3D(
	Canvas C,
	Vector WorldOrigin, Vector Alignment, float Radius, float Height, int NumSegments,
	float R, float G, float B)
{
	local float RadPerSegment;
	local int i, j;
	local Vector SegmentStart, SegmentEnd;

	RadPerSegment = (2.0 * Pi) / NumSegments;
	Alignment.X = FClamp(Alignment.X, -1.0, 1.0);
	Alignment.Y = FClamp(Alignment.Y, -1.0, 1.0);
	Alignment.Z = FClamp(Alignment.Z, -1.0, 1.0);

	// Draw top and bottom circles
	for(i = 0; i < 2; ++i)
	{
		for(j = 0; j < NumSegments; ++j)
		{
			SegmentStart.X = Cos(j * RadPerSegment) * Radius;
			SegmentStart.Y = Sin(j * RadPerSegment) * Radius;
			SegmentStart.Z = Height * 0.5 + (i % 2) * Height * -1.0;

			SegmentEnd.X = Cos((j + 1) * RadPerSegment) * Radius;
			SegmentEnd.Y = Sin((j + 1) * RadPerSegment) * Radius;
			SegmentEnd.Z = SegmentStart.Z;

			SegmentStart += Vect(1,1,0) * Alignment * Radius;
			SegmentStart += Vect(0,0,1) * Alignment * Height * 0.5;

			SegmentEnd += Vect(1,1,0) * Alignment * Radius;
			SegmentEnd += Vect(0,0,1) * Alignment * Height * 0.5;

			SegmentStart += WorldOrigin;
			SegmentEnd += WorldOrigin;

			C.DrawLine3D(SegmentStart, SegmentEnd, R, G, B);
		}
	}

	// Draw four lines
	RadPerSegment = (2.0 * Pi) / 4.0;
	for(i = 0; i < 4; ++i)
	{
		SegmentStart.X = Cos(i * RadPerSegment) * Radius;
		SegmentStart.Y = Sin(i * RadPerSegment) * Radius;
		SegmentStart.Z = Height * 0.5 * -1.0;

		SegmentEnd.X = SegmentStart.X;
		SegmentEnd.Y = SegmentStart.Y;
		SegmentEnd.Z = Height * 0.5;

		SegmentStart += Vect(1,1,0) * Alignment * Radius;
		SegmentStart += Vect(0,0,1) * Alignment * Height * 0.5;

		SegmentEnd += Vect(1,1,0) * Alignment * Radius;
		SegmentEnd += Vect(0,0,1) * Alignment * Height * 0.5;

		SegmentStart += WorldOrigin;
		SegmentEnd += WorldOrigin;

		C.DrawLine3D(SegmentStart, SegmentEnd, R, G, B);
	}
}

/**
*	DrawAxes3D
*	Draws a 3-line cross for X Y and Z axes at the specified location
*/
static function DrawAxes3D(
	Canvas C, Vector WorldOrigin, float LineLength,
	float R, float G, float B)
{
	local Vector LineStart, LineStop;

	LineStart = WorldOrigin + Vect(-1,0,0) * LineLength * 0.5;
	LineStop = LineStart + Vect(1,0,0) * LineLength;
	C.DrawLine3D(LineStart, LineStop, R, G, B);

	LineStart = WorldOrigin + Vect(0,-1,0) * LineLength * 0.5;
	LineStop = LineStart + Vect(0,1,0) * LineLength;
	C.DrawLine3D(LineStart, LineStop, R, G, B);

	LineStart = WorldOrigin + Vect(0,0,-1) * LineLength * 0.5;
	LineStop = LineStart + Vect(0,0,1) * LineLength;
	C.DrawLine3D(LineStart, LineStop, R, G, B);
}

/**
*	GetScreenSpaceLocationAboveActor
*	Given some Actor, this function will determine a screen-space location
*	above that actor based on its world position and collision height
*
*	ZOffset is additional offset on the Z axis above the actor
*/
static function GetScreenSpaceLocationAboveActor(
	Canvas C,
	Actor InActor,
	out Vector OutScreenLocation,
	optional float ZOffset)
{
	local Vector WorldUp;
	local Vector WorldSpaceLocation;
	local int ScreenX, ScreenY;

	if(InActor == None)
	{
		OutScreenLocation.X = 0.0;
		OutScreenLocation.Y = 0.0;
		OutScreenLocation.Z = 0.0;
		return;
	}

	WorldUp.Z = 1.0;
	WorldSpaceLocation = InActor.Location + WorldUp * (InActor.CollisionHeight + ZOffset);

	C.TransformPoint(WorldSpaceLocation, ScreenX, ScreenY);
	OutScreenLocation.X = float(ScreenX);
	OutScreenLocation.Y = float(ScreenY);
	OutScreenLocation.Z = 0.0;
}
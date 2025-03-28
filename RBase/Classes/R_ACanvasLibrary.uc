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
    
    C.Style = 3; // STY_Translucent
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
    
    C.Style = 3; // STY_Translucent
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
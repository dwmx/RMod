//==============================================================================
// R_ACanvasUtilities
// Static utilities for Canvas
//==============================================================================
class R_ACanvasUtilities extends Object abstract;

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
*   DrawBoxOutline
*   Draws a a box with the specified thickness and color on the screen
*   Extents mark the opposite corners of the box in pixels, in range [0,C.Clip] (Z ignored)
*   RGBA colors should be in range [0,1]
*/
static function DrawBoxOutline(
    Canvas C,
    Vector Extent1, Vector Extent2,
    float Thickness,
    float R, float G, float B, float A)
{
    local Texture WhiteTexture;
    local float MinX, MinY, MaxX, MaxY;
    
    WhiteTexture = Texture'UWindow.WhiteTexture';
    
    Extent1.X = FClamp(Extent1.X, 0.0, C.CLipX);
    Extent1.Y = FClamp(Extent1.Y, 0.0, C.ClipY);
    Extent1.Z = 0.0;
    
    Extent2.X = FClamp(Extent2.X, 0.0, C.CLipX);
    Extent2.Y = FClamp(Extent2.Y, 0.0, C.ClipY);
    Extent2.Z = 0.0;
    
    MinX = FMin(Extent1.X, Extent2.X);
    MaxX = FMax(Extent1.X, Extent2.X);
    MinY = FMin(Extent1.Y, Extent2.Y);
    MaxY = FMax(Extent1.Y, Extent2.Y);
    
    R = FClamp(R, 0.0, 1.0);
    G = FClamp(G, 0.0, 1.0);
    B = FClamp(B, 0.0, 1.0);
    
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
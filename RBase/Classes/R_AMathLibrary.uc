//==============================================================================
//  R_AMathLibrary
//  Library class
//
//  Provides various math utilities including interpolations and transforms
//==============================================================================
class R_AMathLibrary extends R_ALibrary abstract;

/**
*   CheckBoundingBoxCollisionMidPointBased
*   Returns true if the mid point of either bounding box is inside of the
*   other bounding box
*/
static function bool CheckBoundingBoxCollisionMidPointBased(
    Vector ExtentA1, Vector ExtentA2,
    Vector ExtentB1, Vector ExtentB2)
{
    local Vector MinA, MaxA, MidA;
    local Vector MinB, MaxB, MidB;
    
    MinA.X = FMin(ExtentA1.X, ExtentA2.X);
    MinA.Y = FMin(ExtentA1.Y, ExtentA2.Y);
    MaxA.X = FMax(ExtentA1.X, ExtentA2.X);
    MaxA.Y = FMax(ExtentA1.Y, ExtentA2.Y);
    MidA.X = (MinA.X + MaxA.X) / 2.0;
    MidA.Y = (MinA.Y + MaxA.Y) / 2.0;
    
    MinB.X = FMin(ExtentB1.X, ExtentB2.X);
    MinB.Y = FMin(ExtentB1.Y, ExtentB2.Y);
    MaxB.X = FMax(ExtentB1.X, ExtentB2.X);
    MaxB.Y = FMax(ExtentB1.Y, ExtentB2.Y);
    MidB.X = (MinB.X + MaxB.X) / 2.0;
    MidB.Y = (MinB.Y + MaxB.Y) / 2.0;
    
    if(MidA.X >= MinB.X && MidA.X <= MaxB.X)
    {
        if(MidA.Y >= MinB.Y && MidA.Y <= MaxB.Y)
        {
            return true;
        }
    }
    
    if(MidB.X >= MinA.X && MidB.X <= MaxA.X)
    {
        if(MidB.Y >= MinA.Y && MidB.Y <= MaxA.Y)
        {
            return true;
        }
    }
    
    return false;
}

/**
*   GetWorldRayFromScreen
*   Given some screen space location, returns a ray that can be used to trace for world collisions
*/
static function Vector GetWorldRayFromScreen(
    Vector ScreenPos,
    float ScreenWidth, float ScreenHeight,
    float FOV,
    Vector CameraLocation, Rotator CameraRotation)
{
   local float HalfWidth, HalfHeight, TanFOV, AspectRatio;
   local Vector ScreenRay, WorldDirection, AxisX, AxisY, AxisZ, WorldRay;
   
   // Calculate half-dimensions and aspect ratio
   HalfWidth = ScreenWidth / 2.0;
   HalfHeight = ScreenHeight / 2.0;
   TanFOV = Tan((FOV * 3.141593) / 360.0);
   AspectRatio = TanFOV / HalfWidth;
   
   // Compute ray direction in screen space
   ScreenRay.Y = ((ScreenPos.X - HalfWidth) * AspectRatio);
   ScreenRay.Z = ((HalfHeight - ScreenPos.Y) * AspectRatio);
   ScreenRay.X = 1.0;
   
   // Convert screen space ray to world space
   GetAxes(CameraRotation, AxisX, AxisY, AxisZ);
   WorldDirection = ((ScreenRay.X * AxisX) + (ScreenRay.Y * AxisY)) + (ScreenRay.Z * AxisZ);
   WorldDirection = Normal(WorldDirection);
   
   // Compute world-space ray endpoint
   WorldRay = WorldDirection / AspectRatio;
   return WorldRay;
}
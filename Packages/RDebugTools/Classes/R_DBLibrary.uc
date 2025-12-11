//==============================================================================
//	R_DBLibrary
//	Debug library functions for RBots
//==============================================================================
class R_DBLibrary extends Object abstract;

static function Font GetDebugFont()
{
	return Font'Engine.MedFont'; // Engine.Canvas.MedFont
}

static function InitializeCanvasForDebugDrawing(Canvas C)
{
	C.Font = GetDebugFont();
}
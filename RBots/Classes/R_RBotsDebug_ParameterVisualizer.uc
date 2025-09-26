//==============================================================================
//	R_RBotsDebug_ParameterVisualizer
//	Class for visualizing changes in some parameter over time
//==============================================================================
class R_RBotsDebug_ParameterVisualizer extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const CanvasBaseLib = Class'RBase.R_ACanvasLibrary';

const WhiteTexture = Texture'UWindow.WhiteTexture';

const OutlineThickness = 2.0;
const ChartLineThickness = 2.0;

// Colors
var private Color OutlineColor;
var private float OutlineAlpha;
var private Color BackdropColor;
var private float BackdropAlpha;
var private Color AxisColor;
var private float AxisAlpha;
var private Color ParameterLineColor;


// Treated as a circular array
var private float Samples[512];
var private int Index;
var private float ValueMin;
var private float ValueMax;

// Labels
var private String ParameterNameString;

function Initialize()
{
	Clear();
}

function Clear()
{
	local int i;

	Index = 0;
	for(i = 0; i < ArrayCount(Samples); ++i)
	{
		Samples[i] = 0.0;
	}
}

function SetValueLimits(float NewValueMin, float NewValueMax)
{
	local float Temp;
	Temp = FMin(NewValueMin, NewValueMax);
	ValueMax = FMax(NewValueMin, NewValueMax);
	ValueMin = Temp;
}

function SetParameterNameString(String NewParameterNameString)
{
	ParameterNameString = NewParameterNameString;
}

function Push(float Value)
{
	Index = (Index + 1) % ArrayCount(Samples);
	Samples[Index] = Value;
}

function DrawParameterNameString(
	Canvas C,
	float XMin, float YMin,
	float XMax, float YMax)
{
	local String DrawString;
	local float PosX, PosY;
	local float RGB[3];

	RGB[0] = 1.0;
	RGB[1] = 1.0;
	RGB[2] = 1.0;

	// Draw chart label
	PosX = XMin + (XMax - XMin) * 0.5;
	PosY = YMin;
	DrawString = ParameterNameString;
	CanvasLib.Static.DrawText2D(C, PosX, PosY, Vect(0.5, 1.0, 0.0), RGB, DrawString);

	// Draw value min
	PosX = XMin;
	PosY = YMax;
	DrawString = Utilities.Static.FloatToString(ValueMin, 1);
	CanvasLib.Static.DrawText2D(C, PosX, PosY, Vect(1.0, 1.0, 0.0), RGB, DrawString);

	// Draw value max
	PosX = XMin;
	PosY = YMin;
	DrawString = Utilities.Static.FloatToString(ValueMax, 1);
	CanvasLib.Static.DrawText2D(C, PosX, PosY, Vect(1.0, 0.0, 0.0), RGB, DrawString);
}

function DrawParameterVisualizer(
	Canvas C,
	float XMin, float YMin,
	float XMax, float YMax)
{
	local float Current;
	local int i;
	local float XPosLast, YPosLast;
	local float XPosCurrent, YPosCurrent;
	local float RGB[3];
	local Vector Extent1, Extent2;

	C.Reset();
	DebugLib.Static.InitializeCanvasForDebugDrawing(C);

	DrawParameterNameString(C, XMin, YMin, XMax, YMax);

	// Draw the outline and backdrop
	Extent1.X = XMin;
	Extent1.Y = YMin;
	Extent2.X = XMax;
	Extent2.Y = YMax;

	// Backdrop
	Utilities.Static.ColorToFloats(BackdropColor, RGB[0], RGB[1], RGB[2]);
	CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], BackdropAlpha);

	// Outline
	Utilities.Static.ColorToFloats(OutlineColor, RGB[0], RGB[1], RGB[2]);
	CanvasBaseLib.Static.DrawBoxOutline(C, Extent1, Extent2, OutlineThickness, RGB[0], RGB[1], RGB[2], OutlineAlpha);

	// Draw 0 axis if necessary
	if(Abs(ValueMax - ValueMin) > FMax(Abs(ValueMax), Abs(ValueMin)))
	{
		Current = 0.0;
		GetScreenCoordinates(
			0, ArrayCount(Samples),
			Current, ValueMin, ValueMax,
			XMin, YMin,
			XMax, YMax,
			XPosCurrent, YPosCurrent);
		// Draw
		Extent1.X = XMin;
		Extent1.Y = YPosCurrent - ChartLineThickness * 0.5;
		Extent2.X = XMax;
		Extent2.Y = YPosCurrent + ChartLineThickness * 0.5;
		Utilities.Static.ColorToFloats(AxisColor, RGB[0], RGB[1], RGB[2]);
		CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], AxisAlpha);
	}

	// Draw chart
	Utilities.Static.ColorToFloats(ParameterLineColor, RGB[0], RGB[1], RGB[2]);

	Current = Samples[(Index + 1) % ArrayCount(Samples)];
	GetScreenCoordinates(
		0, ArrayCount(Samples),
		Current, ValueMin, ValueMax,
		XMin, YMin,
		XMax, YMax,
		XPosCurrent, YPosCurrent);

	for(i = 2; i < ArrayCount(Samples); ++i)
	{
		XPosLast = XPosCurrent;
		YPosLast = YPosCurrent;

		Current = Samples[(Index + i) % ArrayCount(Samples)];
		GetScreenCoordinates(
			i, ArrayCount(Samples),
			Current, ValueMin, ValueMax,
			XMin, YMin,
			XMax, YMax,
			XPosCurrent, YPosCurrent);

		// Draw
		Extent1.X = XPosLast;
		Extent1.Y = YPosLast;
		Extent2.X = XPosCurrent;
		Extent2.Y = YPosLast + ChartLineThickness;
		CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], 1.0);

		Extent1.X = XPosCurrent - ChartLineThickness;
		Extent1.Y = YPosLast;
		Extent2.X = XPosCurrent;
		Extent2.Y = YPosCurrent;
		CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], 1.0);
	}

	C.Reset();
}

function GetScreenCoordinates(
	int Placement, int NumValues,
	float Value, float ValueMin, float ValueMax,
	float XMin, float YMin,
	float XMax, float YMax,
	out float OutPosX, out float OutPosY)
{
	local float t;

	t = float(Placement) / float(NumValues);
	t = FClamp(t, 0.0, 1.0);
	OutPosX = (1.0-t) * XMin + t * XMax;

	t = (Value - ValueMin) / (ValueMax - ValueMin);
	t = 1.0 - FClamp(t, 0.0, 1.0);
	OutPosY = (1.0-t) * YMin + t * YMax;
}

defaultproperties
{
	OutlineColor=(R=0,G=13,B=110)
	OutlineAlpha=1.0
	BackdropColor=(R=0,G=0,B=0)
	BackdropAlpha=0.25
	AxisColor=(R=255,G=255,B=255)
	AxisAlpha=0.25
	ParameterLineColor=(R=0,G=140,B=255)
	ValueMin=0.0
	ValueMax=1.0
}
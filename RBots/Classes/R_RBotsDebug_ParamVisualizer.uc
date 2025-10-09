class R_RBotsDebug_ParamVisualizer extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';
const CanvasLib = Class'RBots.R_RBots_CanvasLibrary';
const CanvasBaseLib = Class'RBase.R_ACanvasLibrary';

const WhiteTexture = Texture'UWindow.WhiteTexture';

const OutlineThickness = 2.0;
const ChartLineThickness = 2.0;

const ParamBarHeight = 8.0;
const ParamBarSpacing = 4.0;

const ParamClass = Class'RBots.R_RBotsDebug_Param';

var private Color BarBackdropColor;
var private Color BarFillColor;
var private Color BackdropColor;
var private float BackdropAlpha;

var private R_RBotsDebug_Param ParamArray[256];
var private int NumParams;

function Initialize()
{
	Clear();
}

function Clear()
{
	local int i;
	for(i = 0; i < ArrayCount(ParamArray); ++i)
	{
		ParamArray[i] = None;
	}
	NumParams = 0;
}

function CreateParam(Name NewParamName)
{
	local R_RBotsDebug_Param NewParam;
	local int i;

	if(NumParams >= ArrayCount(ParamArray))
	{
		return;
	}

	for(i = 0; i < NumParams; ++i)
	{
		if(ParamArray[i].GetName() == NewParamName)
		{	// Params cannot share names
			return;
		}
	}

	NewParam = new(None) ParamClass;
	if(NewParam != None)
	{
		ParamArray[NumParams] = NewParam;
		++NumParams;

		NewParam.Initialize();
		NewParam.SetName(NewParamName);
	}
}

function Advance()
{
	local int i;

	for(i = 0; i < NumParams; ++i)
	{
		ParamArray[i].Advance();
	}
}

function R_RBotsDebug_Param GetParamByName(Name ParamName)
{
	local int i;

	for(i = 0; i < NumParams; ++i)
	{
		if(ParamArray[i].GetName() == ParamName)
		{
			return ParamArray[i];
		}
	}
	return None;
}

function SetParamValue(Name ParamName, float ParamValue)
{
	local R_RBotsDebug_Param Param;

	Param = GetParamByName(ParamName);
	if(Param != None)
	{
		Param.Set(ParamValue);
	}
}

function SetParamLimits(Name ParamName, float LimitMin, float LimitMax)
{
	local R_RBotsDebug_Param Param;

	Param = GetParamByName(ParamName);
	if(Param != None)
	{
		Param.SetLimits(LimitMin, LimitMax);
	}
}

function DrawParamVisualizer(
	Canvas C,
	float XMin, float YMin,
	float XMax, float YMax)
{
	local float RGB[3];
	local Vector Extent1, Extent2;
	local int i;
	local float ParamXMin, ParamYMin, ParamXMax, ParamYMax;

	C.Reset();
	DebugLib.Static.InitializeCanvasForDebugDrawing(C);

	// Draw the outline and backdrop
	Extent1.X = XMin;
	Extent1.Y = YMin;
	Extent2.X = XMax;
	Extent2.Y = YMax;

	// Backdrop
	Utilities.Static.ColorToFloats(BackdropColor, RGB[0], RGB[1], RGB[2]);
	CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], BackdropAlpha);

	// Draw all Params
	ParamXMin = XMin;
	ParamYMin = YMin;
	ParamXMax = XMax;
	ParamYMax = ParamYMin + ParamBarHeight + ParamBarSpacing;
	for(i = 0; i < NumParams; ++i)
	{
		DrawParam(C, ParamArray[i], ParamXMin, ParamYMin, ParamXMax, ParamYMax);
		ParamYMin = ParamYMax;
		ParamYMax += ParamBarHeight + ParamBarSpacing;
	}
}

function DrawParam(
	Canvas C,
	R_RBotsDebug_Param Param,
	float XMin, float YMin,
	float XMax, float YMax)
{
	local float RGB[3];
	local float LimitMin, LimitMax;
	local float Fill;
	local Vector Extent1, Extent2;

	C.Style = 1; // STY_Normal
	RGB[0] = 1.0;
	RGB[1] = 1.0;
	RGB[2] = 1.0;

	CanvasLib.Static.DrawText2D(
		C,
		XMin,
		YMin + (YMax - YMin) * 0.5,
		Vect(0.0,0.5,0.0),
		RGB,
		String(Param.GetName()));

	LimitMin = Param.GetLimitMin();
	LimitMax = Param.GetLimitMax();
	Fill = Param.GetCurrentProportion();

	Extent1.X = XMin + (XMax - XMin) * 0.3;
	Extent1.Y = YMin + ((YMax - YMin) - ParamBarHeight) * 0.5;
	Extent1.Z = 0.0;

	Extent2.X = XMax;
	Extent2.Y = YMax - ((YMax - YMin) - ParamBarHeight) * 0.5;
	Extent2.Z = 0.0;

	Utilities.Static.ColorToFloats(BarBackdropColor, RGB[0], RGB[1], RGB[2]);
	CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], 1.0);

	Extent1.X += 1.0;
	Extent1.Y += 1.0;
	Extent2.X -= 1.0;
	Extent2.Y -= 1.0;

	Fill = FClamp(Fill, 0.0, 1.0);
	Extent2.X = Extent1.X + (Extent2.X - Extent1.X) * Fill;

	Utilities.Static.ColorToFloats(BarFillColor, RGB[0], RGB[1], RGB[2]);
	CanvasBaseLib.Static.DrawBoxSolid(C, Extent1, Extent2, RGB[0], RGB[1], RGB[2], 1.0);
}

defaultproperties
{
	BarBackdropColor=(R=53,G=53,B=53)
	BarFillColor=(R=255,G=179,B=38)
	BackdropColor=(R=0,G=0,B=0)
	BackdropAlpha=0.25
}


/*
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
	*/
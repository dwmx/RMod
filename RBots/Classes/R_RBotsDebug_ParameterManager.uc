//==============================================================================
//	R_RBotsDebug_ParameterManager
//	Class for managing the organization and debug drawing of parameters
//==============================================================================
class R_RBotsDebug_ParameterManager extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const DebugLib = Class'RBots.R_RBots_DebugLibrary';

const WhiteTexture = Texture'UWindow.WhiteTexture';

var Color ParameterBackdropColor;
var Color ParameterFillColor;
var Color ParameterNumericColor;

var float Amt;

function Initialize()
{}

function Clear()
{

}

function DrawParameterManager(Canvas C)
{
	//local float XPos, YPos;
	//local float Width, Height;
	//local float Fill;
	//local String AmtString;
	//local float StrW, StrH;
//
	//Amt += 1.0;
//
	//Width = 128.0;
	//Height = 6.0;
//
	//XPos = C.ClipX * 0.5;
	//YPos = C.ClipY * 0.5;
//
	//Fill = (Amt % 500.0) / 500.0;
//
	//C.DrawColor = ParameterBackdropColor;
	//C.SetPos(XPos, YPos);
	//C.DrawRect(WhiteTexture, Width, Height);
//
	//C.DrawColor = ParameterFillColor;
	//C.SetPos(XPos + 1.0, YPos + 1.0);
	//C.DrawRect(WhiteTexture, (Width - 2.0) * Fill, Height - 2.0);
//
	//StrW = 0.0;
	//StrH = 0.0;
	//DebugLib.Static.InitializeCanvasForDebugDrawing(C);
	//AmtString = Utilities.Static.FloatToString(Amt / 500.0, 1);
	//C.StrLen(AmtString, StrW, StrH);
	//C.SetPos(XPos + Width + 4.0, YPos + (Height * 0.5) - (StrH * 0.5));
	//C.DrawColor = ParameterNumericColor;
	//C.DrawText(AmtString);
//
	//AmtString = "Enviro Avoidance Weight";
	//C.StrLen(AmtString, StrW, StrH);
	//C.SetPos(XPos - StrW - 4.0, YPos + (Height * 0.5) - (StrH * 0.5));
	//C.DrawColor = ParameterNumericColor;
	//C.DrawText(AmtString);
}

defaultproperties
{
	ParameterBackdropColor=(R=255,G=255,B=255)
	ParameterFillColor=(R=255,G=50,B=50)
	ParameterNumericColor=(R=255,G=255,B=255)
}
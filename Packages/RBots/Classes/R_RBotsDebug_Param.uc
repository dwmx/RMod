
//==============================================================================
//	R_RBotsDebug_Param
//	Keeps a running log of values for a given parameter, which can be drawn
//	either as a current value or as a value on some chart
//==============================================================================
class R_RBotsDebug_Param extends Object;

var private float LimitMin;
var private float LimitMax;
var private float Values[512];
var private int CurrentIndex;
var private Name ParamName;

function Initialize()
{
	CurrentIndex = 0;
	LimitMin=0.0;
	LimitMax=1.0;
}

function SetName(Name NewParamName)
{
	ParamName = NewParamName;
}

function Name GetName()
{
	return ParamName;
}

function Advance()
{
	CurrentIndex = (CurrentIndex + 1) % ArrayCount(Values);
	Values[CurrentIndex] = 0.0;
}

function Set(float NewValue)
{
	Values[CurrentIndex] = NewValue;
}

function int GetCount()
{
	return ArrayCount(Values);
}

function float GetCurrent()
{
	return Values[CurrentIndex];
}

function float GetCurrentProportion()
{
	local float Span;

	Span = LimitMax - LimitMin;
	if(Span == 0.0)
	{
		return 0.0;
	}

	return (GetCurrent() - LimitMin) / Span;
}

function SetLimits(float NewLimitMin, float NewLimitMax)
{
	LimitMin = FMin(NewLimitMin, NewLimitMax);
	LimitMax = FMax(NewLimitMin, NewLimitMax);
}

function float GetLimitMin()
{
	return LimitMin;
}

function float GetLimitMax()
{
	return LimitMax;
}

defaultproperties
{
	LimitMin=0.0
	LimitMax=1.0
}
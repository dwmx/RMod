class R_ClientDebugActor extends Actor;

struct FDebugLineSegment
{
	var Vector Begin;
	var Vector End;
	var Color Color;
	var float TimeStampSeconds;
	var float LifeTimeSeconds;
};
var FDebugLineSegment DebugLineSegmentArray[32];
const DEBUG_LINE_SEGMENT_COUNT = 32;

event BeginPlay()
{
	InitializeDebugLineSegmentArray();
}

function InitializeDebugLineSegmentArray()
{
	local int i;
	
	for(i = 0; i < DEBUG_LINE_SEGMENT_COUNT; ++i)
	{
		DebugLineSegmentArray[i].TimeStampSeconds = 0.0;
		DebugLineSegmentArray[i].LifeTimeSeconds = 0.0;
	}
}

function bool CheckIsLineSegmentIndexActive(int LineSegmentIndex)
{
	local float DeltaSeconds;
	
	if(LineSegmentIndex >= DEBUG_LINE_SEGMENT_COUNT || LineSegmentIndex < 0)
	{
		return false;
	}
	
	DeltaSeconds = Level.TimeSeconds - DebugLineSegmentArray[LineSegmentIndex].TimeStampSeconds;
	return DeltaSeconds <= DebugLineSegmentArray[LineSegmentIndex].LifeTimeSeconds;
}

function DrawLineSegmentForDuration(Vector Begin, Vector End, Color Color, float DurationSeconds)
{
	local int i;
	local int LineSegmentIndex;
	
	for(i = 0; i < DEBUG_LINE_SEGMENT_COUNT; ++i)
	{
		if(!CheckIsLineSegmentIndexActive(i))
		{
			break;
		}
	}
	
	if(i < DEBUG_LINE_SEGMENT_COUNT)
	{
		DebugLineSegmentArray[i].Begin = Begin;
		DebugLineSegmentArray[i].End = End;
		DebugLineSegmentArray[i].Color = Color;
		DebugLineSegmentArray[i].TimeStampSeconds = Level.TimeSeconds;
		DebugLineSegmentArray[i].LifeTimeSeconds = DurationSeconds;
	}
}

event PostRender(Canvas C)
{
	RenderDebugLineSegments(C);
}

event RenderDebugLineSegments(Canvas C)
{
	local int i;
	local FDebugLineSegment DebugLineSegment;
	local Vector BoxExtents;
	
	BoxExtents.X = 8.0;
	BoxExtents.Y = 8.0;
	BoxExtents.Z = 8.0;
	for(i = 0; i < DEBUG_LINE_SEGMENT_COUNT; ++i)
	{
		if(CheckIsLineSegmentIndexActive(i))
		{
			DebugLineSegment = DebugLineSegmentArray[i];
			C.DrawLine3D(
				DebugLineSegment.Begin,
				DebugLineSegment.End,
				DebugLineSegment.Color.R,
				DebugLineSegment.Color.G,
				DebugLineSegment.Color.B);
			C.DrawBox3D(
				DebugLineSegment.Begin,
				BoxExtents,
				DebugLineSegment.Color.R,
				DebugLineSegment.Color.G,
				DebugLineSegment.Color.B);
		}
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	DrawType=DT_None
}
//=============================================================================
// DarkDwarfChargeup.
//=============================================================================
class DarkDwarfChargeup extends effects;

var float ExpandFactor;
var bool bExpanding;

function PreBeginPlay()
{
	Super.PreBeginPlay();
}

function StartExpanding()
{
	DrawScale=0.1;
	bHidden=false;
	bExpanding=true;
}

function StopExpanding()
{
	bExpanding=false;
}

function SetPowerLevel(int powerlevel)
{
	ExpandFactor = 0.25 + (powerlevel-1)*0.5;	// 0.25 - 2.0
}

function Hide()
{
	bExpanding=false;
	bHidden=true;
}

function Tick(float DeltaSeconds)
{
	if (bExpanding)
	{
		DrawScale += (DeltaSeconds*ExpandFactor);
		DrawScale = FClamp(DrawScale, 0.1, 4.0);
	}
}

simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText(" bHidden=:   "$bHidden);
	Canvas.CurY -= 8;
	Canvas.DrawText(" DrawScale=: "$DrawScale);
	Canvas.CurY -= 8;
}

defaultproperties
{
     ExpandFactor=0.250000
     bHidden=True
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'RuneFX.DarkDwarfEnergyBall'
     DrawScale=0.750000
     ScaleGlow=2.000000
     AmbientGlow=50
}

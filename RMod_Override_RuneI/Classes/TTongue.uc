//=============================================================================
// TTongue.
//=============================================================================
class TTongue expands LimbWeapon;

var(Dynamics) float Dampening;
var(Dynamics) int	RotAngle;
var(Dynamics) float	AccelMag;
var vector OldPos;

simulated event GetAccelJointParms(int joint, out float DampFactor, out float RotThreshold)
{
	DampFactor = Dampening;
	RotThreshold = RotAngle;
}

simulated event float GetAccelJointMagnitude(int joint)
{
	return AccelMag;
}

simulated function Tick(float DeltaTime)
{
	local vector vel;

	if (Owner != None)
	{
		OldPos = GetJointPos(5);

		if (VSize(Owner.Velocity) > 50)
		{
			vel = -Owner.Velocity*0.2;
			ApplyJointForce(2, vel);
			ApplyJointForce(3, vel);
		}
	}
}

function SpawnBloodSpray(vector HitLoc, vector HitNorm, EMatterType matter)
{
}

function WeaponFire(int SwingCount)
{
	local vector vel;

	vel = Normal(GetJointPos(5)-OldPos)*500;
	ApplyJointForce(2, vel);
	ApplyJointForce(3, vel);
	ApplyJointForce(4, vel);
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Dynamics:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Dampening:   "$Dampening);
	Canvas.CurY -= 8;
	Canvas.DrawText(" RotAngle:    "$RotAngle);
	Canvas.CurY -= 8;
	Canvas.DrawText(" AccelMag:    "$AccelMag);
	Canvas.CurY -= 8;
}

defaultproperties
{
     Dampening=0.005000
     RotAngle=4000
     AccelMag=500.000000
     DrawScale=2.500000
     Skeletal=SkelModel'objects.TubeTongue'
     SkelGroupSkins(1)=Texture'creatures.Strikerstriker'
}

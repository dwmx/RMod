//=============================================================================
// RuneSpheresPower2.
//=============================================================================
class RuneSpheresPower2 expands RuneSpheres;

simulated function Tick(float DeltaTime)
{
	local int i;

	ElapsedTime += DeltaTime;
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Location = Location +
			(vect(1,0,0) * Sin(ElapsedTime*(i+0.2)) * MaxDeviation) +
			(vect(0,1,0) * Cos(ElapsedTime*(i+0.2)) * MaxDeviation);
	}
}

defaultproperties
{
     ParticleTexture(0)=Texture'RuneFX.SparkGold2'
}

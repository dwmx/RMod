class R_RunePlayerHUD_RuneRoyale extends R_RunePlayerHUD;

simulated function DrawRing(Canvas C)
{
    local R_GameReplicationInfo_RuneRoyale GRI;
    local Vector RingOrigin;
    local float RingRadius;
    local int RingSegments;
    local int i;
    local float t;

    local Vector P0, P1;

    GRI = R_GameReplicationInfo_RuneRoyale(PlayerPawn(Owner).GameReplicationInfo);
    if(GRI != None)
    {
        RingRadius = GRI.RingRadius;
        RingSegments = 64;

        RingOrigin = GRI.RingOrigin;

        P0.X = 1.0;
        P0.Y = 0.0;
        P0.Z = 32.0;
        P0 = P0 * RingRadius;

        for(i = 1; i <= RingSegments; ++i)
        {
            t = float(i) / float(RingSegments);
            t = t * 2.0 * Pi;
            P1.X = Cos(t) * RingRadius;
            P1.Y = Sin(t) * RingRadius;
            P1.Z = 32.0;

            C.DrawLine3D(P0, P1, 1.0,1.0,1.0);

            P0 = P1;
        }
    }
}

simulated event PostRender(Canvas C)
{
    Super.PostRender(C);

    DrawRing(C);
}
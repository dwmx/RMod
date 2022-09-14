class R_IceStatueProxyPRI extends R_PlayerReplicationInfo;

/* 
*   This class is necessary for team damage, used only during the IceStatue state.
*   See R_IceStatueProxy.uc for more details.
*/

defaultproperties
{
    RemoteRole=ROLE_None
    Team=128
}
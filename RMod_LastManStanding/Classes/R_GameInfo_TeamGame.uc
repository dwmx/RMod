// Base class for team games
class R_GameInfo_TeamGame extends R_GameInfo;

var class<R_AColors> ColorsClass;
var class<TeamInfo> TeamInfoClass;

var TeamInfo TeamInfoArray[4];
const MAX_TEAMS = 4;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    InitTeamInfo();
}

function InitTeamInfo()
{
    local int i;

    for(i = 0; i < MAX_TEAMS; ++i)
    {
        TeamInfoArray[i] = Spawn(TeamInfoClass);
        TeamInfoArray[i].Size = 0;
        TeamInfoArray[i].Score = 0;
        TeamInfoArray[i].TeamName = "Team";
        TeamInfoArray[i].TeamIndex = i;
        RuneGameReplicationInfo(GameReplicationInfo).Teams[i] = TeamInfoArray[i];
    }
}

function AddToTeam( int num, Pawn Other )
{
	//local teaminfo aTeam;
	//local Pawn P;
	//local bool bSuccess;
	//local string SkinName, FaceName;
//
	//aTeam = Teams[num];
//
	//aTeam.Size++;
	//Other.PlayerReplicationInfo.Team = num;
	//Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	//bSuccess = false;
	//if ( Other.IsA('PlayerPawn') )
	//	Other.PlayerReplicationInfo.TeamID = 0;
	//else
	//	Other.PlayerReplicationInfo.TeamID = 1;
//
	//while ( !bSuccess )
	//{
	//	bSuccess = true;
	//	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
    //                    if ( P.bIsPlayer && (P != Other) 
	//						&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
	//						&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
	//			bSuccess = false;
	//	if ( !bSuccess )
	//		Other.PlayerReplicationInfo.TeamID++;
	//}
//
	//BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$NewTeamMessage$aTeam.TeamName, false);
//
//	//Other.static.GetMultiSkin(Other, SkinName, FaceName);
//	//Other.static.SetMultiSkin(Other, SkinName, FaceName, num);
//
	//Other.DesiredColorAdjust = GetTeamVectorColor(num);
}

defaultproperties
{
    bTeamGame=True
    ColorsClass=Class'RMod.R_AColors'
    TeamInfoClass=Class'TeamInfo'
}
class R_GameInfo_TDM extends R_GameInfo config(RMod);


////////////////////////////////////////////////////////////////////////////////
//	RuneI.TeamGame
var() config bool   bSpawnInTeamArea;
var() config bool	bNoTeamChanges;
var() config float  FriendlyFireScale; //scale friendly fire damage by this value
var() config int	MaxTeams; //Maximum number of teams allowed in (up to 4)
var	TeamInfo Teams[4];
var() config float  GoalTeamScore; //like fraglimit
var() config int	MaxTeamSize;
var  localized string NewTeamMessage;
var		int			NextBotTeam;
var byte TEAM_Red, TEAM_Blue, TEAM_Green, TEAM_Gold;
var localized string TeamColor[4];
var vector VColorRed, VColorBlue, VColorGreen, VColorGold, VColorWhite;
var int TeamSupported[4]; // RUNE

function ResetGameReplicationInfo()
{
	local int i;
	
	Super.ResetGameReplicationInfo();
	
	for(i = 0; i < 4; ++i)
	{
		RuneGameReplicationInfo(GameReplicationInfo).Teams[i] = Teams[i];
	}
}

function PostBeginPlay()
{
	local int i;
	local NavigationPoint N;

	for (i=0;i<4;i++)
	{
		Teams[i] = Spawn(class'TeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamColor[i];
		Teams[i].TeamIndex = i;
		RuneGameReplicationInfo(GameReplicationInfo).Teams[i] = Teams[i];
	}

	Super.PostBeginPlay();

	if(bLevelHasTeamOnly)
	{
		for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
		{
			if (N.IsA('PlayerStart'))
			{
				//Only use TeamOnly starts to determine supported colors..
				if(PlayerStart(N).bTeamOnly)
					TeamSupported[PlayerStart(N).TeamNumber] = 1;
			}
		}
	}
	else
	{ // RUNE:  Non-teamonly supports all colors
		for(i = 0; i < 4; i++)
		{
			TeamSupported[i] = 1;
		}
	}
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	GoalTeamScore = FragLimit;
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	RuneGameReplicationInfo(GameReplicationInfo).GoalTeamScore = GoalTeamScore;
}

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	// FriendlyFire
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";

	return ResultSet;
}

//------------------------------------------------------------------------------
// Player start functions


//FindPlayerStart
//- add teamnames as new teams enter
//- choose team spawn point if bSpawnInTeamArea

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;
	local byte newTeam;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if ( newPlayer == None)
		return None;

	newTeam = newPlayer.PlayerReplicationInfo.Team;

	if(newTeam < 0 || newTeam >= MaxTeams || TeamSupported[newTeam] == 0)
	{
		newTeam = ForceTeam(newPlayer);
	}

	if (bSpawnInTeamArea || bLevelHasTeamOnly)
	{									//Attempt to fix Client spawn problem
		StartSpot = FindPlayerStart(newPlayer, newTeam, Portal);
		if ( StartSpot != None )
		{
			NewPlayer.SetLocation(StartSpot.Location);
			NewPlayer.SetRotation(StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}
				
	return newPlayer;
}

function byte ForceTeam(pawn aPlayer)
{
	local int i, s;
	local int NewTeam;
	local teaminfo SmallestTeam;

	for( i=0; i<MaxTeams; i++ )
	{
		if(TeamSupported[i] != 0)
		{
			if ((Teams[i].Size < MaxTeamSize) && ((SmallestTeam == None) || (SmallestTeam.Size > Teams[i].Size)))
			{
				s = i;
				SmallestTeam = Teams[i];
			}
		}
	}

	NewTeam = s;

	if(aPlayer.IsA('Spectator'))
	{
		aPlayer.PlayerReplicationInfo.Team = NewTeam;
		aPlayer.PlayerReplicationInfo.TeamName = Teams[NewTeam].TeamName;
		return NewTeam;
	}

	if (aPlayer.PlayerReplicationInfo.TeamName != "" )
		Teams[aPlayer.PlayerReplicationInfo.Team].Size--;

	//Add unconditionally 
	AddToTeam(NewTeam, aPlayer);
	return NewTeam;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Spectator') )
		return;
	if(Exiting.PlayerReplicationInfo.Team >= 0
	&& Exiting.PlayerReplicationInfo.Team <= 3)
	{
		Teams[Exiting.PlayerReplicationInfo.Team].Size--;
	}
}
	
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;
	local byte Team;

	if(Player != None && Player.PlayerReplicationInfo != None)
	{
		Team = Player.PlayerReplicationInfo.Team;
	}
	else
	{
		Team = InTeam;
	}

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;
	
	if ( Team == 255 || (Team < MaxTeams && Team >= 0 && TeamSupported[Team] == 0))
	{
		for(i = 0; i < MaxTeams; i++)
		{
			if(TeamSupported[i] != 0)
			{
				Team = i;
				break;
			}
		}

		if(Team == 255)
			Team = 0;
	}
		//Team = 0;

	num = 0;

	//Altered to fix problem with Team-Starts, also to incorporate new bTeamOnly PlayerStart property
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	{
		if (N.IsA('PlayerStart') && (!bLevelHasTeamOnly || (bLevelHasTeamOnly && PlayerStart(N).bTeamOnly)))
		{
			if(Team == PlayerStart(N).TeamNumber)
			{
				if (num<16)
					Candidate[num] = PlayerStart(N);
				else if (Rand(num) < 16)
					Candidate[Rand(16)] = PlayerStart(N);
				num++;
			}
		}
	}
	
	if (num == 0 )
	{
		log("Didn't find any player starts in list for team"@InTeam);
		foreach AllActors( class'PlayerStart', Dest )
		{
			if (num<16)
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
	}

	if (num>16)
		num = 16;
	else if (num == 0)
		return None;
		
	//assess candidates
	for (i=0;i<num;i++)
	{
		if (Candidate[i] == LastStartSpot )
			Score[i] = -6000.0;
		else
			Score[i] = 4000 * FRand(); //randomize
	}
		
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') )
			for (i=0;i<num;i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < 2 * (CollisionRadius + CollisionHeight))
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && (InTeam != OtherPlayer.PlayerReplicationInfo.Team) &&
						FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= 10000.0 - NextDist;
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
	{
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}
	LastStartSpot = Best;
				
	return Best;
}

function bool AddBot()
{
/*	local NavigationPoint StartSpot;
	local bots NewBot;
	local int BotN, DesiredTeam;

	BotN = BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = FindPlayerStart(0);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return false;
	}

	// Try to spawn the player.
	NewBot = Spawn(BotConfig.GetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		return false;

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		NewBot.Destroy();
		log("Failed to spawn bot");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	// Init player's information.
	BotConfig.Individualize(NewBot, BotN, NumBots);
	NewBot.ViewRotation = StartSpot.Rotation;

	// broadcast a welcome message.
	BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, true );

	AddDefaultInventory( NewBot );
	NumBots++;

	DesiredTeam = BotConfig.GetBotTeam(BotN);
	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		ChangeTeam(NewBot, NextBotTeam);
		NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
	}

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(newBot.PlayerReplicationInfo.Team);
		if ( StartSpot != None )
		{
			NewBot.SetLocation(StartSpot.Location);
			NewBot.SetRotation(StartSpot.Rotation);
			NewBot.ViewRotation = StartSpot.Rotation;
			NewBot.ClientSetRotation(NewBot.Rotation);
			StartSpot.PlayTeleportEffect( NewBot, true );
		}
	}
*/
	return true;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification
function Killed(pawn killer, pawn Other, name damageType)
{
	Super.Killed(killer, Other, damageType);

	if(Other == None)
	{
		return;
	}

    // Team scoring, if score tracking enabled
    if(CheckIsScoringEnabled())
    {
        if( (killer == Other) || (killer == None) )
        {
            Teams[Other.PlayerReplicationInfo.Team].Score -= 1.0;
        }
        else
        {
            if(Killer != None && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
            {
                Teams[Other.PlayerReplicationInfo.Team].Score -= 1.0;
            }
            else
            {
                Teams[killer.PlayerReplicationInfo.Team].Score += 1.0;

                if ( (GoalTeamScore > 0) && (Teams[killer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
                {
                    EndGame("teamscorelimit");
                }
            }
        }
    }
}

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s;
	local pawn APlayer;
	local teaminfo SmallestTeam;
	local string SkinName, FaceName;

	if(Other.PlayerReplicationInfo == None
	|| Other.PlayerReplicationInfo.bIsSpectator
	|| Other.GetStateName() == 'PlayerSpectating')
	{
		return false;
	}
	
	for( i=0; i<MaxTeams; i++ )
	{
		if(TeamSupported[i] != 0)
		{
			if ( (Teams[i].Size < MaxTeamSize) 
					&& ((SmallestTeam == None) || (SmallestTeam.Size > Teams[i].Size)) )
			{
				s = i;
				SmallestTeam = Teams[i];
			}
		}
	}
	if ((NewTeam == 255) || (NewTeam >= MaxTeams) || (TeamSupported[NewTeam] == 0))
		NewTeam = s;

	if ( Other.IsA('Spectator'))
	{
		Other.PlayerReplicationInfo.Team = NewTeam;
		Other.PlayerReplicationInfo.TeamName = Teams[NewTeam].TeamName;
		return true;
	}
	if ( Other.PlayerReplicationInfo.Team == NewTeam && bNoTeamChanges)
			return false;
	if ( Other.PlayerReplicationInfo.TeamName != "" )
		Teams[Other.PlayerReplicationInfo.Team].Size--;

	for( i=0; i<MaxTeams; i++ )
	{
		if (i == NewTeam && TeamSupported[i] != 0)
		{
			if (Teams[i].Size < MaxTeamSize)
			{
				AddToTeam(i, Other);
				return true;
			}
			else 
				break;
		}
	}

	if ( (SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize) )
	{
		AddToTeam(s, Other);
		return true;
	}


	return false;
}

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	aTeam = Teams[num];

	aTeam.Size++;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
		Other.PlayerReplicationInfo.TeamID = 0;
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
                        if ( P.bIsPlayer && (P != Other) 
							&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
							&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastMessage(Other.PlayerReplicationInfo.PlayerName$NewTeamMessage$aTeam.TeamName, false);

//	Other.static.GetMultiSkin(Other, SkinName, FaceName);
//	Other.static.SetMultiSkin(Other, SkinName, FaceName, num);

	Other.DesiredColorAdjust = GetTeamVectorColor(num);
}

function vector GetTeamVectorColor(int num)
{
	local Vector V;
	V = ColorsClass.Static.GetTeamColorVector(num);
	return V;
	//local float brightness;
	//brightness = 102;
	//switch(num)
	//{
	//	case 0:
	//		return vect(1,0,0)*brightness;
	//	case 1:
	//		return vect(0,0,1)*brightness;
	//	case 2:
	//		return vect(0,1,0)*brightness;
	//	case 3:
	//		return vect(1,1,0)*brightness;
	//}
	//return vect(0,0,0);
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	return ( (Spectator(Viewer) != None) 
			|| ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team)) );
}

defaultproperties
{
    MaxTeams=4
    MaxTeamSize=16
    NewTeamMessage=" is now on "
    TEAM_Blue=1
    TEAM_Green=2
    TEAM_Gold=3
    TeamColor(0)="Red"
    TeamColor(1)="Blue"
    TeamColor(2)="Green"
    TeamColor(3)="Gold"
    VColorRed=(X=255.000000)
    VColorBlue=(Z=255.000000)
    VColorGreen=(Y=255.000000)
    VColorGold=(X=255.000000,Y=255.000000)
    VColorWhite=(X=255.000000,Y=255.000000,Z=255.000000)
    bCanChangeSkin=False
    bTeamGame=True
    ScoreBoardType=Class'RMod.R_Scoreboard_TDM'
    BeaconName="Team"
    GameName="Team Game"
    GameOptionsClass=Class'RMod.R_GameOptions_DM'
}

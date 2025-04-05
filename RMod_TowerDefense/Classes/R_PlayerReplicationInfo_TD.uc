class R_PlayerReplicationInfo_TD extends R_PlayerReplicationInfo;

var private int Gold;

replication
{
	reliable if(Role == ROLE_Authority)
		Gold;
}

simulated function int GetGold()
{
	return Gold;
}

function SetGold(int NewGold)
{
	Gold = Max(0, NewGold);
}

function IncrementGold(int Amount)
{
	SetGold(Gold + Amount);
}

function SetScore(float NewScore)
{
	Score = NewScore;
}

function IncrementScore(float Amount)
{
	SetScore(Score + Amount);
}
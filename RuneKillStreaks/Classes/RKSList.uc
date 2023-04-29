class RKSList extends Object;

var RKSList Next;

var Pawn AssociatedPawn;
var RKSPlayerState AssociatedPlayerState;
var RKSClientChannel AssociatedClientChannel;

//  Append
//  Adds a new pawn to the end of this list. Spawns an RKSPlayerState to track
//  stats, and spawns an RKSHUD which receives mutator announcements
function Append(Pawn P)
{
    local RKSList ListEnd;

    ListEnd = Self;
    while(ListEnd.Next != None)
    {
        ListEnd = ListEnd.Next;
    }

    ListEnd.Next = new(None) Class'RKSList';
    ListEnd.AssociatedPawn = P;
    ListEnd.AssociatedPlayerState = P.Spawn(Class'RKSPlayerState', P);
    ListEnd.AssociatedClientChannel = P.Spawn(Class'RKSClientChannel', P);
}

//  Find
//  Returns the list node containing the specified pawn, or none.
function RKSList Find(Pawn P)
{
    if(AssociatedPawn == P)
    {
        return Self;
    }

    if(Next != None)
    {
        return Next.Find(P);
    }

    return None;
}
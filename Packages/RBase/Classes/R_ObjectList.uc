//==============================================================================
//	R_ObjectList
//	Singly linked list holding references to Objects
//
//	Note that this list only uses iteration, no recursion due to limitations
//	of UnrealScript's call stack
//
//	Self is always considered the root of the list
//	Self.Next is considered index 0
//	Self.ObjectReference is always None
//
//	When storing Actors, keep in mind that references to those Actors may be
//	lost if game code calls Actor.Destroy
//
//	The Prune function removes any nodes containing stale references
//==============================================================================

//==============================================================================
//	How to iterate over this list:
//		local R_ObjectList NodeIterator;
//		local Object ObjectIterator;
//		NodeIterator = MyList.Begin();
//		while(MyList.Iterate(NodeIterator, ObjectIterator))
//		{
//			/* ObjectIterator is valid, do stuff */
//		}
//==============================================================================

class R_ObjectList extends Object;

var private R_ObjectList Next;
var private Object ObjectReference;

/**
*	Begin
*	Initial node iterator
*/
function R_ObjectList Begin()
{
	return Next;
}

/**
*	Iterate
*	Public iteration function, retrieve initial NodeIt with Begin()
*/
function bool Iterate(out R_ObjectList NodeIt, out Object ObjectIt)
{
	if(NodeIt == None)
	{
		ObjectIt = None;
		return false;
	}

	ObjectIt = NodeIt.ObjectReference;
	NodeIt = NodeIt.Next;
	return true;
}

/**
*	Length
*	Returns the current length of this list
*/
function int Length()
{
	local R_ObjectList Node;
	local int Count;

	Count = 0;
	Node = Next;
	while(Node != None)
	{
		++Count;
		Node = Node.Next;
	}

	return Count;
}

/**
*	Add
*	Add the given object to the end of the list
*/
function Add(Object InObjectReference)
{
	local R_ObjectList Node;

	if(InObjectReference == None)
	{
		return;
	}

	Node = Self;
	while(Node.Next != None)
	{
		Node = Node.Next;
	}

	Node.Next = New(None) Class;
	Node = Node.Next;
	if(Node != None)
	{
		Node.ObjectReference = InObjectReference;
	}
}

/**
*	AddUnique
*	Add the given object to the end of the list if it's not already
*	contained in the list
*/
function AddUnique(Object InObjectReference)
{
	local R_ObjectList Node;

	if(InObjectReference == None)
	{
		return;
	}

	Node = Self;
	while(Node.Next != None)
	{
		if(Node.Next.ObjectReference == InObjectReference)
		{
			return;
		}
		Node = Node.Next;
	}

	Node.Next = New(None) Class;
	Node = Node.Next;
	if(Node != None)
	{
		Node.ObjectReference = InObjectReference;
	}
}

/**
*	Insert
*	Inserts the specified object at the desired index, pushing all other
*	list entries forward by one index after
*	Index must be in range [0,Length], or insertion will not happen
*	Returns true or false for success or failure
*/
function bool Insert(Object InObjectReference, int Index)
{
	local R_ObjectList Node;
	local R_ObjectList Temp;
	local int CurrentIndex;

	if(InObjectReference == None || Index < 0)
	{
		return false;
	}

	Node = Self;
	CurrentIndex = 0;

	while(Node.Next != None && CurrentIndex < Index)
	{
		Node = Node.Next;
		++CurrentIndex;
	}

	if(CurrentIndex == Index)
	{
		if(Node.Next != None)
		{
			Temp = Node.Next;
			Node.Next = New(None) Class;
			Node.Next.ObjectReference = InObjectReference;
			Node.Next.Next = Temp;
		}
		else
		{
			// New tail
			Node.Next = New(None) Class;
			Node.Next.ObjectReference = InObjectReference;
		}
		return true;
	}

	return false;
}

/**
*	Remove
*	Removes the first occurrence of InObjectReference from the list
*	If the list contains multiple references at multiple indices, only
*	the lowest index entry will be removed
*/
function Remove(Object InObjectReference)
{
	local R_ObjectList Node;
	local R_ObjectList Temp;

	if(InObjectReference == None)
	{
		return;
	}

	Node = Self;
	while(Node.Next != None)
	{
		if(Node.Next.ObjectReference == InObjectReference)
		{
			Temp = Node.Next;
			Node.Next = Node.Next.Next;
			Temp.Next = None;
			return;
		}
		Node = Node.Next;
	}
}

/**
*	Contains
*	Returns true if the provided InObjectReference is present anywhere
*	in the list
*/
function bool Contains(Object InObjectReference)
{
	local R_ObjectList Node;

	if(InObjectReference == None)
	{
		return false;
	}

	Node = Self;
	while(Node.Next != None)
	{
		if(Node.Next.ObjectReference == InObjectReference)
		{
			return true;
		}
		Node = Node.Next;
	}

	return false;
}

/**
*	GetAtIndex
*	Returns the referenced object at the specified index
*	If index is invalid, returns None
*/
function Object GetAtIndex(int Index)
{
	local R_ObjectList Node;
	local int CurrentIndex;

	if(Next == None || Index < 0)
	{
		return None;
	}

	Node = Next;
	CurrentIndex = 0;
	while(Node != None && CurrentIndex < Index)
	{
		Node = Node.Next;
		++CurrentIndex;
	}

	if(Node != None && CurrentIndex == Index)
	{
		return Node.ObjectReference;
	}

	return None;
}

/**
*	Find
*	Searches the list and sets OutIndex to the index of InObjectReference
*	if it is contained
*	Returns true if object found, false otherwise
*/
function bool Find(Object InObjectReference, out int OutIndex)
{
	local R_ObjectList Node;
	local int Index;

	if(InObjectReference == None)
	{
		return false;
	}

	Node = Self;
	Index = 0;
	while(Node.Next != None)
	{
		if(Node.Next.ObjectReference == InObjectReference)
		{
			OutIndex = Index;
			return true;
		}
		Node = Node.Next;
		++Index;
	}

	OutIndex = -1;
	return false;
}
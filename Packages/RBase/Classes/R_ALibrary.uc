//==============================================================================
//  R_ALibrary
//  Library class
//
//  This is the base class for all Library classes used throughout RBase.
//  Libraries are single classes which define static functions that any object
//  can call at any time via static call.
//
//  Sample useage:
//  const MyLibrary = Class'R_AMyLibrary';  // Import the library
//  MyLibrary.Static.MyFunction;            // Call MyLibrary.MyFunction
//==============================================================================
class R_ALibrary extends Object abstract;
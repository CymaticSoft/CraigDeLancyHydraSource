/**
 *	HydraGameGametype
 *
 *	Creation date: 01/18/2013 03:39
 *	Copyright 2013, Craig A DeLancy
 */

class HydraGameGameType extends GameInfo
    config(Game);
 
defaultproperties
{
    PlayerControllerClass=class'HydraGamePlayerController'
    DefaultPawnClass=class'UDKBase.SimplePawn'
    bWaitingToStartMatch=true
    bDelayedStart=false
    HUDType=class'UDKBase.UDKHUD'
}
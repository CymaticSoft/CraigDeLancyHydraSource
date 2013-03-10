/*
 *
 *	HydraGamePlayerController
 *
 *	Creation date: 01/18/2013 03:39
 *	Copyright 2013, Craig A DeLancy
 */

class HydraGamePlayerController extends GamePlayerController;

var HydraGamePlayerInput RazerInput;
var quat QuatRotation;
var Rotator RightHandRot, LeftHandRot;
var Vector RightHandLoc, LeftHandLoc;
var float MYFOV, GroundSpeedModifier;
var int TeamIndex;
var bool bWeaponIgnored, bMovementIgnored, bLookIgnored;
var bool DoubleLL, DoubleLR, DoubleLU, DoubleLD;
var bool DoubleRL, DoubleRR, DoubleRU, DoubleRD;
var float JoyDoubleClickTime;
//Use GroundSpeedModifier to change your max speed, 1.5 for sprint, 0.5 for crouch. I handle it in the input, only works if GroundSpeedFix is true in input


//Input Section, all sorts of functions to assign commands to later.
//Button Presses

function RightTriggerPress()
{

}

function RightTriggerRelease()
{

}

function RightBumperPress()
{

}

function RightBumperRelease()
{

}

function RightStartPress()
{

}

function RightStartRelease()
{

}

function RightJoyPress()
{

}

function RightJoyRelease()
{

}

function RightB1Press()
{

}

function RightB1Release()
{

}

function RightB2Press()
{

}

function RightB2Release()
{

}

function RightB3Press()
{

}

function RightB3Release()
{

}

function RightB4Press()
{

}

function RightB4Release()
{

}

function LeftTriggerPress()
{

}

function LeftTriggerRelease()
{

}

function LeftBumperPress()
{

}

function LeftBumperRelease()
{

}

function LeftStartPress()
{

}

function LeftStartRelease()
{

}

function LeftJoyPress()
{

}

function LeftJoyRelease()
{

}

function LeftB1Press()
{

}

function LeftB1Release()
{

}

function LeftB2Press()
{

}

function LeftB2Release()
{

}

function LeftB3Press()
{

}

function LeftB3Release()
{

}

function LeftB4Press()
{

}

function LeftB4Release()
{

}

// Gesture Recognition
//Jabs First
Function RightPunchUR()
{

}

Function RightPunchUC()
{

}

Function RightPunchUL()
{

}

Function RightPunchCR()
{

}

Function RightPunchCC()
{

}

Function RightPunchCL()
{

}

Function RightPunchDR()
{

}

Function RightPunchDC()
{

}

Function RightPunchDL()
{

}

Function RightStop()
{

}

Function RightPullBack()
{

}

//NowSwings

Function RightSwingUR()
{

}

Function RightSwingUC()
{

}

Function RightSwingUL()
{

}

Function RightSwingCR()
{

}

Function RightSwingCC()
{

}

Function RightSwingCL()
{

}

Function RightSwingDR()
{

}

Function RightSwingDC()
{

}

Function RightSwingDL()
{

}

//NowFlicks

Function RightFlickUR()
{

}

Function RightFlickUC()
{

}

Function RightFlickUL()
{

}

Function RightFlickCR()
{

}

Function RightFlickCC()
{

}

Function RightFlickCL()
{

}

Function RightFlickDR()
{

}

Function RightFlickDC()
{

}

Function RightFlickDL()
{

}

//Jabs First
Function LeftPunchUR()
{

}

Function LeftPunchUC()
{

}

Function LeftPunchUL()
{

}

Function LeftPunchCR()
{

}

Function LeftPunchCC()
{

}

Function LeftPunchCL()
{

}

Function LeftPunchDR()
{

}

Function LeftPunchDC()
{

}

Function LeftPunchDL()
{

}

Function LeftStop()
{

}

Function LeftPullBack()
{

}

//NowSwings

Function LeftSwingUR()
{

}

Function LeftSwingUC()
{

}

Function LeftSwingUL()
{

}

Function LeftSwingCR()
{

}

Function LeftSwingCC()
{

}

Function LeftSwingCL()
{

}

Function LeftSwingDR()
{

}

Function LeftSwingDC()
{

}

Function LeftSwingDL()
{

}

//NowFlicks

Function LeftFlickUR()
{

}

Function LeftFlickUC()
{

}

Function LeftFlickUL()
{

}

Function LeftFlickCR()
{

}

Function LeftFlickCC()
{

}

Function LeftFlickCL()
{

}

Function LeftFlickDR()
{

}

Function LeftFlickDC()
{

}

Function LeftFlickDL()
{

}

//Joystick Clicks and Double Clicks

Function LUClick()
{
	if(DoubleLU==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleLU=True;
	SetTimer(JoyDoubleClickTime, False, 'LUUndouble');
	//Regular Click Funciton goes here
	}
}

Function LDClick()
{
	if(DoubleLD==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleLD=True;
	SetTimer(JoyDoubleClickTime, False, 'LDUndouble');
	//Regular Click Funciton goes here
	}
}

Function LRClick()
{
	if(DoubleLR==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleLR=True;
	SetTimer(JoyDoubleClickTime, False, 'LRUndouble');
	//Regular Click Funciton goes here
	}
}

Function LLClick()
{
	if(DoubleLL==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleLL=True;
	SetTimer(JoyDoubleClickTime, False, 'LLUndouble');
	//Regular Click Funciton goes here
	}
}

Function LUUndouble()
{
	DoubleLU=false;
}

Function LDUndouble()
{
	DoubleLD=false;
}

Function LRUndouble()
{
	DoubleLR=false;
}

Function LLUndouble()
{
	DoubleLL=false;
}

//Returning to center, not a stick-click
Function LCenter()
{

}

Function RUClick()
{
	if(DoubleRU==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleRU=True;
	SetTimer(JoyDoubleClickTime, False, 'RUUndouble');
	//Regular Click Funciton goes here
	}
}

Function RDClick()
{
	if(DoubleRD==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleRD=True;
	SetTimer(JoyDoubleClickTime, False, 'RDUndouble');
	//Regular Click Funciton goes here
	}
}

Function RRClick()
{
	if(DoubleRR==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleRR=True;
	SetTimer(JoyDoubleClickTime, False, 'RRUndouble');
	//Regular Click Funciton goes here
	}
}

Function RLClick()
{
	if(DoubleRL==True)
	{
	//DoubleClick Funtcion Goes Here
	}
	else
	{
	DoubleRL=True;
	SetTimer(JoyDoubleClickTime, False, 'RLUndouble');
	//Regular Click Funciton goes here
	}
}

Function RUUndouble()
{
	DoubleRU=false;
}

Function RDUndouble()
{
	DoubleRD=false;
}

Function RRUndouble()
{
	DoubleRR=false;
}

Function RLUndouble()
{
	DoubleRL=false;
}

//Returning to center, not a stick-click
Function RCenter()
{

}

event PlayerTick( float DeltaTime )
{
	super.PlayerTick(DeltaTime);
	MYFOV=FovAngle;
	if(HydraGamePlayerInput(PlayerInput).TheController!=Self)
	{
		HydraGamePlayerInput(PlayerInput).TheController=Self;
	}
}

Simulated Function PostBeginPlay()
{
	Super.PostBeginPlay();
	HydraGamePlayerInput(PlayerInput).TheController=Self;
	RazerInput=HydraGamePlayerInput(PlayerInput);
}

simulated exec function Duck()
{
	GroundSpeedModifier=0.5;
}

simulated exec function UnDuck()
{
	GroundSpeedModifier=1.0;
}




/**
 * Allow player controllers to adjust the acceleration in PlayerWalking
 *
 * @param NewAccel - the acceleration used by PlayerWalking::PlayerMove
 */
function AdjustPlayerWalkingMoveAccel(out vector NewAccel);

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}
	}

	event BeginState(Name PreviousStateName)
	{
		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}
	}

Begin:
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if( NewVolume.bWaterVolume )
		{
			GotoState( Pawn.WaterMovementState );
		}
		else
		{
			GotoState( Pawn.LandMovementState );
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration	= NewAccel;

		if( bPressedJump )
		{
			Pawn.DoJump( bUpdating );
			if( Pawn.Physics == PHYS_Falling )
			{
				GotoState(Pawn.LandMovementState);
			}
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local rotator OldRotation, ViewRotation;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		if ( Pawn.OnLadder != None )
		{
			NewAccel = PlayerInput.aForward*Pawn.OnLadder.ClimbDir;
		    if ( Pawn.OnLadder.bAllowLadderStrafing )
				NewAccel += PlayerInput.aStrafe*Y;
		}
		else
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	event BeginState(Name PreviousStateName)
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}

	event EndState(Name NextStateName)
	{
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			Pawn.ShouldCrouch(false);
		}
	}
}

// Player Driving a vehicle.
state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

	// Set the throttle, steering etc. for the vehicle based on the input provided
	function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
	{
		local Vehicle CurrentVehicle;

		CurrentVehicle = Vehicle(Pawn);
		if (CurrentVehicle != None)
		{
			//`log("Forward:"@InForward@" Strafe:"@InStrafe@" Up:"@InUp);
			bPressedJump = InJump;
			CurrentVehicle.SetInputs(InForward, -InStrafe, InUp);
			CheckJumpOrDuck();
		}
	}

	function PlayerMove( float DeltaTime )
	{
		// update 'looking' rotation
		UpdateRotation(DeltaTime);

		// TODO: Don't send things like aForward and aStrafe for gunners who don't need it
		// Only servers can actually do the driving logic.
		ProcessDrive(PlayerInput.RawJoyUp, PlayerInput.RawJoyRight, PlayerInput.aUp, bPressedJump);
		if (Role < ROLE_Authority)
		{
			ServerDrive(PlayerInput.RawJoyUp, PlayerInput.RawJoyRight, PlayerInput.aUp, bPressedJump, ((Rotation.Yaw & 65535) << 16) + (Rotation.Pitch & 65535));
		}

		bPressedJump = false;
	}

	unreliable server function ServerUse()
	{
		local Vehicle CurrentVehicle;

		CurrentVehicle = Vehicle(Pawn);
		CurrentVehicle.DriverLeave(false);
	}

	event BeginState(Name PreviousStateName)
	{
		CleanOutSavedMoves();
	}

	event EndState(Name NextStateName)
	{
		CleanOutSavedMoves();
	}
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
	{
		if ( Pawn.PhysicsVolume.bWaterVolume )
			Pawn.SetPhysics(PHYS_Swimming);
		else
			GotoState(Pawn.LandMovementState);
		return bUpdating;
	}

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Checkpoint;
		local vector X,Y,Z;

		if ( !Pawn.bCollideActors )
		{
			GotoState(Pawn.LandMovementState);
		}
		if (Pawn.Physics != PHYS_RigidBody)
		{
			if ( !NewVolume.bWaterVolume )
			{
				Pawn.SetPhysics(PHYS_Falling);
				if ( Pawn.Velocity.Z > 0 )
				{
					GetAxes(Rotation,X,Y,Z);
	 				Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
				    if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
				    {
					    Pawn.velocity.Z = Pawn.OutOfWaterZ; //set here so physics uses this for remainder of tick
					    GotoState(Pawn.LandMovementState);
				    }
				    else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
					    GotoState(Pawn.LandMovementState);
				    else //check if in deep water
				    {
					    Checkpoint = Pawn.Location;
					    Checkpoint.Z -= (Pawn.CylinderComponent.CollisionHeight + 6.0);
					    HitActor = Trace(HitLocation, HitNormal, Checkpoint, Pawn.Location, false);
					    if (HitActor != None)
						    GotoState(Pawn.LandMovementState);
					    else
					    {
						    SetTimer(0.7, false);
					    }
				    }
			    }
			}
			else
			{
				ClearTimer();
				Pawn.SetPhysics(PHYS_Swimming);
			}
		}
		else if (!NewVolume.bWaterVolume)
		{
			// if in rigid body, go to appropriate state, but don't modify pawn physics
			GotoState(Pawn.LandMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		Pawn.Acceleration = NewAccel;
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;

		if (Pawn == None)
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Rotation,X,Y,Z);

			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + PlayerInput.aUp*vect(0,0,1);
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			// Update rotation.
			oldRotation = Rotation;
			UpdateRotation( DeltaTime );

			if ( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}
			bPressedJump = false;
		}
	}

	event Timer()
	{
		if (!Pawn.PhysicsVolume.bWaterVolume && Role == ROLE_Authority)
		{
			GotoState(Pawn.LandMovementState);
		}

		ClearTimer();
	}

	event BeginState(Name PreviousStateName)
	{
		ClearTimer();
		if (Pawn.Physics != PHYS_RigidBody)
		{
			Pawn.SetPhysics(PHYS_Swimming);
		}
	}

Begin:
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + PlayerInput.aUp*vect(0,0,1);;
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);

		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}

	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}


defaultproperties
{
	InputClass=class'HydraGamePlayerInput'
	bWeaponIgnored=false
	bMovementIgnored=false
	bLookIgnored=false
	GroundSpeedModifier=1.0
	DesiredFOV=90
	DefaultFOV=90
	FovAngle=90
	DoubleLL=false
	DoubleLR=false
	DoubleLU=false
	DoubleLD=false
	DoubleRL=false
	DoubleRR=false
	DoubleRU=false
	DoubleRD=false
	JoyDoubleClickTime=0.15
}

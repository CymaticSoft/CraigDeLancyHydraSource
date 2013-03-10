/**
 *	HydraGamePlayerInput
 *
 *	Creation date: 01/18/2013 03:39
 *	Copyright 2013, Craig A DeLancy
 */
class HydraGamePlayerInput extends PlayerInput
   DLLBind(sixense);


const SIXENSE_BUTTON_BUMPER    = 128; //(0x01<<7)
const SIXENSE_BUTTON_JOYSTICK    = 256; //(0x01<<8)
const SIXENSE_BUTTON_1         = 32;  //(0x01<<5)
const SIXENSE_BUTTON_2         = 64;  //(0x01<<6)
const SIXENSE_BUTTON_3         = 8;   //(0x01<<3)
const SIXENSE_BUTTON_4         = 16;  //(0x01<<4)
const SIXENSE_BUTTON_START     = 1;   //(0x01<<0)

var bool bLogs;
var bool RightBumperOld, RightJoyOld, Right1Old, Right2Old, Right3Old, Right4Old, RightStartOld, RightTriggerOld;
var bool LeftBumperOld, LeftJoyOld, Left1Old, Left2Old, Left3Old, Left4Old, LeftStartOld, LeftTriggerOld, DockedOld, RDocked, LDocked;
var bool RightRClick, RightUClick, RightLClick, RightDClick, RightJoyCenter;
var bool LeftRClick, LeftUClick, LeftLClick, LeftDClick, LeftJoyCenter;
var bool OldLeft, OldRight, OldForward, OldBackward, BdoubleLeftWaiting, bDoubleRightWaiting, bDoubleBWaiting, bDoubleFWaiting, DoubleTimer;
var bool HydrasOff, GroundSpeedFix;
var int ActiveControllers;

//Relative Axis for gesture recognition
var vector RightUp, RightForward, RightRight, RightAverageVelocity, RightAverageAcceleration;
var vector LeftUp, LeftForward, LeftRight, LeftAverageVelocity, LeftAverageAcceleration;
var float RightAverageVADot, LeftAverageVADot, DistanceBetweenHands, MinimumGestureTime;    //Distance between hands may be useful for prying open doors instead of button mashing
var int RightGesture, LeftGesture;
var bool RightRecogEnabled, LeftRecogEnabled, BLeftGesture, BRightGesture;
//0 for draw back, 10 for stop, **look at your numpad** 5 for a straight punch, other single digits for angled punches, 18 for an uppercut, 16 for a right hook, 28 for flicking your wrist up and backwards, etc.

var float PointerSensitivity, DoubleListenTime, GestureVelocityThreshold;
var int MovementMode, AimMode, LastMoveMode, LastAimMode, LogCounter;
//Allows for several control schemes, 0 not using hydras, 1 left joy for movement, right for aim, 2 uses pointing for aiming and left hand tilt for movement, etc...

const SIXENSE_SUCCESS = 0;
const SIXENSE_FAILURE  = -1;

var vector RightHandPosition, LeftHandPosition, OldRightPos, OldLeftPos, RightVelocity, OldRightVelocity, LeftVelocity, OldLeftVelocity, RightAccel, LeftAccel, QRecoil;
var rotator RightHandRotation, LeftHandRotation;
Var vector RightHandPoint, LeftHandPoint, LeftHandTilt, RightHandTilt, RightJoyStick, LeftJoyStick;
var float RightTrigger, LeftTrigger, TiltSensitivity;
var HydraGamePlayerController TheController;

const SIXENSE_MAX_CONTROLLERS = 4;

struct sixenseControllerData {
  var float pos[3];
  var float rot_mat[9];
  var float joystick_x;
  var float joystick_y;
  var float trigger;
  var int buttons;
  var byte sequence_number;
  var float rot_quat[4];
  var byte firmware_revision[2];
  var byte hardware_revision[2];
  var byte packet_type[2];
  var byte magnetic_frequency[2];
  var int enabled;
  var int controller_index;
  var byte is_docked;
  var byte which_hand;
  var byte hemi_tracking_enabled;
};

struct sixenseAllControllerData {
	var sixenseControllerData controller[4];
};

var sixenseControllerData LData0, LData1, LData2, LData3, LData4, LData5, LData6, LData7, LData8, LData9;
var sixenseControllerData RData0, RData1, RData2, RData3, RData4, RData5, RData6, RData7, RData8, RData9;

`define m33el(x, y) `y + `x * 3

dllimport final function int sixenseInit( );
dllimport final function int sixenseExit( );

dllimport final function int sixenseGetMaxBases();
dllimport final function int sixenseSetActiveBase( int i );
dllimport final function int sixenseIsBaseConnected( int i );

dllimport final function int sixenseGetMaxControllers( );
dllimport final function int sixenseIsControllerEnabled( int which );
dllimport final function int sixenseGetNumActiveControllers( );

dllimport final function int sixenseGetHistorySize();

dllimport final function int sixenseGetData( int which, int index_back, out sixenseControllerData data );
dllimport final function int sixenseGetAllData( int index_back, out sixenseAllControllerData data );
dllimport final function int sixenseGetNewestData( int which, out sixenseControllerData data );
dllimport final function int sixenseGetAllNewestData( out sixenseAllControllerData data );

dllimport final function int sixenseSetHemisphereTrackingMode( int which_controller, int state );
dllimport final function int sixenseGetHemisphereTrackingMode( int which_controller, out int state );

dllimport final function int sixenseAutoEnableHemisphereTracking( int which_controller );

dllimport final function int sixenseSetHighPriorityBindingEnabled( int on_or_off );
dllimport final function int sixenseGetHighPriorityBindingEnabled( out int on_or_off );

dllimport final function int sixenseTriggerVibration( int controller_id, int duration_100ms, int pattern_id );

dllimport final function int sixenseSetFilterEnabled( int on_or_off );
dllimport final function int sixenseGetFilterEnabled( out int on_or_off );

dllimport final function int sixenseSetFilterParams( float near_range, float near_val, float far_range, float far_val );
dllimport final function int sixenseGetFilterParams( out float near_range, out float near_val, out float far_range, out float far_val );

dllimport final function int sixenseSetBaseColor( byte red, byte green, byte blue );
dllimport final function int sixenseGetBaseColor( out byte red, out byte green, out byte blue );

function InitInputSystem()
{
	local int Number;

	QRecoil=vect(0,0,0);
	super.InitInputSystem();
	number=sixenseInit();
	if(number==0)
	{
		`Log("SIXENSE_SUCCESS");
		//DefaultRazerModes so make no changes

	}
	else
	{
		//KeyboardNMouse
		`Log("SIXENSE_FAILURE");
		MovementMode=0;
		AimMode=0;
	}
}

function CloseSystem()
{
	local int Number;

	number=sixenseExit();
	if(number==0)
	{
		`Log("SIXENSE_SUCCESS");
		//DefaultRazerModes so make no changes

	}
	else
	{
		//KeyboardNMouse
		`Log("SIXENSE_FAILURE");

	}
}

Event CheckRightButtons()
{
	local sixenseControllerData Data;

	sixenseGetNewestData( 1, Data );
	RData9=RData8;
	RData8=Rdata7;
	RData7=RData6;
	RData6=RData5;
	RData5=RData4;
	RData4=RData3;
	RData3=RData2;
	Rdata2=Rdata1;
	Rdata1=Rdata0;
	Rdata0=Data;
	
	RightTrigger=Data.Trigger;
	
	If(Data.is_Docked!=0)
	{
		RDocked=True;
	}
	else
	{
		RDocked=False;
	}

	If(Data.Trigger>=0.5)
	{
		RightTriggerPressed(True);
	}
	else
	{
		RightTriggerPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_BUMPER) == SIXENSE_BUTTON_BUMPER)
	{
		RightBumperPressed(True);
	}
	else
	{
		RightBumperPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_START) == SIXENSE_BUTTON_START)
	{
		RightSTARTPressed(True);
	}
	else
	{
		RightSTARTPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_JOYSTICK) == SIXENSE_BUTTON_JOYSTICK)
	{
		RightJOYSTICKPressed(True);
	}
	else
	{
		RightJOYSTICKPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_1) == SIXENSE_BUTTON_1)
	{
		Right1Pressed(True);
	}
	else
	{
		Right1Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_2) == SIXENSE_BUTTON_2)
	{
		Right2Pressed(True);
	}
	else
	{
		Right2Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_3) == SIXENSE_BUTTON_3)
	{
		Right3Pressed(True);
	}
	else
	{
		Right3Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_4) == SIXENSE_BUTTON_4)
	{
		Right4Pressed(True);
	}
	else
	{
		Right4Pressed(False);
	}
	
}

Function RightTriggerPressed(bool IsPressed)
{

	if(IsPressed!=RightTriggerOld)
	{
		If(IsPressed==True)
		{
			TheController.RightTriggerPress();
		}
		else
		{
			TheController.RightTriggerRelease();
		}
	}

	RightTriggerOld=IsPressed;
}



Function RightBumperPressed(bool IsPressed)
{
	if(IsPressed!=RightBumperOld)
	{
		If(IsPressed==True)
		{
			TheController.RightBumperPress();
		}
		else
		{
			TheController.RightBumperRelease();
		}
	}
	
	RightBumperOld=IsPressed;
}

Function RightStartPressed(bool IsPressed)
{
	if(IsPressed!=RightStartOld)
	{
		If(IsPressed==True)
		{
			TheController.RightStartPress();
		}
		else
		{
			TheController.RightStartRelease();
		}
	}
	
	RightStartOld=IsPressed;
}

Function RightJoystickPressed(bool IsPressed)
{
	if(IsPressed!=RightJoyOld)
	{
		If(IsPressed==True)
		{
			TheController.RightJoyPress();
		}
		else
		{
			TheController.RightJoyRelease();
		}
	}
	
	RightJoyOld=IsPressed;
}

Function Right1Pressed(bool IsPressed)
{
	if(IsPressed!=Right1Old)
	{
		If(IsPressed==True)
		{
			TheController.RightB1Press();
		}
		else
		{
			TheController.RightB1Release();
		}
	}
	
	Right1Old=IsPressed;
}

Function Right2Pressed(bool IsPressed)
{
	if(IsPressed!=Right2Old)
	{
		If(IsPressed==True)
		{
			TheController.RightB2Press();
		}
		else
		{
			TheController.RightB2Release();
		}
	}
	
	Right2Old=IsPressed;
}

Function Right3Pressed(bool IsPressed)
{
	if(IsPressed!=Right3Old)
	{
		If(IsPressed==True)
		{
			TheController.RightB3Press();
		}
		else
		{
			TheController.RightB3Release();
		}
	}
	
	Right3Old=IsPressed;
}

Function Right4Pressed(bool IsPressed)
{
	if(IsPressed!=Right4Old)
	{
		If(IsPressed==True)
		{
			TheController.RightB4Press();
		}
		else
		{
			TheController.RightB4Release();
		}
	}
	
	Right4Old=IsPressed;
}

Event CheckLeftButtons()
{
	local sixenseControllerData Data;

	sixenseGetNewestData( 0, Data );
	LData9=LData8;
	LData8=Ldata7;
	LData7=LData6;
	LData6=LData5;
	LData5=LData4;
	LData4=LData3;
	LData3=LData2;
	Ldata2=Ldata1;
	LData1=LData0;
	Ldata0=Data;
	
	
	LeftTrigger=Data.Trigger;
	
	If(Data.is_Docked!=0)
	{
		LDocked=True;
	}
	else
	{
		LDocked=False;
	}
	
	If(Data.Trigger>=0.5)
	{
		LeftTriggerPressed(True);
	}
	else
	{
		LeftTriggerPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_BUMPER) == SIXENSE_BUTTON_BUMPER)
	{
		LeftBumperPressed(True);
	}
	else
	{
		LeftBumperPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_START) == SIXENSE_BUTTON_START)
	{
		LeftSTARTPressed(True);
	}
	else
	{
		LeftSTARTPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_JOYSTICK) == SIXENSE_BUTTON_JOYSTICK)
	{
		LeftJOYSTICKPressed(True);
	}
	else
	{
		LeftJOYSTICKPressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_1) == SIXENSE_BUTTON_1)
	{
		Left1Pressed(True);
	}
	else
	{
		Left1Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_2) == SIXENSE_BUTTON_2)
	{
		Left2Pressed(True);
	}
	else
	{
		Left2Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_3) == SIXENSE_BUTTON_3)
	{
		Left3Pressed(True);
	}
	else
	{
		Left3Pressed(False);
	}
	
	If((Data.Buttons & SIXENSE_BUTTON_4) == SIXENSE_BUTTON_4)
	{
		Left4Pressed(True);
	}
	else
	{
		Left4Pressed(False);
	}
	
}

Function LeftTriggerPressed(bool IsPressed)
{

	if(IsPressed!=LeftTriggerOld)
	{
		If(IsPressed==True)
		{
			TheController.LeftTriggerPress();
		}
		else
		{
			TheController.LeftTriggerRelease();
		}
	}

	LeftTriggerOld=IsPressed;
}

Function LeftBumperPressed(bool IsPressed)
{
	if(IsPressed!=LeftBumperOld)
	{
		If(IsPressed==True)
		{
			TheController.LeftBumperPress();
		}
		else
		{
			TheController.LeftBumperRelease();
		}
	}
	
	LeftBumperOld=IsPressed;
}

Function LeftStartPressed(bool IsPressed)
{
	if(IsPressed!=LeftStartOld)
	{
		If(IsPressed==True)
		{
			TheController.LeftStartPress();
		}
		else
		{
			TheController.LeftStartRelease();
		}
	}
	
	LeftStartOld=IsPressed;
}

Function LeftJoystickPressed(bool IsPressed)
{
	if(IsPressed!=LeftJoyOld)
	{
		If(IsPressed==True)
		{
			TheController.LeftJoyPress();
		}
		else
		{
			TheController.LeftJoyRelease();
		}
	}
	
	LeftJoyOld=IsPressed;
}

Function Left1Pressed(bool IsPressed)
{
	if(IsPressed!=Left1Old)
	{
		If(IsPressed==True)
		{
			TheController.LeftB1Press();
		}
		else
		{
			TheController.LeftB1Release();
		}
	}
	
	Left1Old=IsPressed;
}

Function Left2Pressed(bool IsPressed)
{
	if(IsPressed!=Left2Old)
	{
		If(IsPressed==True)
		{
			TheController.LeftB2Press();
		}
		else
		{
			TheController.LeftB2Release();
		}
	}
	
	Left2Old=IsPressed;
}

Function Left3Pressed(bool IsPressed)
{
	if(IsPressed!=Left3Old)
	{
		If(IsPressed==True)
		{
			TheController.LeftB3Press();
		}
		else
		{
			TheController.LeftB3Release();
		}
	}
	
	Left3Old=IsPressed;
}

Function Left4Pressed(bool IsPressed)
{
	if(IsPressed!=Left4Old)
	{
		If(IsPressed==True)
		{
			TheController.LeftB4Press();
		}
		else
		{
			TheController.LeftB4Release();
		}
	}
	
	Left4Old=IsPressed;
}

Event Vector GetPositionRight()
{
local vector RightPos, Pos;
local sixenseControllerData Data;

	sixenseGetNewestData( 1, Data );
	Pos.X = -Data.pos[2]; 
	Pos.Y = Data.pos[0]; 
	Pos.Z = Data.pos[1];

	RightPos=Pos;
	return RightPos;
}

Event Rotator GetRotationRight()
{
local sixenseControllerData Data;
local Matrix sxMat;
local Rotator RightRot;

	sixenseGetNewestData( 1, Data );	
   
   //X Basis Vector
   sxMat.XPlane.X = data.rot_mat[ `m33el(2, 2) ];
   sxMat.XPlane.Y = -data.rot_mat[ `m33el(2, 0) ];
   sxMat.XPlane.Z = -data.rot_mat[ `m33el(2, 1) ];
   sxMat.XPlane.W = 0;
   
   //Y Basis Vector
   sxMat.YPlane.X = -data.rot_mat[ `m33el(0, 2) ];
   sxMat.YPlane.Y = data.rot_mat[ `m33el(0, 0) ];
   sxMat.YPlane.Z = data.rot_mat[ `m33el(0, 1) ];
   sxMat.YPlane.W = 0;
   
   //Z Basis Vector
   sxMat.ZPlane.X = -data.rot_mat[ `m33el(1, 2) ];
   sxMat.ZPlane.Y = data.rot_mat[ `m33el(1, 0) ];
   sxMat.ZPlane.Z = data.rot_mat[ `m33el(1, 1) ];
   sxMat.ZPlane.W = 0;
   
   //W Basis Vector
   sxMat.WPlane.X = 0;
   sxMat.WPlane.Y = 0;
   sxMat.WPlane.Z = 0;
   sxMat.WPlane.W = 1;

	RightRot=MatrixGetRotator(sxMat);

	return RightRot;
}

Event Vector GetPositionLeft()
{
local vector LeftPos, Pos;
local sixenseControllerData Data;

	sixenseGetNewestData( 0, Data );
	Pos.X = -Data.pos[2]; 
	Pos.Y = Data.pos[0]; 
	Pos.Z = Data.pos[1];

	LeftPos=Pos;
	return LeftPos;
}

Event Rotator GetRotationLeft()
{
local sixenseControllerData Data;
local Matrix sxMat;
local Rotator LeftRot;

	sixenseGetNewestData( 0, Data );	
   
   //X Basis Vector
   sxMat.XPlane.X = data.rot_mat[ `m33el(2, 2) ];
   sxMat.XPlane.Y = -data.rot_mat[ `m33el(2, 0) ];
   sxMat.XPlane.Z = -data.rot_mat[ `m33el(2, 1) ];
   sxMat.XPlane.W = 0;
   
   //Y Basis Vector
   sxMat.YPlane.X = -data.rot_mat[ `m33el(0, 2) ];
   sxMat.YPlane.Y = data.rot_mat[ `m33el(0, 0) ];
   sxMat.YPlane.Z = data.rot_mat[ `m33el(0, 1) ];
   sxMat.YPlane.W = 0;
   
   //Z Basis Vector
   sxMat.ZPlane.X = -data.rot_mat[ `m33el(1, 2) ];
   sxMat.ZPlane.Y = data.rot_mat[ `m33el(1, 0) ];
   sxMat.ZPlane.Z = data.rot_mat[ `m33el(1, 1) ];
   sxMat.ZPlane.W = 0;
   
   //W Basis Vector
   sxMat.WPlane.X = 0;
   sxMat.WPlane.Y = 0;
   sxMat.WPlane.Z = 0;
   sxMat.WPlane.W = 1;

	LeftRot=MatrixGetRotator(sxMat);

	return LeftRot;
}

Event Float GetRightJoyX()
{
local sixenseControllerData Data;
local Float Joy;
	sixenseGetNewestData( 1, Data );	
	Joy=data.Joystick_X;
	return Joy;
}

Event Float GetRightJoyY()
{
local sixenseControllerData Data;
local Float Joy;
	sixenseGetNewestData( 1, Data );	
	Joy=data.Joystick_Y;
	return Joy;
}
	
Event Float GetLeftJoyX()
{
local sixenseControllerData Data;
local Float Joy;
	sixenseGetNewestData( 0, Data );	
	Joy=data.Joystick_X;
	return Joy;
}

Event Float GetLeftJoyY()
{
local sixenseControllerData Data;
local Float Joy;
	sixenseGetNewestData( 0, Data );	
	Joy=data.Joystick_Y;
	return Joy;
}

Event Vector GetPosition(sixenseControllerData Data)
{
	local vector Pos;

	Pos.X = -Data.pos[2]; 
	Pos.Y = Data.pos[0]; 
	Pos.Z = Data.pos[1];

	return Pos;
}

Function DoGestureRecognitionRight(float DeltaTime)
{
	Local Vector Pos0, Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8, Pos9;
	Local Vector Vel1, Vel2, Vel3, Vel4, Vel5, Vel6, Vel7, Vel8, Vel9;
	Local Vector A1, A2, A3, A4, A5, A6, A7, A8;
	local Float VANormed;
	
	Pos9=GetPosition(RData9);
	Pos8=GetPosition(RData8);
	Vel9=(Pos8-Pos9)/DeltaTime;
	Pos7=GetPosition(RData7);
	Vel8=(Pos7-Pos8)/DeltaTime;
	Pos6=GetPosition(RData6);
	Vel7=(Pos6-Pos7)/DeltaTime;
	Pos5=GetPosition(RData5);
	Vel6=(Pos5-Pos6)/DeltaTime;
	Pos4=GetPosition(RData4);
	Vel5=(Pos4-Pos5)/DeltaTime;
	Pos3=GetPosition(RData3);
	Vel4=(Pos3-Pos4)/DeltaTime;
	Pos2=GetPosition(RData2);
	Vel3=(Pos2-Pos3)/DeltaTime;
	Pos1=GetPosition(RData1);
	Vel2=(Pos1-Pos2)/DeltaTime;
	Pos0=GetPosition(RData0);
	Vel1=(Pos0-Pos1)/DeltaTime;
	
	RightAverageVelocity=((Vel1+Vel2+Vel3+Vel4+Vel5+Vel6+Vel7+Vel8+Vel9)/9);
	//RightAverageVelocity=RightVelocity;
	
	A8=(Vel8-Vel9)/DeltaTime;
	A7=(Vel7-Vel8)/DeltaTime;
	A6=(Vel6-Vel7)/DeltaTime;
	A5=(Vel5-Vel6)/DeltaTime;
	A4=(Vel4-Vel5)/DeltaTime;
	A3=(Vel3-Vel4)/DeltaTime;
	A2=(Vel2-Vel3)/DeltaTime;
	A1=(Vel1-Vel2)/DeltaTime;

	RightAverageAcceleration=((A1+A2+A3+A4+A5+A6+A7+A8)/8);
	//RightAverageAcceleration=RightAccel;
	
	VANormed=(Normal(RightAverageVelocity)) DOT (Normal(RightAverageAcceleration));
	RightAverageVADot=VANormed;
	
	If(bLogs==true && LogCounter==29)
	{
		//`Log("RightVA"$VANormed);
	}
	
	DetermineRightGesture();
}

Function DetermineRightGesture()
{
	local float DotUR, DotUC, DotUL, DotCR, DotCC, DotCL, DotDR, DotDC, DotDL;
	Local Int Gesture;

	If(RightAverageVADot>0.5 && VSize(RightAverageVelocity)>=GestureVelocityThreshold)
	{
		//Acceleration and Velocity are in line with each other, this is a straight gesture like a jab
		if(RightAverageVelocity.X<0)
		{
			Gesture=0;
		}
		else
		{
			DotUR=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,1,1))));
			DotUC=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,0,1))));
			DotUL=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,-1,1))));
			DotCR=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,1,0))));
			DotCC=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,0,0))));
			DotCL=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,-1,0))));
			DotDR=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,1,-1))));
			DotDC=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,0,-1))));
			DotDL=((Normal(RightAverageVelocity)) DOT (Normal(Vect(1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=9;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=8;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=7;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=6;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=5;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=4;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=3;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=2;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=1;
			}
			Else
			{
				Gesture=5;
			}
		}
	}
	Else if(RightAverageVADot<0.5 && RightAverageVADot>(-0.6) && VSize(RightAverageVelocity)>GestureVelocityThreshold)
	{
		//Acceleration is at an angle from velocity indicated a curved motion, like a hook
		if(RightAverageVelocity.X<0)
		{
			//Then we are flicking backwards
			DotUR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,1,1))));
			DotUC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,0,1))));
			DotUL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,-1,1))));
			DotCR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,1,0))));
			DotCC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,0,0))));
			DotCL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,-1,0))));
			DotDR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,1,-1))));
			DotDC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,0,-1))));
			DotDL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(-1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=21;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=22;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=23;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=24;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=25;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=26;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=27;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=28;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=29;
			}
			Else
			{
				Gesture=25;
			}
		}
		else
		{
			//SwingingForwards

			DotUR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,1,1))));
			DotUC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,0,1))));
			DotUL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,-1,1))));
			DotCR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,1,0))));
			DotCC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,0,0))));
			DotCL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,-1,0))));
			DotDR=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,1,-1))));
			DotDC=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,0,-1))));
			DotDL=((Normal(RightAverageAcceleration)) DOT (Normal(Vect(1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=11;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=12;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=13;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=14;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=15;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=16;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=17;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=18;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=19;
			}
			Else
			{
				Gesture=15;
			}
		}
	}
	Else
	{
		//Acceleration is opposite velocity, indicating a sudden stop
		Gesture=10;
	}
	
	If(Gesture!=RightGesture )
	{
		//This means we have performed a new action and are not just continuing an action
		RightGesture=Gesture;
		PerformRightGesture();
		If(bLogs==true)
		{
			`Log("New_RGesture"$RightGesture);
		}

	}
}

Function PerformRightGesture()
{
	If(RightGesture==0)
	{
		TheController.RightPullBack();
	}
	else If(RightGesture==10)
	{
		TheController.RightStop();
	}
	else If(RightGesture<10)
	{
		If(RightGesture==9)
		{
			TheController.RightPunchUR();
		}
		else If(RightGesture==8)
		{
			TheController.RightPunchUC();
		}
		else If(RightGesture==7)
		{
			TheController.RightPunchUL();
		}
		else If(RightGesture==6)
		{
			TheController.RightPunchCR();
		}
		else If(RightGesture==5)
		{
			TheController.RightPunchCC();
		}
		else If(RightGesture==4)
		{
			TheController.RightPunchCL();
		}
		else If(RightGesture==3)
		{
			TheController.RightPunchDR();
		}
		else If(RightGesture==2)
		{
			TheController.RightPunchDC();
		}
		else If(RightGesture==1)
		{
			TheController.RightPunchDL();
		}
	}
	else If(RightGesture<20)
	{
		If(RightGesture==19)
		{
			TheController.RightSwingUR();
		}
		else If(RightGesture==18)
		{
			TheController.RightSwingUC();
		}
		else If(RightGesture==17)
		{
			TheController.RightSwingUL();
		}
		else If(RightGesture==16)
		{
			TheController.RightSwingCR();
		}
		else If(RightGesture==15)
		{
			TheController.RightSwingCC();
		}
		else If(RightGesture==14)
		{
			TheController.RightSwingCL();
		}
		else If(RightGesture==13)
		{
			TheController.RightSwingDR();
		}
		else If(RightGesture==12)
		{
			TheController.RightSwingDC();
		}
		else If(RightGesture==11)
		{
			TheController.RightSwingDL();
		}
	}
	else If(RightGesture<30)
	{
		If(RightGesture==29)
		{
			TheController.RightFlickUR();
		}
		else If(RightGesture==28)
		{
			TheController.RightFlickUC();
		}
		else If(RightGesture==27)
		{
			TheController.RightFlickUL();
		}
		else If(RightGesture==26)
		{
			TheController.RightFlickCR();
		}
		else If(RightGesture==25)
		{
			TheController.RightFlickCC();
		}
		else If(RightGesture==24)
		{
			TheController.RightFlickCL();
		}
		else If(RightGesture==23)
		{
			TheController.RightFlickDR();
		}
		else If(RightGesture==22)
		{
			TheController.RightFlickDC();
		}
		else If(RightGesture==21)
		{
			TheController.RightFlickDL();
		}
	}
}


Function DoGestureRecognitionLeft(float DeltaTime)
{

	Local Vector Pos0, Pos1, Pos2, Pos3, Pos4, Pos5, Pos6, Pos7, Pos8, Pos9;
	Local Vector Vel1, Vel2, Vel3, Vel4, Vel5, Vel6, Vel7, Vel8, Vel9;
	Local Vector A1, A2, A3, A4, A5, A6, A7, A8;
	local Float VANormed;
	
	Pos9=GetPosition(LData9);
	Pos8=GetPosition(LData8);
	Vel9=(Pos8-Pos9)/DeltaTime;
	Pos7=GetPosition(LData7);
	Vel8=(Pos7-Pos8)/DeltaTime;
	Pos6=GetPosition(LData6);
	Vel7=(Pos6-Pos7)/DeltaTime;
	Pos5=GetPosition(LData5);
	Vel6=(Pos5-Pos6)/DeltaTime;
	Pos4=GetPosition(LData4);
	Vel5=(Pos4-Pos5)/DeltaTime;
	Pos3=GetPosition(LData3);
	Vel4=(Pos3-Pos4)/DeltaTime;
	Pos2=GetPosition(LData2);
	Vel3=(Pos2-Pos3)/DeltaTime;
	Pos1=GetPosition(LData1);
	Vel2=(Pos1-Pos2)/DeltaTime;
	Pos0=GetPosition(LData0);
	Vel1=(Pos0-Pos1)/DeltaTime;
	
	LeftAverageVelocity=((Vel1+Vel2+Vel3+Vel4+Vel5+Vel6+Vel7+Vel8+Vel9)/9);
	
	A8=(Vel8-Vel9)/DeltaTime;
	A7=(Vel7-Vel8)/DeltaTime;
	A6=(Vel6-Vel7)/DeltaTime;
	A5=(Vel5-Vel6)/DeltaTime;
	A4=(Vel4-Vel5)/DeltaTime;
	A3=(Vel3-Vel4)/DeltaTime;
	A2=(Vel2-Vel3)/DeltaTime;
	A1=(Vel1-Vel2)/DeltaTime;

	LeftAverageAcceleration=((A1+A2+A3+A4+A5+A6+A7+A8)/8);

	VANormed=(Normal(LeftAverageVelocity)) DOT (Normal(LeftAverageAcceleration));
	LeftAverageVADot=VANormed;
	DetermineLeftGesture();
}

Function DetermineLeftGesture()
{
	local float DotUR, DotUC, DotUL, DotCR, DotCC, DotCL, DotDR, DotDC, DotDL;
	Local Int Gesture;
	
	If(LeftAverageVADot>0.5 && VSize(LeftAverageVelocity)>GestureVelocityThreshold)
	{
		//Acceleration and Velocity are in line with each other, this is a straight gesture like a jab
		if(LeftAverageVelocity.X<0)
		{
			Gesture=0;
		}
		else
		{
			DotUR=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,1,1))));
			DotUC=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,0,1))));
			DotUL=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,-1,1))));
			DotCR=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,1,0))));
			DotCC=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,0,0))));
			DotCL=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,-1,0))));
			DotDR=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,1,-1))));
			DotDC=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,0,-1))));
			DotDL=((Normal(LeftAverageVelocity)) DOT (Normal(Vect(1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=9;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=8;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=7;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=6;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=5;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=4;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=3;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=2;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=1;
			}
			Else
			{
				Gesture=5;
			}
		}
	}
	Else if(LeftAverageVADot<0.5 && LeftAverageVADot>(-0.6) && VSize(LeftAverageVelocity)>GestureVelocityThreshold)
	{
		//Acceleration is at an angle from velocity indicated a curved motion, like a hook
		if(LeftAverageVelocity.X<0)
		{
			//Then we are flicking backwards
			DotUR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,1,1))));
			DotUC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,0,1))));
			DotUL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,-1,1))));
			DotCR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,1,0))));
			DotCC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,0,0))));
			DotCL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,-1,0))));
			DotDR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,1,-1))));
			DotDC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,0,-1))));
			DotDL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(-1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=21;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=22;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=23;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=24;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=25;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=26;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=27;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=28;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=29;
			}
			Else
			{
				Gesture=25;
			}
		}
		else
		{
			//SwingingForwards
			DotUR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,1,1))));
			DotUC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,0,1))));
			DotUL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,-1,1))));
			DotCR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,1,0))));
			DotCC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,0,0))));
			DotCL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,-1,0))));
			DotDR=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,1,-1))));
			DotDC=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,0,-1))));
			DotDL=((Normal(LeftAverageAcceleration)) DOT (Normal(Vect(1,-1,-1))));
		
			If(DotUR>DotUC && DotUR>DotUL && DotUR>DotCR && DotUR>DotCC && DotUR>DotCL && DotUR>DotDR && DotUR>DotDC && DotUR>DotDL)
			{
				Gesture=11;
			}
			Else If(DotUC>DotUR && DotUC>DotUL && DotUC>DotCR && DotUC>DotCC && DotUC>DotCL && DotUC>DotDR && DotUC>DotDC && DotUC>DotDL)
			{
				Gesture=12;
			}
			Else If(DotUL>DotUR && DotUL>DotUC && DotUL>DotCR && DotUL>DotCC && DotUL>DotCL && DotUL>DotDR && DotUL>DotDC && DotUL>DotDL)
			{
				Gesture=13;
			}
			Else If(DotCR>DotUR && DotCR>DotUL && DotCR>DotUC && DotCR>DotCC && DotCR>DotCL && DotCR>DotDR && DotCR>DotDC && DotCR>DotDL)
			{
				Gesture=14;
			}
			Else If(DotCC>DotUR && DotCC>DotUL && DotCC>DotCR && DotCC>DotUC && DotCC>DotCL && DotCC>DotDR && DotCC>DotDC && DotCC>DotDL)
			{
				Gesture=15;
			}
			Else If(DotCL>DotUR && DotCL>DotUL && DotCL>DotCR && DotCL>DotCC && DotCL>DotUC && DotCL>DotDR && DotCL>DotDC && DotCL>DotDL)
			{
				Gesture=16;
			}
			Else If(DotDR>DotUR && DotDR>DotUL && DotDR>DotCR && DotDR>DotCC && DotDR>DotCL && DotDR>DotUC && DotDR>DotDC && DotDR>DotDL)
			{
				Gesture=17;
			}
			Else If(DotDC>DotUR && DotDC>DotUL && DotDC>DotCR && DotDC>DotCC && DotDC>DotCL && DotDC>DotDR && DotDC>DotUC && DotDC>DotDL)
			{
				Gesture=18;
			}
			Else If(DotDL>DotUR && DotDL>DotUL && DotDL>DotCR && DotDL>DotCC && DotDL>DotCL && DotDL>DotDR && DotDL>DotDC && DotDL>DotUC)
			{
				Gesture=19;
			}
			Else
			{
				Gesture=15;
			}
		}
	}
	Else
	{
		//Acceleration is opposite velocity, indicating a sudden stop
		Gesture=10;
	}
	
	
	If(Gesture!=LeftGesture)
	{
		//This means we have performed a new action and are not just continuing an action
		LeftGesture=Gesture;
		PerformLeftGesture();
		If(bLogs==true)
		{
			`Log("New_LGesture"$LeftGesture);
		}
	}
}




Function PerformLeftGesture()
{
	If(LeftGesture==0)
	{
		TheController.LeftPullBack();
	}
	else If(LeftGesture==10)
	{
		TheController.LeftStop();
	}
	else If(LeftGesture<10)
	{
		If(LeftGesture==9)
		{
			TheController.LeftPunchUR();
		}
		else If(LeftGesture==8)
		{
			TheController.LeftPunchUC();
		}
		else If(LeftGesture==7)
		{
			TheController.LeftPunchUL();
		}
		else If(LeftGesture==6)
		{
			TheController.LeftPunchCR();
		}
		else If(LeftGesture==5)
		{
			TheController.LeftPunchCC();
		}
		else If(LeftGesture==4)
		{
			TheController.LeftPunchCL();
		}
		else If(LeftGesture==3)
		{
			TheController.LeftPunchDR();
		}
		else If(LeftGesture==2)
		{
			TheController.LeftPunchDC();
		}
		else If(LeftGesture==1)
		{
			TheController.LeftPunchDL();
		}
	}
	else If(LeftGesture<20)
	{
		If(LeftGesture==19)
		{
			TheController.LeftSwingUR();
		}
		else If(LeftGesture==18)
		{
			TheController.LeftSwingUC();
		}
		else If(LeftGesture==17)
		{
			TheController.LeftSwingUL();
		}
		else If(LeftGesture==16)
		{
			TheController.LeftSwingCR();
		}
		else If(LeftGesture==15)
		{
			TheController.LeftSwingCC();
		}
		else If(LeftGesture==14)
		{
			TheController.LeftSwingCL();
		}
		else If(LeftGesture==13)
		{
			TheController.LeftSwingDR();
		}
		else If(LeftGesture==12)
		{
			TheController.LeftSwingDC();
		}
		else If(LeftGesture==11)
		{
			TheController.LeftSwingDL();
		}
	}
	else If(LeftGesture<30)
	{
		If(LeftGesture==29)
		{
			TheController.LeftFlickUR();
		}
		else If(LeftGesture==28)
		{
			TheController.LeftFlickUC();
		}
		else If(LeftGesture==27)
		{
			TheController.LeftFlickUL();
		}
		else If(LeftGesture==26)
		{
			TheController.LeftFlickCR();
		}
		else If(LeftGesture==25)
		{
			TheController.LeftFlickCC();
		}
		else If(LeftGesture==24)
		{
			TheController.LeftFlickCL();
		}
		else If(LeftGesture==23)
		{
			TheController.LeftFlickDR();
		}
		else If(LeftGesture==22)
		{
			TheController.LeftFlickDC();
		}
		else If(LeftGesture==21)
		{
			TheController.LeftFlickDL();
		}
	}
}

// Postprocess the player's input.
event PlayerInput( float DeltaTime )
{
	local float FOVScale, TimeScale;
	local bool Docked;
	OldRightPos=RightHandPosition;
	OldRightVelocity=RightVelocity;
	OldLeftPos=LeftHandPosition;
	OldLeftVelocity=LeftVelocity;
	
	CheckRightButtons();
	CheckLeftButtons();
	
	RightHandRotation=GetRotationRight();
	LeftHandPosition=GetPositionLeft();
	LeftHandRotation=GetRotationLeft();
	RightHandPosition=GetPositionRight();
	
	DistanceBetweenHands=(VSize(RightHandPosition-LeftHandPosition));
	
	GetAxes(RightHandRotation, RightForward, RightRight, RightUp); 
	GetAxes(LeftHandRotation, LeftForward, LeftRight, LeftUp); 
	
	RightVelocity=(RightHandPosition/DeltaTime-OldRightPos/DeltaTime);
	RightAccel=(RightVelocity-OldrightVelocity)/DeltaTime;
	
	LeftVelocity=(LeftHandPosition/DeltaTime-OldLeftPos/DeltaTime);
	LeftAccel=(LeftVelocity-OldLeftVelocity)/DeltaTime;
	
	
	if(RightRecogEnabled==True)
	{
	DoGestureRecognitionRight(DeltaTime);
	}
	
	if(LeftRecogEnabled==True)
	{
	DoGestureRecognitionLeft(DeltaTime);
	}
	
	if(RDocked!=LDocked)
	{
		Docked=True;
	}
	else if(RDocked==LDocked && LDocked==false)
	{
		Docked=False;
	}
	else
	{
		Docked=True;
	}
	
	If(Docked!=DockedOld)
	{
		if(Docked==True)
		{
			Dock();
		}
		else
		{
			UnDock();
		}
	}
	
	DockedOld=Docked;
	
	//GetRightTilt
	if(RightHandRotation.Roll<0)
	{
		RightHandTilt.Y=-TiltSensitivity*square( -1*(Clamp(RightHandRotation.Roll, -6000, 6000)*0.001) );
	}
	else
	{
		RightHandTilt.Y=TiltSensitivity*square( (Clamp(RightHandRotation.Roll, -6000, 6000)*0.001) );
	}
	
	if(RightHandRotation.Pitch<0)
	{
		RightHandTilt.X=TiltSensitivity*square( -1*(Clamp(RightHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	else
	{
		RightHandTilt.X=-TiltSensitivity*square( (Clamp(RightHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	
	RightHandTilt.Z=0;
	
	//GetLeftTilt
	if(LeftHandRotation.Roll<0)
	{
		LeftHandTilt.Y=-TiltSensitivity*square( -1*(Clamp(LeftHandRotation.Roll, -6000, 6000)*0.001) );
	}
	else
	{
		LeftHandTilt.Y=TiltSensitivity*square( (Clamp(LeftHandRotation.Roll, -6000, 6000)*0.001) );
	}
	
	if(LeftHandRotation.Pitch<0)
	{
		LeftHandTilt.X=TiltSensitivity*square( -1*(Clamp(LeftHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	else
	{
		LeftHandTilt.X=-TiltSensitivity*square( (Clamp(LeftHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	
	LeftHandTilt.Z=0;
	
	RightJoyStick.Z=0;
	RightJoyStick.X=GetRightJoyX();
	RightJoyStick.Y=GetRightJoyY();
	
	LeftJoyStick.Z=0;
	LeftJoyStick.X=GetLeftJoyX();
	LeftJoyStick.Y=GetLeftJoyY();
	
	If(RightJoyCenter==True)
	{
		if(RightJoyStick.Y>0.7)
		{
			RightJoyCenter=False;
			RightUClick=True;
			TheController.RUClick();
		}
		if(RightJoyStick.Y<-0.7)
		{
			RightJoyCenter=False;
			RightDClick=True;
			TheController.RDClick();
		}
		if(RightJoyStick.X>0.7)
		{
			RightJoyCenter=False;
			RightRClick=True;
			TheController.RRClick();
		}
		if(RightJoyStick.X<-0.7)
		{
			RightJoyCenter=False;
			RightLClick=True;
			TheController.RLClick();
		}
	}
	Else
	{
		if(RightJoyStick.Y>-0.7 && RightJoyStick.Y<0.7 && RightJoyStick.X>-0.7 && RightJoyStick.X<0.7)
		{
			RightLClick=False;
			RightUClick=False;
			RightRClick=False;
			RightJoyCenter=True;
			RightDClick=False;
			TheController.RCenter();
		}
	}
	
	If(LeftJoyCenter==True)
	{
		if(LeftJoyStick.Y>0.7)
		{
			LeftJoyCenter=False;
			LeftUClick=True;
			TheController.LUClick();
		}
		if(LeftJoyStick.Y<-0.7)
		{
			LeftJoyCenter=False;
			LeftDClick=True;
			TheController.LDClick();
		}
		if(LeftJoyStick.X>0.7)
		{
			LeftJoyCenter=False;
			LeftRClick=True;
			TheController.LRClick();
		}
		if(LeftJoyStick.X<-0.7)
		{
			LeftJoyCenter=False;
			LeftLClick=True;
			TheController.LLClick();
		}
	}
	Else
	{
		if(LeftJoyStick.Y>-0.7 && LeftJoyStick.Y<0.7 && LeftJoyStick.X>-0.7 && LeftJoyStick.X<0.7)
		{
			LeftLClick=False;
			LeftUClick=False;
			LeftRClick=False;
			LeftJoyCenter=True;
			LeftDClick=False;
			TheController.LCenter();
		}
	}
	
	if( MovementMode==1 )
	{
		if(GroundSpeedFix==True)
		{
			TheController.Pawn.GroundSpeed=TheController.Pawn.Default.GroundSpeed*VSize(LeftJoyStick)*TheController.GroundSpeedModifier;
		}
		aBaseY=LeftJoyStick.Y;
		aStrafe=LeftJoyStick.X;	
	}
	else if( MovementMode==2 )
	{
		if(GroundSpeedFix==True)
		{
			TheController.Pawn.GroundSpeed=TheController.Pawn.Default.GroundSpeed*VSize(LeftHandTilt)*TheController.GroundSpeedModifier;
		}
		//Tilt is in unreal space, not joy space
		aBaseY=LeftHandTilt.X;
		aStrafe=LeftHandTilt.Y;
	}
	
	//GetRightPoint
	if(RightHandRotation.Yaw<0)
	{
		RightHandPoint.X=-PointerSensitivity*square( -1*(Clamp(RightHandRotation.Yaw, -6000, 6000)*0.001) );
	}
	else
	{
		RightHandPoint.X=PointerSensitivity*square( (Clamp(RightHandRotation.Yaw, -6000, 6000)*0.001) );
	}
	
	if(RightHandRotation.Pitch<0)
	{
		RightHandPoint.Y=PointerSensitivity*square( -1*(Clamp(RightHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	else
	{
		RightHandPoint.Y=-PointerSensitivity*square( (Clamp(RightHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	
	RightHandPoint.Z=0;
	
	//GetLeftPoint
	if(LeftHandRotation.Yaw<0)
	{
		LeftHandPoint.X=-PointerSensitivity*square( -1*(Clamp(LeftHandRotation.Yaw, -6000, 6000)*0.001) );
	}
	else
	{
		LeftHandPoint.X=PointerSensitivity*square( (Clamp(LeftHandRotation.Yaw, -6000, 6000)*0.001) );
	}
	
	if(LeftHandRotation.Pitch<0)
	{
		LeftHandPoint.Y=PointerSensitivity*square( -1*(Clamp(LeftHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	else
	{
		LeftHandPoint.Y=-PointerSensitivity*square( (Clamp(LeftHandRotation.Pitch, -6000, 6000)*0.001) );
	}
	
	LeftHandPoint.Z=0;
	
	//If one hand is working, the other should be too, so I don't log both
	
	if(bLogs==true && LogCounter>30)
	{
		//ActiveControllers=sixenseIsControllerEnabled( 1 );
		//`log("Controller"$ActiveControllers);
		//`log("LeftTiltY"$LeftHandTilt.Y);
		//`log("LeftTiltX"$LeftHandTilt.X);
	
		//`log("RightPointX"$RightHandPoint.X);
		//`log("RightPointY"$RightHandPoint.Y);
	
		//`log("RightJoyX"$RightJoyStick.X);
		//`log("RightJoyY"$RightJoyStick.Y);
	
		//`log("RVZ"$LeftAverageVelocity.Z$"RVY"$LeftAverageVelocity.Y$"RVX"$LeftAverageVelocity.X);
		//`log("RAZ"$RightAverageAcceleration.Z$"RAY"$RightAverageAcceleration.Y$"RAX"$RightAverageAcceleration.X);
		
		//`log("RV"$VSize(RightVelocity));
		//`log("RGesture"$(RightGesture));
		//`log("RAZ"$RightAccel.Z);
		//`log("RAY"$RightAccel.Y);
		//`log("RAX"$RightAccel.X);
	
		LogCounter=0;
	}
	else
	{
		LogCounter+=1;
	}

	if ( bEnableMouseSmoothing )
	{
		aMouseX = SmoothMouse(aMouseX, DeltaTime,bXAxis,0);
		aMouseY = SmoothMouse(aMouseY, DeltaTime,bYAxis,1);
	}
	
	If(AimMode==0)
	{
		aTurn=PointerSensitivity*1.5*aMouseX;
		aLookUp=-1*PointerSensitivity*1.5*aMouseY;
	}
	If(AimMode==1)
	{
		aTurn=GetRightJoyX();
		aLookUp=GetRightJoyY();
	}
	Else If(AimMode==2)
	{
		aTurn=RightHandPoint.X;
		aLookUp=RightHandPoint.Y;
	}
	
	//You can add to this QRecoil from your weapon class an it will be processed here (X is left, Y is up, don't use Z
	if(QRecoil!=vect(0,0,0))
	{
		aLookUp+=QRecoil.Y;
		aTurn+=QRecoil.X;
		QRecoil=vect(0,0,0);
	}

	// Save Raw values
	RawJoyUp		= aBaseY;
	RawJoyRight		= aStrafe;
	RawJoyLookRight	= aTurn;
	RawJoyLookUp	= aLookUp;

	// PlayerInput shouldn't take timedilation into account
	DeltaTime /= WorldInfo.TimeDilation;
	if (Outer.bDemoOwner && WorldInfo.NetMode == NM_Client)
	{
		DeltaTime /= WorldInfo.DemoPlayTimeDilation;
	}

	PreProcessInput( DeltaTime );

	// Scale to game speed
	TimeScale = 100.f*DeltaTime;
	aBaseY		*= TimeScale * MoveForwardSpeed;
	aStrafe		*= TimeScale * MoveStrafeSpeed;
	aUp			*= TimeScale * MoveStrafeSpeed;
	aTurn		*= TimeScale * LookRightScale;
	aLookUp		*= TimeScale * LookUpScale;

	PostProcessInput( DeltaTime );

	ProcessInputMatching(DeltaTime);

	// Check for Double click movement.
	//CatchDoubleClickInput();

	// Take FOV into account (lower FOV == less sensitivity).

	if ( bEnableFOVScaling )
	{
		FOVScale = GetFOVAngle() * 0.01111; // 0.01111 = 1 / 90.0
	}
	else
	{
		FOVScale = 1.0;
	}

	aLookUp*= FOVScale;
	aTurn*= FOVScale;

	// Forward/ backward movement
	aForward		+= aBaseY;

	// Handle walking.
	HandleWalking();

	// check for turn locking
	if (bLockTurnUntilRelease)
	{
		if (RawJoyLookRight != 0)
		{
			aTurn = 0.f;
			if (AutoUnlockTurnTime > 0.f)
			{
				AutoUnlockTurnTime -= DeltaTime;
				if (AutoUnlockTurnTime < 0.f)
				{
					bLockTurnUntilRelease = FALSE;
				}
			}
		}
		else
		{
			bLockTurnUntilRelease = FALSE;
		}
	}

	// ignore move input
	// Do not clear RawJoy flags, as we still want to be able to read input.
	if( TheController.bMovementIgnored==true )
	{
		aForward	= 0.f;
		aStrafe		= 0.f;
		aUp			= 0.f;
	}

	// ignore look input
	// Do not clear RawJoy flags, as we still want to be able to read input.
	if( TheController.bLookIgnored==true )
	{
		aTurn		= 0.f;
		aLookup		= 0.f;
	}
}

//Testing Functions

Exec Function AdjustTilt(float Amt)
{
	TiltSensitivity=Amt;
}

Exec Function AdjustPoint(float Amt)
{
	PointerSensitivity=Amt;
}

Exec Function SetMoveMode(int Amt)
{
	LastMoveMode=MovementMode;
	MovementMode=Amt;
}

Exec Function SetAimMode(int Amt)
{
	LastAimMode=AimMode;
	AimMode=Amt;
}

Exec Function AddRecoil(vector Amt)
{
	QRecoil+=Amt;
}

Exec Function ToggleMouseSmoothing()
{
	if(bEnableMouseSmoothing==true)
	{
		bEnableMouseSmoothing=false;
		`log("MouseSmothingOff");
	}
	else
	{
		bEnableMouseSmoothing=true;
		`log("MouseSmoothingOn");
	}
}
Function Dock()
{
	LastMoveMode=MovementMode;
	MovementMode=0;
	LastAimMode=AimMode;
	AimMode=0;
	`log("Hydras_Docked");
}

Function UnDock()
{
	MovementMode=LastMoveMode;
	AimMode=LastAimMode;
	`log("Hydras_UnDocked");
}

Function Destroy()
{
	//Super.Destroy();
	CloseSystem();
}

defaultproperties
{
	RightBumperOld=False
	RightJoyOld=False
	Right1Old=False
	Right2Old=False
	Right3Old=False
	Right4Old=False
	RightStartOld=False
	LeftBumperOld=False
	oldForward=False
	OldBackward=False
	OldLeft=False
	OldRight=False
	LeftJoyOld=False
	Left1Old=False
	Left2Old=False
	Left3Old=False
	Left4Old=False
	LeftStartOld=False
	RightTriggerOld=False
	LeftTriggerOld=False
	
	BdoubleleftWaiting=false
	BdoublerightWaiting=false
	BdoublebWaiting=false
	BdoublefWaiting=false
	DoubleListenTime=0.15
	Doubletimer=false
	
	//So you get a more analog feel from the joystick
	GroundSpeedFix=True
	LogCounter=0
	bLogs=true
	RightGesture=10
	LeftGesture=10
	MinimumGestureTime=0.15
	RightRecogEnabled=True
	LeftRecogEnabled=True
	GestureVelocityThreshold=800.00
	PointerSensitivity=0.1
	BLeftGesture=True
	BRightGesture=True
	RightJoyCenter=True
	LeftJoyCenter=True
	TiltSensitivity=0.05
	MovementMode=1
	AimMode=1
	
}

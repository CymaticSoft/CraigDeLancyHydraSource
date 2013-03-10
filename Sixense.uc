class Sixense extends Object
	DLLBind(sixense);

//layout of the basis vectors
//unreal space     X axis = forward Y axis = Right    Z axis = up       
//sixense space   X axis = Right    Y axis = Up	       Z axis = back
// Sx2Un		  X = -Z 		  Y = X                  Z = Y                            
//Un2Sx		  X = Y		  Y = Z		   Z = -X

// Bit masks. 0x01 >> 2^x = y
const SIXENSE_BUTTON_BUMPER 	= 128; //(0x01<<7)
const SIXENSE_BUTTON_JOYSTICK 	= 256; //(0x01<<8)
const SIXENSE_BUTTON_1      		= 32; //(0x01<<5);
const SIXENSE_BUTTON_2      		= 64; //(0x01<<6);
const SIXENSE_BUTTON_3      		= 8;  //(0x01<<3);
const SIXENSE_BUTTON_4      		= 16; //(0x01<<4);
const SIXENSE_BUTTON_START  		= 1;  //(0x01<<0);

// what is this?
const SIXENSE_SUCCESS = 0;
const SIXENSE_FAILURE  = -1;

// 4 controllers at once? Wicked!
const SIXENSE_MAX_CONTROLLERS = 4;


// 3D position, rotation matrices, joystick, trigger, and button data
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

// Sets up controller data for all controllers?
struct sixenseAllControllerData {
	var sixenseControllerData controller[4];
};

// declares an object that you'll use later when you want to display data in ClientMessage
var sixenseAllControllerData TheControllerData;

// importing functions from sixense.dll
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

/*NOTE
	The C++ DLL stores it's matrix data as a 2D Array but Unreal must address it with one index. Use the macro below to address it more naturally 
	
		EX: Memory layout of 3x3 rotation matrices
		C++:     rot_mat[0][0], rot_mat[0][1], rot_mat[0][2], rot_mat[1][0], rot_mat[1][1], rot_mat[1][2], rot_mat[2][0], rot_mat[2][1], rot_mat[2][2]   
		Unreal:  0                , 1                 , 2                  , 3                 , 4                  , 5                 , 6                 , 7                 , 8	
******************/
// mathematical conversion: 3x + y = U
//macro for accessing a particular 3x3 matrix element using two indices
//column major 
// what does ` do? It is the grave accent (the one below tilde). Necessary for log output, other operations.
`define m33el(x, y) `y + `x * 3
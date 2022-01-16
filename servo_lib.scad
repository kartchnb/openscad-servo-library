// To add new servo models to this library:
//   1) add a new source file for the servo in the "servos" folder
//   2) In the new source file, define the servo parameters
//   2) Add the file to the include list below
//   3) Add the servo parameters defined in the new source file to the ServoLib_Servo_Parameters list below

// Include the servo-specific files
include<servos/s3003_clone.scad>
include<servos/mg90s_clone.scad>
include<servos/sg90_clone.scad>
include<servos/gh_s37d.scad>

// Combine all of the servo models into a single list
SERVOLIB_SERVO_PARAMETERS =
concat
(
	SERVOLIB_PARAMETERS_S3003_CLONE, 	// "S3003 (Clone)"
	SERVOLIB_PARAMETERS_MG90S_CLONE, 	// "MG90S (Clone)"
	SERVOLIB_PARAMETERS_SG90_CLONE,  	// "SG90 (Clone)"
	SERVOLIB_PARAMETERS_GH_S37D 		// "GH-S37D"
);

// List of valid servo model strings:
ServoLib_ValidServoModels = [ for (x = SERVOLIB_SERVO_PARAMETERS) x[0] ];



// Define Iota, a small amount to be used to make differencing objects look better in preview
ServoLib_Iota = 0.001;



// Check if the specified servo model name is valid.
function ServoLib_ServoModelIsValid(servo_model) =
	let
	(
		servo_index = search([servo_model], SERVOLIB_SERVO_PARAMETERS) [0]
	)
	servo_index != [];



// Query the Aft Height of the specified servo model
function ServoLib_AftHeight(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "aft height");

// Query the Wing Height of the specified servo model
function ServoLib_WingHeight(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "wing height");

// Query the Fore Height of the specified servo model
function ServoLib_ForeHeight(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "fore height");

// Query the Axle Height of the specified servo model
function ServoLib_AxleHeight(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "axle height");

// Query the Body Width of the specified servo model
function ServoLib_BodyWidth(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "body width");

// Query the Wing Width of the specified servo model
function ServoLib_WingWidth(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "wing width");

// Query the Axle Offset of the specified servo model
function ServoLib_AxleOffset(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "axle offset");

// Query the Axle Diameter of the specified servo model
function ServoLib_AxleDiameter(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "axle diameter");

// Query the Body Length of the specified servo model
function ServoLib_BodyLength(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "body length");

// Query the Body Height of the specified servo model
// This is the sum of the Aft Height, Wing Height, and Fore Height
function ServoLib_BodyHeight(servo_model) =
	ServoLib_AftHeight(servo_model) +
	ServoLib_WingHeight(servo_model) +
	ServoLib_ForeHeight(servo_model);

// Query the spline type of the specified servo model
function ServoLib_SplineType(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "spline type");



// Generate a model of the specified servo
// The generated motor is centered according to the xcenter and zcenter parameters
// 
// Horizontal centering (xcenter):
// 	By default, the servo is centered, horizontally, on the axle
//	An xcenter value of "body" will, instead, center on the middle of the body
//
// Vertical centering (zcenter):
//  By default, the servo is generated with the top of the axle on the origin
//  A zcenter value of "axle base" or "body top" will, instead, place the top of the servo body on the XY plane
//  A zcenter value of "wing top" will place the top of the wings on the XY plane
//  A zcenter value of "wing bottom" will place the bottom of the wings on the XY plane
//  A zcenter value of "body base" or "base" will place the entire servo above the XY plane
module ServoLib_GenerateServo(servo_model, xcenter, zcenter)
{
	// Gather motor dimensions
	body_width = ServoLib_BodyWidth(servo_model);
	body_length = ServoLib_BodyLength(servo_model);
	body_height = ServoLib_BodyHeight(servo_model);
	fore_height = ServoLib_ForeHeight(servo_model);
	wing_width = ServoLib_WingWidth(servo_model);
	wing_height = ServoLib_WingHeight(servo_model);

	axle_offset = ServoLib_AxleOffset(servo_model);
	axle_diameter = ServoLib_AxleDiameter(servo_model);
	axle_height = ServoLib_AxleHeight(servo_model);

	// Calculate where to center the motor
	x_offset = 
		xcenter == "body" ? 0 :
		-axle_offset;
	y_offset = 0;
	z_offset =
		zcenter == "axle base" || zcenter == "body top" ? axle_height :
		zcenter == "wing top" ? axle_height + fore_height :
		zcenter == "wing bottom" ? axle_height + fore_height + wing_height :
		zcenter == "body base" || zcenter == "base" ? axle_height + body_height :
		0;
	echo(zcenter=zcenter);
	echo(z_offset=z_offset);

	translate([x_offset, y_offset, z_offset])
	difference()
	{
		union()
		{
			translate([0, 0, -axle_height])
			{
				// Model the servo body
				translate([-body_width/2, -body_length/2, -body_height])
					cube([body_width, body_length, body_height]);

				// Model the servo wings
				for (x_mirror = [0, 1])
				mirror([x_mirror, 0, 0])
				translate([body_width/2, -body_length/2, -fore_height - wing_height])
					cube([(wing_width - body_width)/2, body_length, wing_height]);
			}

			// Model the axle
			translate([axle_offset, 0, 0-axle_height])
				cylinder(d=axle_diameter, h=axle_height);
		}

		// Drill out the screw holes
		translate([0, 0, -axle_height - fore_height - wing_height - ServoLib_Iota])
		linear_extrude(wing_height + ServoLib_Iota*2)
			ServoLib_GenerateScrewHolesOutline(servo_model, xcenter="body");
	}
}



// Generate the outline of the screw holes for the given servo model
// This outline is simply a 2D representation of the holes and it will probably
// need to be extruded to be useful
module ServoLib_GenerateScrewHolesOutline(servo_model, xcenter)
{
	body_width = ServoLib_BodyWidth(servo_model);
	axle_offset = ServoLib_AxleOffset(servo_model);
	hole_parameters = _ServoLib_RetrieveScrewHoleParameters(servo_model);

	x_offset = 
		xcenter == "body" ? 0 :
		-axle_offset;
	y_offset = 0;

	// Offset the holes to match the motor body offset, which centers on the axle
	translate([x_offset, y_offset])
	{
		// Generate circles for each defined hole
		for (i = [0: 1: len(hole_parameters) - 1])
		{
			hole_table = hole_parameters[i];
			x_offset = hole_table [search(["x offset"], hole_table) [0]] [1];
			y_offset = hole_table [search(["y offset"], hole_table) [0]] [1];
			diameter = hole_table [search(["diameter"], hole_table) [0]] [1];

			translate([x_offset, y_offset])
				circle(d=diameter);
		}
	}
}






//-----------------------------------------------------------------------------
// "Private" functions are listed below 
//-----------------------------------------------------------------------------

// Retrieve the parameters for a specified servo model
function _ServoLib_RetrieveParameter(servo_model, key) =
	let
	(
		servo_index = search([servo_model], SERVOLIB_SERVO_PARAMETERS) [0],
		servo_parameters = SERVOLIB_SERVO_PARAMETERS [servo_index] [1],
		value_index = search([key], servo_parameters) [0],
		value = servo_parameters [value_index] [1]
	)
	ServoLib_ServoModelIsValid(servo_model) == false
		? assert(false, str("Servo model \"", servo_model, "\" is not currently supported by servo_lib"))
		: value_index == [] || value == undef 
			? assert(false, str("Requested parameter \"", key, "\" not found for servo model \"", servo_model, "\""))
			: value;



// Return the list of screw hole parameters for this model
function _ServoLib_RetrieveScrewHoleParameters(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "mounting screw holes");

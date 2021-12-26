include<tabletools_lib/tabletools_lib.scad>

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



// Generate a model of the specified servo
// The servo will be modeled entirely below the horizontal axes, with the center of the axle at [0, 0, 0]
module ServoLib_GenerateServo(servo_model)
{
	body_width = ServoLib_BodyWidth(servo_model);
	body_length = ServoLib_BodyLength(servo_model);
	body_height = ServoLib_BodyHeight(servo_model);
	fore_height = ServoLib_ForeHeight(servo_model);
	wing_width = ServoLib_WingWidth(servo_model);
	wing_height = ServoLib_WingHeight(servo_model);

	axle_offset = ServoLib_AxleOffset(servo_model);
	axle_diameter = ServoLib_AxleDiameter(servo_model);
	axle_height = ServoLib_AxleHeight(servo_model);

	difference()
	{
		union()
		{
			// Offset the motor body to center on the axle
			translate([-body_width/2 + axle_offset, 0, -axle_height])
			{
				// Model the servo body
				translate([-body_width/2, -body_length/2, -body_height])
					cube([body_width, body_length, body_height]);

				// Model the servo wings
				translate([-wing_width/2, -body_length/2, -fore_height - wing_height])
					cube([wing_width, body_length, wing_height]);
			}

			// Model the axle
			translate([0, 0, 0-axle_height])
				cylinder(d=axle_diameter, h=axle_height);
		}

		// Drill out the screw holes
		translate([0, 0, -axle_height - fore_height - wing_height - iota])
		linear_extrude(wing_height + iota*2)
			ServoLib_GenerateScrewHolesOutline(servo_model);
	}
}



// Generate the outline of the screw holes for the given servo model
// This outline is simply a 2D representation of the holes and it will probably
// need to be extruded to be useful
module ServoLib_GenerateScrewHolesOutline(servo_model)
{
	body_width = ServoLib_BodyWidth(servo_model);
	axle_offset = ServoLib_AxleOffset(servo_model);
	hole_parameters = _ServoLib_RetrieveScrewHoleParameters(servo_model);

	// Offset the holes to match the motor body offset, which centers on the axle
	translate([-body_width/2 + axle_offset, 0])
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
	_ServoLib_ReturnIfServoModelIsValid(servo_model, value);


// Return the specified value if the servo model is valid
function _ServoLib_ReturnIfServoModelIsValid(servo_model, value) =
    ServoLib_ServoModelIsValid(servo_model)
    ? value
    : assert(false, str("Servo model \"", servo_model, "\" is not currently supported by servo_lib"));



// Return the list of screw hole parameters for this model
function _ServoLib_RetrieveScrewHoleParameters(servo_model) =
	_ServoLib_RetrieveParameter(servo_model, "mounting screw holes");

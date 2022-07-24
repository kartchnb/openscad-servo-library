/* [General Parameters] */
// Display all supported servo names?
Display_Servo_Names = true;

// The size of the font to use for labels
Font_Size = 5;



/* [Advanced] */
// The value to use for creating the model preview (lower is faster)
Preview_Quality_Value = 32;

// The value to use for creating the final model render (higher is more detailed)
Render_Quality_Value = 128;



include<../servo_lib.scad>



module Generate(index=0)
{
    servo_name = Servo_Names[index];

    supported = ServoLib_ServoModelIsValid(servo_name);
    if (supported)
    {
        ServoLib_GenerateServo(servo_name, xcenter="body", zcenter="base");

        if (Display_Servo_Names)
        {
            y_offset = -ServoLib_BodyLength(servo_name)/2;
            translate([0, y_offset])
            rotate([0, 0, 90])
            color("lightblue")
                text(servo_name, size=Font_Size, valign="center", halign="right");
        }
    }
    
    else
    {
        echo(str ("'", servo_name, "' is not a supported servo name"));
    }
    
    if (index < len(Servo_Names) - 1)
    {
        x_offset = ServoLib_WingWidth(servo_name)/2 + ServoLib_WingWidth(Servo_Names[index + 1])/2 + 10;
        translate([x_offset, 0, 0])
        Generate(index + 1);
    }
}



// Global parameters
iota = 0.001;
$fn = $preview ? Preview_Quality_Value : Render_Quality_Value;

Servo_Names = ServoLib_ValidServoModels;



// Generate the servo models
Generate();

# Servo Library for OpenSCAD
Created by Brad Kartchner (kartchnb@gmail.com)

This library is designed to make it easier to create designs incorporting 
standard servos.

Methods are provided to access dimensions for each servo and to generate models
of them.

Although I believe this library is fully-featured, only a very limited selection of servos (ones that I personally have on hand) have been included.  It's fairly easy to add more, though.

A current list of supported servos can always be obtained by echoing the value
of the ServoLib_ValidServoModels variable.  For example:
   echo (ServoLib_ValidServoModels);

As of version 2.0.0, the supported servo models are:
   ["S3003 (Clone)", "MG90S (Clone)", "SG90 (Clone)", "GH-S37D"]

-------------------------------------------------------------------------------
## METHODS
### ServoLib_GenerateServo(servo_model, xcenter, zcenter)
   This method generates a basic model of the specified servo.
   The generated model is intended to be a guide for designing around servo hardware. It is not intended to be accurate beyond the basic measurements.

   The method accepts the following parameters:
   * `servo_model` - the name of the servo to model.
     
   * `xcenter ` - specifies where the motor should be centered horizontally (defaults to "axle")
     "axle" generates the motor centered on the axle.
     "body" generates the motor with the body centered along the origin.

   * `zcenter` - determines where the motor is positioned on the z-axis (defaults to "axle top").
     "axle top" generates the motor with the top of the axle on the XY plane.
     "axle base" or "body top" generates the motor with the bottom of the axle on the XY plane.
     "wing top" generates the motor with the top of the wings on the XY plane.
     "wing bottom" generates the motor with the bottom of the wings on the XY plane.
     "body base" or "base" generates the motor with the entire servo above the XY plane.

### ServoLib_GenerateScrewHolesOutline(servo_model)
   Generates a 2D hole pattern for the servo's mounting screw holes.
   This pattern can be extruded to create mounting screw holes in your model.

   The method accepts the following parameters:
   * `servo_model` - the name of the servo to model.
-------------------------------------------------------------------------------
## FUNCTIONS
### ServoLib_ServoModelIsValid(servo_model)
   Returns true if servo_model is a recognized Servo Model Name.
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_AftHeight(servo_model)
   Returns the Aft Height of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_WingHeight(servo_model)
   Returns the Wing Height of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_ForeHeight(servo_model)
   Returns the Fore Height of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_AxleHeight(servo_model)
   Returns the Axle Height of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_BodyWidth(servo_model)
   Returns the Body Width of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_WingWidth(servo_model)
   Returns the Wing Width of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_AxleOffset(servo_model)
   Returns the Axle Offset of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_AxleDiameter(servo_model)
   Returns the Axle Diameter of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_BodyLength(servo_model)
   Returns the Body Length of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.

### ServoLib_BodyHeight(servo_model)
   Returns the Body Height of the specified servo model (see diagrams below).
   The function accepts the following parameters:
   * `servo_model` - the name of the servo to model.
-------------------------------------------------------------------------------
Diagram of servo measurements:

![servo diagram](https://user-images.githubusercontent.com/54730012/158481400-c6d95aa7-3db0-4da5-b4b7-e66df4bb73a3.png)

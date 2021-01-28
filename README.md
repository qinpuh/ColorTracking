# ColorTracking

## What is this
This code tracks painted nail movement on a texture board and time-varying forces during the whole exploration process. 

### TactileForceMainScript
The main function that runs the time-varying position and force tracking.

### rgbTraker
This function can be applied to track the positions of any colored object by adjusting the color threshold value in the function.

###TrackPaintedNail
Function that defines the color of the painted nail and calls rgbTracker to track the movement

###TrackingSanityCheck
Input any frame and plot to check the position returned by TrackPaintedNail is indeed correct

###ForceVelocityAlignment
Aligning the force and position trackings.

###ClickFig
Function that allows used to interactively click on the frame

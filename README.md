# ColorTracking

## What is this
This code tracks painted nail movement on a texture board and time-varying forces during the whole exploration process. 

### TactileForceMainScript
The main function that runs the time-varying position and force tracking.

### rgbTraker
This function can be applied to track the positions of any colored object by adjusting the color threshold value in the function.

### TrackPaintedNail
Function that defines the color of the painted nail and calls rgbTracker to track the movement

### plot_MarkeronNail
Visually show the tracked nail by a red dot and display it on every frame

### plot_velocity
Function that plots the x,y position in mm, distance from center in mm, and velocity in mm/s versus time

### alignForceVelocityTraces
Aligning the force and position trackings and plot the force traes

### plot_VelandForce
Plot aligned velocity and force traces on the same plot.

### TrackingSanityCheck
Input any frame and plot to check the position returned by TrackPaintedNail is indeed correct

### ClickFig
Function that allows used to interactively click on the frame

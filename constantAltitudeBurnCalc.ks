//@lazyGlobal off.

//#include "utils/shipTools.ks"
//#include "utils/extraMath.ks"

//given a ship - at it's current location in its (sub)orbital flight -  what pitch is required
//to maintain a constant altitude at maximum engine thrust?
function calculateConstantAltitudeBurnPitch{
	parameter theShip to ship.

	//how far away is the ship from the center of the thing it is orbiting?
	declare local radius to theShip:altitude + theShip:orbit:body:radius.

	//what is the acceleration due to gravity at our current altitude?
	declare local gravitationalAcceleration to theShip:body:mu/(radius^2).

	//what is the apparent acceleration due to the centrifugal force at it's current orbital location
	//the equation for centrifugal Acceleration is: CentrifugalAcceleration = (angularVelocity^2)*radius
	//the equation for angularVelocity is: angularVelocity = HorizontalVelocity/radius
	//pluging in all those values, we get a long-form equation for centrifugal Acceleration of:
	//CentrifugalAcceleration = ((HorizontalVelocity/radius)^2)*radius
	//this expands out to:
	//CentrifugalAcceleration = (HorizontalVelocity/radius)*(HorizontalVelocity/radius)*radius
	//but at the end, those two radiuses cancel out, so we can simply that into:
	//CentrifugalAcceleration = (HorizontalVelocity/radius)*HorizontalVelocity
	//which then can be simplified further into
	//CentrifugalAcceleration = HorizontalVelocity^2/radius
	declare local centrifugalAcceleration to getHorizontalOrbitalVector(theShip):sqrMagnitude/radius.

	//what is the apparent acceleration of those two combined? 
	declare local downwardsAcceleration to gravitationalAcceleration - centrifugalAcceleration.

	//what is the combined uppy-downy force on the ship?
	declare local downwardsForce to theShip:mass * downwardsAcceleration.

	declare local pitchAngle to 0.
	if theShip:availablethrust > 0 {
		//now lets do a bit of trig to find out what pitch angle we need.
		declare local dfOverAvailThrust to downwardsForce/theShip:availablethrust.
		set pitchAngle to arcSin(clamp(dfOverAvailThrust,-1,1)).
	} else {
		//if there is no thrust, that probably means we are between stages and the autoStage function hasn't quite gotten a chance to run.
		//if this is the case, we should probably just hold the pitch where it is.
		set pitchAngle to getCurrentPitchAngle().
	}

	//now lets constrain the pitch angle to a safe value.
	declare local minPitchAngle to 0.
	declare local maxPitchAngle to 84.9.
	set pitchAngle to clamp(pitchAngle,minPitchAngle,maxPitchAngle).

	return pitchAngle.
}
@lazyglobal off.
RunOncePath("0:/utilities/utils.ks").
RunOncePath("0:/flightParameters/orbitalParameters.ks").

PrintStatusWindow("status.ks", version).

// Control scheme
until false {
	UpdateStatusWindow().
	wait 0.
}
@lazyglobal off.
RunOncePath("./utilities/utils.ks").
RunOncePath("./flightParameters/orbitalParameters.ks").

PrintStatusWindow("status.ks", version).

// Control scheme
until 0 {
	UpdateStatusWindow().
	wait 0.
}
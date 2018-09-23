@lazyglobal off.

run once utils.
run once orbitalParameters.

PrintStatusWindow("status.ks", version).

// Control scheme
until 0 {
	UpdateStatusWindow().
	wait 0.
}
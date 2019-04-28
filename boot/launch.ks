@lazyglobal off.

SET ship:control:mainThrottle TO 0.
local cpu is core:part:getModule("kOSProcessor").

cpu:doEvent("Open Terminal").
set terminal:height TO 19.
set terminal:width TO 59.
set terminal:brightness TO 0.8.
set terminal:charHeight TO 12.

print("boot launch").
wait 3.

switch to 0.
runPath("0:/scripts/launch.ks").

copyPath("0:/boot/default.ks", "1:/boot/default.ks").
deletepath("1:/boot/launch.ks").

switch to 1.
set cpu:bootFilename to "/boot/default.ks".
SET ship:control:mainThrottle TO 0.
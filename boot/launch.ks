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

copyPath("0:/boot/default.ks", "1:/boot/default.ks").
deletepath("1:/boot/launch_new.ks").
set cpu:bootFilename to "/boot/default.ks".

switch to 0.
runPath("0:/scripts/launch_new.ks").

switch to 1.
SET ship:control:mainThrottle TO 0.
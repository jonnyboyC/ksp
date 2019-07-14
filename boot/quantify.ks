@lazyglobal off.

SET ship:control:mainThrottle TO 0.
local cpu is core:part:getModule("kOSProcessor").

cpu:doEvent("Open Terminal").
set terminal:height TO 19.
set terminal:width TO 59.
set terminal:brightness TO 0.8.
set terminal:charHeight TO 12.

print("boot quantity").
wait 3.

switch to 0.
runOncePath("0:/scripts/quantifyShip.ks").

switch to 1.
SET ship:control:mainThrottle TO 0.
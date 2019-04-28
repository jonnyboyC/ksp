@lazyglobal off.

SET SHIP:CONTROL:MAINTHROTTLE TO 0.

local cpu is core:part:getModule("kOSProcessor").

cpu:doEvent("Open Terminal").
set terminal:height TO 19.
set terminal:width TO 59.
set terminal:brightness TO 0.8.
set terminal:charHeight TO 12.

print("boot default").

switch to 0.
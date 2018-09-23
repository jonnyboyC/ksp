@lazyglobal off.

parameter 
	vessel_name.

local message is "Hello".
local connection is vessel(vessel_name):connection.

print("Delay is " + connection:delay + "s").
if connection:sendMessage(message) {
  print("Message sent!").
}
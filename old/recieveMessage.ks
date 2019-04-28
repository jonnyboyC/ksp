@lazyglobal off.

print (ship:messages:length).

until not ship:messages:empty {
  wait 0.1.
}

local received is ship:message:pop.
print("Message sent by " + received:sender:name + " at " + received:sentAt).
print(received:content).


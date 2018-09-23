@lazyglobal off.

print "These are all the resources active in this stage:".
set reslist to stage:resources.
FOR res in reslist {
    print "Resource " + res:name.
    print "    value = " + res:amount.

    if res:capacity <> 0 {
        print "    which is "
          + round(100 * res:amount / res:capacity)
          + "% full.".
    }
}.
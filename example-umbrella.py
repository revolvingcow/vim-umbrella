#!/usr/bin/python

import coverage

output = ""
cov = coverage.coverage()
cov.load()

for a in [cov.analysis2("*")]:
    output += "{0};{1};{2};{3}\n".format(
            a[0], 
            ",".join(str(x) for x in a[1]), 
            "", 
            ",".join(str(x) for x in a[3]))

f = open(".umbrella-coverage", "w")
f.write(output)
f.close()

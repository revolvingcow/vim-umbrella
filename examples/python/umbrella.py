#!/usr/bin/python
import coverage
import os
import unittest

# Store our output to the file
output = ""

# Start the coverage
cov = coverage.coverage()
cov.start()

# Dynamically get all the test cases we can find.
suite = unittest.TestSuite()
suite.addTests(unittest.TestLoader().discover(os.getcwd(), pattern="*.py"))

# Run the tests
unittest.TextTestRunner().run(suite)

# Stop coverage and save the stats
cov.stop()
cov.save()

# Iterate through the tested files
for source in cov.data.measured_files():
    for a in [cov.analysis2(source)]:
        output += "{0};{1};{2};{3};\n".format(
                a[0], 
                ",".join(str(x) for x in a[1]), 
                ",".join(str(x) for x in a[2]), 
                ",".join(str(x) for x in a[3]))

# Write the coverage report for umbrella
fileName = ".umbrella-coverage"
if os.path.isfile(fileName):
    os.remove(fileName)

f = open(fileName, "w")
f.write(output)
f.close()

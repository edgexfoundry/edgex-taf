<!--

 Copyright (C) 2019 Intel Corporation

 SPDX-License-Identifier: Apache-2.0

-->

Python Implementation of Test Automation
============================================

This is an implementation of TAF for automated testing

**Implementation.**<br />
The implementation is written in [Python 3][python].

It uses Robot framework to control automation and post results.


System Requirements
-------------------

TAF is targeted to run on Ubuntu Linux.

The TAF is implemented in version 3.6 of [Python][python], an
open licensed dynamic programming language available on all common
platforms.

To find out whether a compatible version of Python is
already installed on your system, execute `python3 --version` in a
terminal.

The command will return the version number if Python is
available.

Please see the *Using Python* part of Python's
[documentation][python-using] for system installation instructions.

Note that additional python packages may need to installed depending
upon what is supported by the python base version versus what is
needed by a particular TAF implementation.

This is usually easy to resolve by noting python import exceptions<br/ >
and then using pip to install the missing packages.

The TAF uses [robot framework][robot] for controlling the test cases.

For development, git is used to continuously develop
and review the code.

[Doxygen][doxygen] is used as the documentation tool.<br />
The doxypy plugin is used to allow test developers to comment the code in a
more pythonic way.

Program Execution
-----------------

The TAF framework runs from the command line using robot framework.<br />
During development, it is also possible for test case code to be
instrumented to run outside of robot.<br />
This can assist in debugging robot scripts as well as python code.

It is important to note that test cases are not "written in Robot".<br />
Robot is used by TAF in a lightweight manner, that is,<br />
to control the execution of testsuites, import keywords (python function<br />
names), and identify test case mappings from robot to python code.

Refer to [TAF Common][taf-common] for the usage.

When running under robot do not use python print statements to
debug code. Use logging instead.<br />
If you have a particularly tricky bug, then implement code in your test script to run outside
of robot.<br />
There are scripts in testCaseApps subdirectories which have examples.

Documentation
---------------------
//TODO

License
-------

Copyright (C) 2019 Intel Corporation

SPDX-License-Identifier: Apache-2.0


[python]: http://python.org "Python Programming Language"
[python-using]: http://docs.python.org/2/using/index.html "Python Setup and Usage"
[robot]: http://robotframework.org "Generic test automation framework for acceptance testing and ATDD"
[doxygen]: http://www.stack.nl/~dimitri/doxygen/ "Generate documentation from source code"
[taf-common]: https://github.com/edgexfoundry/edgex-taf-common "TAF Common"

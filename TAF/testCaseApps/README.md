<!--

 Copyright (C) 2019 Intel Corporation

 SPDX-License-Identifier: Apache-2.0

-->

- This directory is for test case apps. 	
- Place the test app directory underneath the use case type that is most appropriate.

- Test Case App is a set of libraries that automates the test procedure. These are totally
  specific to the solution under test and has the business logic.
  It is subdivided by use case types. Each test case app should have it’s own subdirectory within its use case type subdirectory.  Specific test cases may also have their own specific config files there also.
  These python libraries will be called by the robot files for performing test scenarios.



"""
 @copyright Copyright (C) 2019 Intel Corporation

 @license SPDX-License-Identifier: Apache-2.0

 @package: TAF.testScenarios

 @file run.py

 @description
     This file allows testers to execute set(s) of testCases/useCases based on the parameters passed. It will create
     a report based on the results that can be published in a web server or can sent through email.

"""
from robot import run, rebot
import os
import sys
import argparse
import logging
import fnmatch

OUTPUTDIR = "../../testArtifacts/robot/log"
VERSION = "1.0"
RUNLEVEL= "INFO"
DRY_RUN = False
noReport = False
tmpOutputDir = None


def error(msg):
    """
    This function logs an error message and end the execution.

    @param msg  Message to be displayed before stopping test execution.
    """
    sys.stderr.write(msg+"\r\n")
    sys.exit()


def configure_parser():
    """
    This method is the console log parser

    @retval t_parser  Returns TAF Parser
    """
    t_parser = argparse.ArgumentParser(description="TAF test Runner")
    t_parser.add_argument("-u", "--useCase", action="append", default=None, dest="useCase", help="specify UC")
    t_parser.add_argument("-t", "--testCase", action="append", default=None, dest="testCase", help="specify TestCase")
    t_parser.add_argument("-i", "--include", action="append", default=None, dest="include", help="Tags to include")
    t_parser.add_argument("-e", "--exclude", action="append", default=None, dest="exclude", help="Tags to exclude")
    t_parser.add_argument("-L", "--loglevel", choices=["TRACE", "DEBUG", "INFO", "WARN", "ERROR", "NONE"],
                          default=RUNLEVEL, dest="logLevel",help="Tags to exclude")
    t_parser.add_argument("-c", "--configFile", default=None, dest="configFile", help="configFile to use")
    t_parser.add_argument("--version", "-v", action="version", version="%(prog)s {0}".format(VERSION))
    return t_parser


def check_args():
    """
    Validate arguments received.
    """
    if args.useCase and args.testCase:
        error("Can only specify one useCase or testCase", 1)
    elif not (args.useCase or args.testCase):
        error("Need at least one useCase or testCase", 2)
    elif args.useCase:
        logging.info("Running usecase {0}".format(args.useCase))
        if '*' in args.useCase:
            for file in os.listdir('.'):
                if fnmatch.fnmatch(file, 'UC_*'):
                    run_uc(file)
        else:
            for eachUC in args.useCase:
                run_uc(eachUC)
    elif args.testCase:
        logging.info("Running testcase {0}".format(args.testCase))
        if args.testCase in [".", "*"]:
            run_tests()
        else:
            for eachTest in args.testCase:
                run_test(eachTest)
    else:
        logging.info("Nothing")


def delete_files_in_folder(folder):
    """
      This method deletes files under certain folder.
      @param folder Directory path
    """
    if os.path.isdir(folder):
        for the_file in os.listdir(folder):
            file_path = os.path.join(folder, the_file)
            try:
                if os.path.isfile(file_path):
                    os.unlink(file_path)
            except Exception as e:
                print(e)


def run_uc(ucdir):
    """
      Execute test cases under an use case directory.
      @param ucdir Use case directory
    """

    if ucdir.startswith("UC_"):
        if os.path.isdir(ucdir):
            global tmpOutputDir, DRY_RUN
            if args.configFile:
                tmpOutputDir = "../../testArtifacts/robot/"+get_base_filename()+"/"+ucdir
            else:
                tmpOutputDir = "../../testArtifacts/robot/"+ucdir
            os.chdir(ucdir)
            delete_files_in_folder(tmpOutputDir)
            run_tests()
            os.chdir("..")
            if DRY_RUN is False:
                make_report(ucdir)
        else:
            error("Usecase dir {0} does not exists".format(ucdir), 3)
    else:
        error("Use Case directory needs to start with UC_", 4)


def run_ucs():
    """
      Execute set of use cases
    """
    for uc in os.listdir("./"):
        run_uc(uc)


def make_report(file_dir):
    """
      Creates a report file based on the executed usecase.
      @param file_dir File name of the report being generated.
    """
    file_list = []
    if args.configFile is not None:
        output_dir = "../testArtifacts/robot/" + get_base_filename() + "/" + file_dir
    else:
        output_dir = "../testArtifacts/robot/" + file_dir
    for t_file in os.listdir(output_dir):
        if fnmatch.fnmatch(t_file, '*.xml'):
            file_list.append(output_dir + "/" + t_file)
    logging.debug(file_list)
    rebot(*file_list, log=output_dir + "_log.html", report=output_dir + "_report.html")


def get_base_filename():
    """
      Returns file's directory.
      @retval Returns file's directory.
    """
    output_dir = os.path.basename(args.configFile)
    dot_position = output_dir.find(".")
    if dot_position != -1:
        output_dir = output_dir[:dot_position]
    return output_dir


def run_test(testfile):
    """
      Execute defined test cases using as parameter received testfile.
      @param testfile Test's file path.
    """
    global tmpOutputDir,noReport, DRY_RUN
    logging.debug("Testing {0}".format(testfile))
    if testfile.endswith(".robot"):
        robotstart = testfile.find(".robot")
        testname = testfile[:robotstart]
        profile = "../../config/profiles/Sample_Profile.py"
        iterations = "iterations:1"
        if tmpOutputDir is None:
            tmpOutputDir = OUTPUTDIR
        kwargs = {"outputdir": tmpOutputDir, "loglevel": args.logLevel,
                  "variablefile": profile, "variable": [iterations]}
        if args.include:
            kwargs["include"] = args.include
        if args.exclude:
            kwargs["exclude"] = args.exclude
        if args.configFile:
            kwargs["variable"].append("PLATCONFIG:"+args.configFile)
            kwargs["outputdir"] = tmpOutputDir
        if os.path.isdir(testname):
            logging.debug("Found configuration directory for {0}".format(testname))
            for cfg in os.listdir(testname):
                cfgIndex = cfg.find(".cfg")
                if cfgIndex > 0:
                    cfgname = cfg[:cfgIndex]
                    Newtestname = testname + "_" + cfgname
                    if noReport:
                        kwargs["output"] = Newtestname+".xml"
                    logging.info("Running test {0} using config: {1}".format(testfile, testname+"/"+cfg))
                    kwargs["report"] = Newtestname+"_report.html"
                    kwargs["variable"].append("testcase_cfg:"+testname+"/"+cfg)
                    if DRY_RUN is False:
                        run(testfile, **kwargs)
                    else:
                        pass
        else:
            logging.info("Run test {0}".format(testfile))
            if DRY_RUN is False:
                logging.debug("Output to {0}, {1}".format(tmpOutputDir,noReport))
                if noReport:
                    kwargs["output"] = testname+".xml"
                run(testfile, **kwargs)
    else:
        logging.error("{0} Not a robot file".format(testfile))


def run_tests():
    """
      Execute tests in current directory.
    """
    global noReport
    noReport = True
    for item in os.listdir("."):
        run_test(item)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    args = configure_parser().parse_args()
    check_args()

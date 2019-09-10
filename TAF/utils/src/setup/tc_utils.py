"""
 @copyright Copyright (C) 2019 Intel Corporation

 @license SPDX-License-Identifier: Apache-2.0

 @file demo_tc_utils.py

 @brief  Helper functions for test case routines.

 @description
    Helper functions for test case routines.
"""
import six

LOGNAME = "DEMO_TC_UTILS"
STANZA = "*"*50
SML_STANZA = "*"*12


def config_sections():
    """
     Return list of sections that must be present in the config file.
     @retval    List of sections to validate in config file.
    """
    return ['Suite']


def config_items(section_name):
    """
    Return list of item expected for a specific section.
    """
    if section_name == 'Demo':
        return ['username']
    return []


def verify_config(cfg, log):
    """
     verify configuration input
     @param     cfg     Configuration file path
     @param     log     Logger object
     @retval    Returns True/False based on the sections and items found in the config file.
    """
    section_names = config_sections()
    for section in section_names:
        try:
            cfg_set = cfg.get_section(section)
        except six.moves.configparser.NoSectionError:
            log.error("{}:verify_config: Required section ( {} ) missing from config"
                      "file".format(LOGNAME, section))
            return False

        _cfg_items = config_items(section)
        for item in _cfg_items:
            if item not in cfg_set:
                log.error("{}:verify_config: Required item ( {}.{} ) missing from"
                          "config file".format(LOGNAME, section, item))
                return False
    return True


def print_log_header(log):
    """
     print log header
     @param     log     Logger object
    """
    log.info("{}".format(STANZA))
    log.info("{}".format(STANZA))
    log.info("{}{}{}".format(SML_STANZA, "  DEMO TEST RUN START  ", SML_STANZA))


def print_log_footer(log):
    """
     print log footer
     @param     log     Logger object
    """
    log.info("{}{}{}".format(SML_STANZA, "    DEMO TEST RUN END  ", SML_STANZA))
    log.info("{}".format(STANZA))
    log.info("{}".format(STANZA))


def print_tc_header(log, tc_name):
    """
     print_tc_header
     @param     log     Logger object
     @param     tc_name Test case name.
    """
    log.info("{}".format(STANZA))
    log.info("{}{}{}".format(SML_STANZA, tc_name, " START"))


def print_tc_footer(log, tc_name):
    """
     print_tc_footer
     @param     log     Logger object
     @param     tc_name Test Case name
    """
    log.info("{}".format(STANZA))
    log.info("{}{}{}".format(SML_STANZA, tc_name, " END"))

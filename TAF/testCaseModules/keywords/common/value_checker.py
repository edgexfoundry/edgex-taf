"""
 @copyright Copyright (C) 2020 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file value_checker.py

 @description
    data validation
"""

from TUC.data.SettingsInfo import SettingsInfo
import numpy as np
import struct
import binascii

STRING = "STRING"
BOOL = "BOOL"
INT8 = "INT8"
INT16 = "INT16"
INT32 = "INT32"
INT64 = "INT64"
UINT8 = "UINT8"
UINT16 = "UINT16"
UINT32 = "UINT32"
UINT64 = "UINT64"
FLOAT32 = "FLOAT32"
FLOAT64 = "FLOAT64"


def check_value_range(val, value_type):
    SettingsInfo().TestLog.info('Check the value {} whether in the {} range or not'.format(val, value_type))

    if value_type == STRING:
        return True
    elif value_type == BOOL:
        if bool(val) == True or bool(val) == False:
            return True
        else:
            return False
    elif value_type == INT8:
        if np.iinfo(np.int8).min <= int(val) <= np.iinfo(np.int8).max:
            return True
        else:
            return False
    elif value_type == INT16:
        if np.iinfo(np.int16).min <= int(val) <= np.iinfo(np.int16).max:
            return True
        else:
            return False
    elif value_type == INT32:
        if np.iinfo(np.int32).min <= int(val) <= np.iinfo(np.int32).max:
            return True
        else:
            return False
    elif value_type == INT64:
        if np.iinfo(np.int64).min <= int(val) <= np.iinfo(np.int64).max:
            return True
        else:
            return False
    elif value_type == UINT8:
        if np.iinfo(np.uint8).min <= int(val) <= np.iinfo(np.uint8).max:
            return True
        else:
            return False
    elif value_type == UINT16:
        if np.iinfo(np.uint16).min <= int(val) <= np.iinfo(np.uint16).max:
            return True
        else:
            return False
    elif value_type == UINT32:
        if np.iinfo(np.uint32).min <= int(val) <= np.iinfo(np.uint32).max:
            return True
        else:
            return False
    elif value_type == UINT64:
        if np.iinfo(np.uint64).min <= int(val) <= np.iinfo(np.uint64).max:
            return True
        else:
            return False
    elif value_type == FLOAT32:
        try:
            decode_val = float(val)
        except ValueError:
            # Decode base64 to bytes
            byte_val = binascii.a2b_base64(val)
            # Convert bytes to float, 'f' can refer to https://docs.python.org/2/library/struct.html#format-characters
            decode_val = struct.unpack('>f', byte_val)[0]

        if np.finfo(np.float32).min <= int(decode_val) <= np.finfo(np.float32).max:
            return True
        else:
            return False
    elif value_type == FLOAT64:
        try:
            decode_val = float(val)
        except ValueError:
            byte_val = binascii.a2b_base64(val)
            decode_val = struct.unpack('>d', byte_val)[0]

        if np.finfo(np.float64).min <= int(decode_val) <= np.finfo(np.float64).max:
            return True
        else:
            return False
    SettingsInfo().TestLog.info("Unsupported data type {}".format(value_type))
    return False


def check_value_equal(value_type, expect,  val):
    SettingsInfo().TestLog.info('Check the {} value {} equal to {}'.format(value_type, expect, val))

    offset = 0.001
    if value_type == FLOAT32:
        try:
            decode_val = float(val)
        except ValueError:
            # Decode base64 to bytes
            byte_val = binascii.a2b_base64(str(val))
            # Convert bytes to float, 'f' can refer to https://docs.python.org/2/library/struct.html#format-characters
            decode_val = struct.unpack('>f', byte_val)[0]
            decode_val = round(decode_val, 2)

        SettingsInfo().TestLog.info('Decode {} to {}'.format(val, decode_val))

        if abs(decode_val - float(expect)) < offset:
            return True
        else:
            return False

    elif value_type == FLOAT64:
        try:
            decode_val = float(val)
        except ValueError:
            byte_val = binascii.a2b_base64(val)
            decode_val = struct.unpack('>d', byte_val)[0]
            SettingsInfo().TestLog.info('Decode {} to {}'.format(val, decode_val))

        if abs(decode_val - float(expect)) < offset:
            return True
        else:
            return False
    # elif value_type == BOOL:
    #     return bool(val) == expect
    else:
        return val == expect
    SettingsInfo().TestLog.info("Unsupported data type {}".format(value_type))
    return False

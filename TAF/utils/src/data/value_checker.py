from TUC.data.SettingsInfo import SettingsInfo
import numpy as np

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
        if value_type == '0' or value_type == '1':
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
        if np.finfo(np.float32).min <= int(val) <= np.finfo(np.float32).max:
            return True
        else:
            return False
    elif value_type == FLOAT64:
        if np.finfo(np.float64).min <= int(val) <= np.finfo(np.float64).max:
            return True
        else:
            return False
    SettingsInfo().TestLog.info("Unsupported data type {}".format(value_type))
    return False

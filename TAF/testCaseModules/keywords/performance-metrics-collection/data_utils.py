"""
 @copyright Copyright (C) 2020 IOTech Ltd

 @license SPDX-License-Identifier: Apache-2.0

 @file data_utils.py

 @description
    data calculation
"""


# Get Maximum, Minimum, and Average from list
def calculate_avg_max_min_from_list(list):

    calculate_values = {"max": max(list),
                        "min": min(list),
                        "avg": round(sum(list) / len(list), 2)}

    return calculate_values

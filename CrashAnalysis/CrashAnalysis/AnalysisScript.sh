#!/bin/sh

#  AnalysisScript.sh
#  CrashAnalysis
#
#  Created by xiefei5 on 2017/8/19.
#  Copyright © 2017年 xiefei5. All rights reserved.


export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

"${1}" "${2}" "${3}" > "${4}"

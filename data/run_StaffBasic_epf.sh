#!/bin/bash

/opt/1C/v8.3/x86_64/1cv8 ENTERPRISE  \
  /DisableStartupMessages  \
  /SLev2  \
  /UseHwLicenses+  \
  /Out ./1c_log/`date -I`.log -NoTruncate  \
  /Execute "<EPF_WITH_ABSOLUTE_PATH>" \
  /IBName<NAME_DB_LOCAL> \
  /N <USER> /P <PASS>

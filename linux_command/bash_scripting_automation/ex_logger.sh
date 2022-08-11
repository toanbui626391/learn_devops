#!/bin/bash

#logger write log information to /var/log/syslog or /var/log/messages depend on distro
function my_logger() {
  local MESSAGE=$@
  echo "$MESSAGE"
  logger -i -t randomly -p user.info "$MESSAGE"
}
my_logger "Random number: $RANDOM"
my_logger "Random number: $RANDOM"
my_logger "Random number: $RANDOM"
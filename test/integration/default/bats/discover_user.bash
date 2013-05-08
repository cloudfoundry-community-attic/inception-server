export TEST_USER=$(users | head -n1 | awk '{print $1}')
export TEST_USER_HOME="/home/$TEST_USER"

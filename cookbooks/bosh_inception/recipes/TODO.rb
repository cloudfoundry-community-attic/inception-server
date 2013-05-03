# if [[ $(grep "export TMPDIR" /home/vcap/.bashrc) == "" ]]; then
#   echo 'adding $TMPDIR to .bashrc'
#   echo "export TMPDIR=/var/vcap/store/tmp" >> /home/vcap/.bashrc
# fi
# 
# if [[ $(grep "export EDITOR" /home/vcap/.bashrc) == "" ]]; then
#   echo 'setting $EDITOR to vim as default'
#   echo "export EDITOR=vim" >> /home/vcap/.bashrc
# fi

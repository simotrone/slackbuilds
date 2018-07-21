if [ -x sbin/depmod ]; then
  chroot . /sbin/depmod -a @KERNEL@ 2>/dev/null
fi

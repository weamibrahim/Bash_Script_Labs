
source checker.sh
source menu.sh
checkFile "settings"
[ ${?} -ne 0 ] && exit 1
checkRFile "settings"
[ ${?} -ne 0 ] && exit 2
source settings

runMenu


exit 0





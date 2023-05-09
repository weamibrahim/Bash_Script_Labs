
function checkInt {
	[ ${#} -ne 1 ] && return 2
	C=$(echo ${1} | grep -c "^[0-9]*$")
	[ ${C} -eq 0 ] && return 1
	return 0
}


function checkRange {
	[ ${#} -ne 3 ] && return 2
	local START=${1}
	local END=${2}
	local NUM=${3}
	if [ ${NUM} -ge ${START} ] && [ ${NUM} -le ${END} ]
	then
		return 0
	else
		return 1
	fi
}


function checkIPv4 {
	[ ${#} -ne 1 ] && return 2
	##IPv4 : 4octet x.x.x.x
	OCT1=$(echo ${1} | awk ' BEGIN { FS="." } { print $1 } ')
	OCT2=$(echo ${1} | awk ' BEGIN { FS="." } { print $2 } ')
	OCT3=$(echo ${1} | awk ' BEGIN { FS="." } { print $3 } ')
	OCT4=$(echo ${1} | awk ' BEGIN { FS="." } { print $4 } ')
	checkInt ${OCT1}
	[ ${?} -ne 0 ] && return 1
	checkInt ${OCT2}
	[ ${?} -ne 0 ] && return 1
	checkInt ${OCT3}
	[ ${?} -ne 0 ] && return 1
	checkInt ${OCT4}
	[ ${?} -ne 0 ] && return 1
	checkRange 0 255 ${OCT1}
	[ ${?} -ne 0 ] && return 1
	checkRange 0 255 ${OCT2}
	[ ${?} -ne 0 ] && return 1
	checkRange 0 255 ${OCT3}
	[ ${?} -ne 0 ] && return 1
	checkRange 0 255 ${OCT4}
	[ ${?} -ne 0 ] && return 1
	return 0
}

function checkFile {
	FILENAME=${1}
	if [ -f ${FILENAME} ]
	then
		return 0
	else
		return 1
	fi
}

function checkRFile {
        FILENAME=${1}
        if [ -r ${FILENAME} ]
        then
                return 0
        else
                return 1
        fi
}


function checkWFile {
        FILENAME=${1}
        if [ -w ${FILENAME} ]
        then
                return 0
        else
                return 1
        fi
}



function checkInteger {
	VAL=${1}
	if [ $(echo ${VAL} | grep -c "^[0-9]*$") -eq 1 ]
	then
		return 0
	else
		return 1
	fi
}

function checkNInteger {
        VAL=${1}
        if [ $(echo ${VAL} | grep -c "^\-\{0,1\}[0-9]*$") -eq 1 ]
        then
                return 0
        else
                return 1
        fi
}

function checkFloatPoint {
	local V=1
}


function checkEMail {
        VAL=${1}
        if [ $(echo ${VAL} | grep -c "^[0-9]*$") -eq 1 ]
        then
                return 0
        else
                return 1
        fi
}







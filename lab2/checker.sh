
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
	VAL=${1}
    CHECK=$(echo "${VAL}" | grep -Eq '^[-+]?[0-9]+\.?[0-9]*$')
    if [  ${?} -eq 1 ]
    then
        return 1
    else
        return 0
    fi

}

function checkEMail {
    VAL=${1}
    CHECK=$(echo ${VAL} | grep -Eq "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
    if [ ${?} -eq 1 ]
    then
        return 1
    else
        return 0
    fi
}







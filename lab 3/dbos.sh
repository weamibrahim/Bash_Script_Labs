source checker.sh


function checkID {
	[ ${#} -ne 1 ] && return 1
	checkInt ${1}
	[ ${?} -ne 0 ] && return 2
	RES=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "select id from ${MYSQLDB}.inv where (id=${1})")
        [ ! -z "${RES}" ] && return 3
	return 0
}

function authenticate {
	echo "Authentication.."
	CURUSER=""
	echo -n "Enter your username: "
	read USERNAME
	echo -n "Enter your password: "
	read -s PASSWORD
	
	RES=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "select username from ${MYSQLDB}.users where (username='${USERNAME}') and (password=md5('${PASSWORD}'))")
	if [ -z "${RES}" ]
	then
		echo "Invalid credentials"
		return 1
	else
		CURUSER=${USERNAME}
		echo "Welcome ${CURUSER}"
	fi
	return 0
}


function converttexttodb {
    echo "Convert text to database"

	if [ -z ${CURUSER} ] 
	then
		echo "Authenticate first"
		return 1
	fi
    checkFile "invdata"
    [ ${?} -ne 0 ] && exit 2
    checkRFile "invdata"
    [ ${?} -ne 0 ] && exit 3

    checkFile "invdet"
    [ ${?} -ne 0 ] && exit 4
    checkRFile "invdet"
    [ ${?} -ne 0 ] && exit 5

    cat invdata | sed '1d' | while read p; do
        local ID=$(echo ${p} | awk ' BEGIN { FS=":" } { print $1 } ')
        local CUSTOMERNAME=$(echo ${p} | awk ' BEGIN { FS=":" } { print $2 } ')
        local DATE=$(echo ${p} | awk ' BEGIN { FS=":" } { print $3 } ')
        echo "insert into ${MYSQLDB}.inv (id,customername,date) values (${ID},'${CUSTOMERNAME}','${DATE}')"

        mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "insert into ${MYSQLDB}.inv (id,customername,date) values (${ID},'${CUSTOMERNAME}','${DATE}')"
    done

    cat invdet | sed '1d' | while read p; do
        local SERIAL=$(echo ${p} | awk ' BEGIN { FS=":" } { print $1 } ')
        local INVID=$(echo ${p} | awk ' BEGIN { FS=":" } { print $2 } ')
        local PRODID=$(echo ${p} | awk ' BEGIN { FS=":" } { print $3 } ')
        local QUANTITY=$(echo ${p} | awk ' BEGIN { FS=":" } { print $4 } ')
        local PRICE=$(echo ${p} | awk ' BEGIN { FS=":" } { print $5 } ')
        
        mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "insert into ${MYSQLDB}.invdet (serial, inv_id, prodid, quantity, price) values ('${SERIAL}', '${INVID}' , '${PRODID}', '${QUANTITY}', '${PRICE}')"
    done

}



function queryinvoice {
	echo "Query invoice"
	if [ -z ${CURUSER} ] 
	then
		echo "Authenticate first"
		return 1
	fi
	echo -n "Enter invoice id : "
    read INVID
    checkInt ${INVID}
    [ ${?} -ne 0 ] && echo "Invalid integer format" && return 2
  
    checkID ${INVID}
    [ ${?} -eq 0 ] && echo "ID ${INVID} not exists!" && return 3

	RES=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -s -e "select * from ${MYSQLDB}.inv where (id=${INVID})"| tail -1)
	ID=${INVID}
	CUSTOMERNAME=$(echo "${RES}"| awk ' { print $2 } ')
	DATE=$(echo "${RES}" | awk ' {  print $3 } ')
	echo "Invoice ID: ${INVID}"
	echo "Invoice date : ${DATE}"
	echo "Customer name : ${CUSTOMERNAME}"

    NUMBEROFPRODUCTS=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -s -e "select COUNT(*) from ${MYSQLDB}.invdet where (inv_id=${INVID})" | tail -1)

	echo "Details: "
    echo -e "Product ID\tQuantity\tunit price\tTotal product "
    COUNTER=1
    TOTAL=0
    while [ ${NUMBEROFPRODUCTS}  -ge ${COUNTER} ]
    do
        PRODUCT=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -s -e "select * from ${MYSQLDB}.invdet where (inv_id=${INVID})" | sed -n "${COUNTER}p")
        
        local SERIAL=$(echo ${PRODUCT} | awk ' { print $1 } ')
        local INVID=$(echo ${PRODUCT} | awk ' { print $2 } ')
        local PRODID=$(echo ${PRODUCT} | awk ' { print $3 } ') 
        local QUANTITY=$(echo ${PRODUCT} | awk ' { print $4 } ')
        local PRICE=$(echo ${PRODUCT} | awk ' { print $5 } ')
        local PRODUCTTOTALPRICE=$(echo ${QUANTITY} \* ${PRICE} | bc)
        echo  -e "${PRODID}\t\t${QUANTITY}\t\t${PRICE}\t\t${PRODUCTTOTALPRICE} \t"
        COUNTER=$[${COUNTER} + 1]
        TOTAL=$[${PRODUCTTOTALPRICE} + ${TOTAL}]
    done

    echo "==================================================="
    echo "Invoice total: ${TOTAL}"
	return 0
}


function insertinvoice {
	local OPT
	echo "Insert"
	echo "Query"
        if [ -z ${CURUSER} ]
        then
                echo "Authenticate first"
                return 1
        fi
	echo -n "Enter invoice id : "
	read INVID
	checkInt ${INVID}
	[ ${?} -ne 0 ] && echo "Invalid integer format" && return 1

	checkID ${INVID}
	[ ${?} -ne 0 ] && echo "ID ${CUSTID} is already exists!!" && return 3

	echo -n "Enter invoice customer name : "
	read CUSTNAME
	echo -n "Enter invoice date : "
	read DATE

    echo -n "Enter serial id : "
    read SERIAL

    echo -n "Enter product id : "
    read PRODID

	checkInt ${PRODID}
	[ ${?} -ne 0 ] && echo "Invalid integer format" && return 4

    echo -n "Enter product quantity : "
    read QUANTITY
	checkInt ${QUANTITY}
	[ ${?} -ne 0 ] && echo "Invalid integer format" && return 5

    echo -n "Enter product price : "
    read PRICE
	checkInt ${PRICE}
	[ ${?} -ne 0 ] && echo "Invalid integer format" && return 6
    
	echo -n "Save (y/n)"
	read OPT
	case "${OPT}" in
		"y")
			mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "insert into ${MYSQLDB}.inv (id,customername,date) values (${INVID},'${CUSTNAME}','${DATE}')"
            mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "insert into ${MYSQLDB}.invdet (serial, inv_id, prodid, quantity, price) values (${SERIAL} ,${INVID},${PRODID},'${QUANTITY}','${PRICE}')"
			echo "Done .."
			;;
		"n")
			echo "Discarded."
			;;
		*)
			echo "Invalid option"
	esac
	return 0
}

function deleteinvoice {
	echo "Delete"
	local OPT
        if [ -z ${CURUSER} ]
        then
                echo "Authenticate first"
                return 1
        fi
	echo -n "Enter invoice id : "
        read INVID
        checkInt ${INVID}
        [ ${?} -ne 0 ] && echo "Invalid integer format" && return 2
   
        checkID ${INVID}
        [ ${?} -eq 0 ] && echo "ID ${INVID} not exists!" && return 3
 
        RES=$(mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -s -e "select * from ${MYSQLDB}.inv where (id=${INVID})"| tail -1)
        ID=${INVID}
        CUSTNAME=$(echo "${RES}"| awk ' { print $2 } ')
        DATE=$(echo "${RES}" | awk ' {  print $3 } ')
        echo "Details of invoice id ${INVID}"
        echo "invoice customer name : ${CUSTNAME}"
        echo "Invoice date : ${DATE}"
	echo -n "Delete (y/n)"
        read OPT
        case "${OPT}" in
                "y")
                        mysql -h ${MYSQLHOST} -u ${MYSQLUSER} -p${MYSQLPASS} -e "delete from ${MYSQLDB}.inv where id=${INVID}"
                        echo "Done .."
                        ;;
                "n")
                        echo "not deleted."
                        ;;
                *)
                        echo "Invalid option"
        esac



	return 0
}


source dbos.sh
CURUSER=""
function runMenu {
	echo "Enter option (1-6)"
local OPT=0
while [ ${OPT} -ne 6 ]
do
echo -e "\t1-Authenitcate"
echo -e "\t2-Convert text to database"
echo -e "\t3-Query a invoice"
echo -e "\t4-Insert a new invoice"
echo -e "\t5-Delete an existing invoice"
echo -e "\t6-Quit"
echo -e "Please choose a menu from 1 to 6"
read OPT
case "${OPT}" in
	"1")
		authenticate
		;;
	"2")
		converttexttodb
		;;
	"3")
		queryinvoice
		;;
	"4")
		insertinvoice
		;;
	"5")
		deleteinvoice
		;;
	"6")
		echo "Bye bye.."
		;;
	*)
		echo "Sorry, invalid option, try again"
esac
done
}

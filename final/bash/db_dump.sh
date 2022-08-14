#!/bin/bash

DST=/local/files
BUP=/local/backup
RED='\033[0;31m'
NC='\033[0m' # No Color
#functions#############################################################
usage()
{
echo "This script could make a CVS dump of the database and pack old dumps to an archive"
echo -e "USAGE: \n -u "DB username" \n -d "database" \n \n -c {compression value from 1 {faster} to 9 {better compression}} \n Password must be stored in .pgpass file (chmod 0600)"
}

dump_cvs()
{
#PGPASSWORD="$PASS"
psql -U $USR -d $DB -A -F"," --pset footer -c "select ar.id, ar.magazines_id, mag.name, ar.article_type_id, art.type, ar.author_id, aut.author from articles ar left join article_types art on art.id = ar.article_type_id left join author aut on ar.author_id = aut.id left join magazines mag on ar.magazines_id = mag.id;" > $DST/dump_`date +"%Y_%m_%d-%H_%M_%S"`.cvs
}

files_count()
{
COUNT=`find $DST -type f |wc -l`
}

make_archive()
{
tar cf $BUP/archive_`date +"%Y_%m_%d-%H_%M_%S"`.tar.gz --use-compress-program="gzip $GZIP" $DST
}

clean_files()
{
rm -f $DST/*
}
#options#############################################################
while getopts ":u:d:c:hh:" arg
do
case $arg in
h)  usage ; exit 0 ;; #how to use
u)  USR=${OPTARG} ;;  #username
d)  DB=${OPTARG} ;;  #database
c)  GZIP=-${OPTARG} ;; #compression ratio
esac
done


#if no options was given - show help
if [[ $# -lt 1  ]]
then
usage
exit 1
fi

#some values was missed
if
[[ -z $USR ]] || [[ -z $DB ]]; #|| [[ -z $PASS ]];
then
echo -e "${RED}There is some of the authentication params are missed. Please read help ${NC}\n"
usage
exit 1

fi

#set compression = 5 if not defined
if
[[ -z $GZIP ]];
then
GZIP=-5

fi

#check files count

#echo "$USR, $DB, $PASS, $GZIP"

files_count

#if there is more than 3 files - move them to the arhive
if
[[ $COUNT -ge 3 ]];
then
make_archive
clean_files

fi

dump_cvs

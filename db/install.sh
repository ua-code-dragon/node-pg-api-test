#!/bin/bash

pushd `dirname $0` > /dev/null

_error(){
    echo "ERROR: $*" >&2
    kill $$
    exit -1
}

_ME=$(readlink -f "$0")
PWD=$(dirname "${_ME}")

[ -z "$PGHOST" ] && source "${PWD}/env.sh"
[ -z "$PGHOST" ] && source "${PWD}/env.local.sh"
[ -z "$PGHOST" ] && _error "No database credentials"

command -v psql > /dev/null || _error "No postgresql client installed"

sqltmp=$(mktemp /tmp/db-sql-script.XXXXXX)

echo "\\set ON_ERROR_STOP true" > $sqltmp
echo "begin transaction;" >> $sqltmp
    for f in extensions schemas types
    do
        [ -f "${PWD}/structure/$f.sql" ] && cat "${PWD}/structure/$f.sql" >> $sqltmp
    done
echo "commit;" >> $sqltmp

PP=$PGPASSWORD
export PGPASSWORD=$PGSUPERPASSWORD
psql -h $PGHOST -p $PGPORT $PGDB $PGSUPERUSER < $sqltmp || echo "ERROR (in: ${sqltmp})"
export PGPASSWORD=$PP

echo "\\set ON_ERROR_STOP true" > $sqltmp
echo "begin transaction;" >> $sqltmp
    for sd in `ls -d ${PWD}/structure/schema/*/`
    do
        ss=$(basename "${sd}")
        echo "set search_path to ${ss},pg_catalog;" >> $sqltmp
        for tp in tables views functions alter data
        do
            for sf in `ls ${sd}${tp}/*.sql 2>/dev/null`
            do
                cat $sf >> $sqltmp
            done;
        done;
    done
    echo "set search_path to public,pg_catalog;" >> $sqltmp
echo "commit;" >> $sqltmp

psql -h $PGHOST -p $PGPORT $PGDB $PGUSER < $sqltmp && rm $sqltmp || echo "ERROR (in: ${sqltmp})"

exit 0





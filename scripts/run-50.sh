#!/bin/sh
COUNT=0
MAX=50
VERSION1=0
VERSION2=0
while [ $COUNT -lt $MAX ];
do
  OUTPUT=$(curl $FRONTEND_URL -s -w "Elapsed Time:%{time_total}")
  VERSION=$(echo $OUTPUT|awk -F'Backend version:' '{print $2}'| awk -F',' '{print $1}')
  TIME=$(echo $OUTPUT| awk -F"Elapsed Time:" '{print $2}'|awk -F'#' '{print $1}')
  echo "Backend:$VERSION Elapsed Time:$TIME sec"
  COUNT=$(expr $COUNT + 1)
  if [ $VERSION == "1.0.0" ];
  then
     VERSION1=$(expr $VERSION1 + 1)
  fi
  if [ $VERSION == "2.0.0" ];
  then
     VERSION2=$(expr $VERSION2 + 1)
  fi
done
echo "========================================================"
echo "Total Request: $MAX"
echo "Version 1.0.0: $VERSION1"
echo "Version 2.0.0: $VERSION2"
echo "========================================================"

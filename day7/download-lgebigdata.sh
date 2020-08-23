#!/bin/bash
TARGET="/Users/psyoblade/git/psyoblade/data-engineer-intermediate-training/day7/notebooks/data/KT_data_20200717"

echo "10초 후 다음 경로로 이동 및 다운로드 합니다 $TARGET"
echo "cd $TARGET"

for x in $(seq 1 10); do
    echo -ne "."
    sleep 1
done

cd $TARGET 
filenames="delivery.csv fpopl.csv card_20200717.csv df_card01.csv df_card02.csv df_card03.csv df_card04.csv df_card05.csv df_card06.csv"
s3root="https://psyoblade-faces.s3.ap-northeast-2.amazonaws.com/lgebigdata"

for filename in $filenames; do
    wget $s3root/$filename
done


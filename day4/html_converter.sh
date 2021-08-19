#!/bin/bash
lectures="core delta stream troubleshoot"
for lecture in $lectures; do
    notebook="lgde-spark-$lecture"
    notepath="notebooks/$notebook"
    echo "processing notebook('$notepath')"
    rm $notepath/*.html
    docker-compose exec notebook sh -c "jupyter nbconvert work/$notebook/*.ipynb --to html"
    sleep 5
done

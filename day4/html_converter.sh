#!/bin/bash
rm notebooks/*.html
docker-compose exec notebook sh -c "jupyter nbconvert work/*.ipynb --to html"

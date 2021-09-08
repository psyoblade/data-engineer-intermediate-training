#!/bin/bash
rm work/*.html
docker-compose exec notebook sh -c "jupyter nbconvert work/*.ipynb --to html"
docker-compose exec notebook sh -c "jupyter nbconvert work/answer/*.ipynb --to html"

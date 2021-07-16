#!/bin/bash
curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:9880/test

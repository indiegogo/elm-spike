#!/bin/sh
elm-live --before-build=./build-support/before-build.sh src/Main.elm --output assets/elm.js --open


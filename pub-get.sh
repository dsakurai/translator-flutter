#!/usr/bin/env bash
set -e

(cd server     && dart --disable-analytics && dart pub get)
(cd client     && flutter config --no-analytics && flutter pub get)
(cd translator && flutter config --no-analytics && flutter pub get)

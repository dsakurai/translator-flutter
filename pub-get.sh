#!/usr/bin/env bash
set -e

(cd server      && dart --disable-analytics && dart pub get)
(cd translator && flutter pub get)

#! /usr/bin/env bash
set -e

if [[ "" = "$1" ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
	echo "No day nb passed"
	exit 1
fi
day_nb=$1

mkdir -p "${day_nb}"/{elixir,in,out}

cp utils/templates/day.exs "${day_nb}"/elixir/day"${day_nb}".exs

cp utils/templates/zero "${day_nb}"/in/example
cp utils/templates/zero "${day_nb}"/in/solve
cp utils/templates/zero "${day_nb}"/out/example.1
cp utils/templates/zero "${day_nb}"/out/example.2
cp utils/templates/zero "${day_nb}"/out/solve.1
cp utils/templates/zero "${day_nb}"/out/solve.2
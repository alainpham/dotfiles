#!/bin/bash

# === Check for input ===
if [ -z "$1" ]; then
    echo "Usage: $0 <IMDb_ID> (e.g., tt0111161)"
    exit 1
fi

IMDB_ID="$1"
API_KEY="$TMDB_API_KEY" # should bedefined in PATH ans env var

# === Query TMDb API ===
response=$(curl -s "https://api.themoviedb.org/3/find/$IMDB_ID?api_key=$API_KEY&external_source=imdb_id")

# === Extract title and release year ===
raw_title=$(echo "$response" | jq -r '.movie_results[0].title')
year=$(echo "$response" | jq -r '.movie_results[0].release_date' | cut -d- -f1)

# === Sanitize title: remove non-ASCII, replace spaces with dots ===
clean_title=$(echo "$raw_title" | iconv -c -f utf-8 -t ascii | tr ' ' '.' | tr '[:upper:]' '[:lower:]')


# === Check and output ===
if [[ "$clean_title" == "" || "$year" == "" || "$clean_title" == "null" ]]; then
    echo "Movie not found or invalid IMDb ID: $IMDB_ID"
    exit 2
fi

echo "$clean_title.$year.imdbid-${IMDB_ID}"


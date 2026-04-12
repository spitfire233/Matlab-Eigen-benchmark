#!/bin/bash

# Array of file URLs
urls=(
	"https://suitesparse-collection-website.herokuapp.com/mat/Janna/StocF-1465.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Janna/Flan_1565.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Rothberg/cfd2.mat"
	"https://suitesparse-collection.herokuapp.com/mat/Rothberg/cfd1.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/AMD/G3_circuit.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Wissgott/parabolic_fem.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/GHS_psdef/apache2.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/MaxPlanck/shallow_water1.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/FIDAP/ex15.mat"
)

# Directory to save downloads
download_dir="./matrices"

# Check if directory already exists
if [ -d "$download_dir" ]; then
  echo "Directory '$download_dir' already exists. Skipping download."
  exit 0
fi

# Create directory
mkdir -p "$download_dir"

for url in "${urls[@]}"; do
  filename=$(basename "$url")
  filepath="$download_dir/$filename"

  if [ -f "$filepath" ]; then
    echo "Skipping existing file: $filename"
    continue
  fi

  echo "Downloading: $url"
  curl -L "$url" -o "$filepath"
  echo "Saved to: $filepath"
done

echo "All downloads completed."
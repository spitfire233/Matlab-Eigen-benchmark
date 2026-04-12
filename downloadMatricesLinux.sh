#!/bin/bash

# Array of file URLs
urls=(
	"https://suitesparse-collection-website.herokuapp.com/mat/Janna/StocF-1465.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Janna/Flan_1565.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Rothberg/cfd2.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Rothberg/cfd1.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/AMD/G3_circuit.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/Wissgott/parabolic_fem.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/GHS_psdef/apache2.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/MaxPlanck/shallow_water1.mat"
	"https://suitesparse-collection-website.herokuapp.com/mat/FIDAP/ex15.mat"
)

# Directory to save downloads
download_dir="./matrices"

# Create directory if it doesn't exist
mkdir -p "$download_dir"

# Loop through URLs and download each file
for url in "${urls[@]}"; do
  echo "Downloading: $url"
  
  # Extract filename from URL
  filename=$(basename "$url")
  
  # Download file
  curl -L "$url" -o "$download_dir/$filename"
  
  # Alternative with wget:
  # wget -P "$download_dir" "$url"

  echo "Saved to: $download_dir/$filename"
done

echo "All downloads completed."

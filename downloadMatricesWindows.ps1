# Array of file URLs
$urls = @(
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
$downloadDir = ".\matrices"

# If directory already exists → skip everything
if (Test-Path $downloadDir) {
    Write-Host "Directory '$downloadDir' already exists. Skipping download."
    exit
}

# Create directory
New-Item -ItemType Directory -Path $downloadDir | Out-Null

# Array of file URLs
$urls = @(
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
$downloadDir = ".\matrices"

# If directory already exists → skip everything
if (Test-Path $downloadDir) {
    Write-Host "Directory '$downloadDir' already exists. Skipping download."
    exit
}

# Create directory
New-Item -ItemType Directory -Path $downloadDir | Out-Null

# Loop through URLs and download each file
foreach ($url in $urls) {
    Write-Host "Downloading: $url"

    $filename = [System.IO.Path]::GetFileName($url)
    $outputPath = Join-Path $downloadDir $filename

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Host "Saved to: $outputPath"
    }
    catch {
        Write-Host "Failed to download: $url"
        Write-Host $_
    }
}

Write-Host "All downloads completed."
Write-Host "All downloads completed."
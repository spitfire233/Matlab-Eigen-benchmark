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

# Create directory if it doesn't exist
if (!(Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir | Out-Null
}

# Loop through URLs and download each file
foreach ($url in $urls) {
    Write-Host "Downloading: $url"

    # Extract filename from URL
    $filename = [System.IO.Path]::GetFileName($url)

    # Full output path
    $outputPath = Join-Path $downloadDir $filename

    try {
        # Download file
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing

        Write-Host "Saved to: $outputPath"
    }
    catch {
        Write-Host "Failed to download: $url"
        Write-Host $_
    }
}

Write-Host "All downloads completed."

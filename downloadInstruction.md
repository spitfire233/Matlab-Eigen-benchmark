# File Downloader Usage Guide (Bash & PowerShell)

This guide shows **how to run** the provided downloader scripts.

---

# 🐧 Bash Script Usage

## Run the script

```bash
bash ./downloadMatricesLinux.sh
```

## What it does

* Downloads each URL in the list
* Saves files into the `downloads` folder (created automatically)

---

# 🪟 PowerShell Script Usage

## Run the script

```powershell
.\downloadMatricesWindows.ps1
```

## If blocked by execution policy

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## What it does

* Downloads each URL in the list
* Saves files into the `downloads` folder (created automatically)

---



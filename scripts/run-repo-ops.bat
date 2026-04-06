@echo off
REM Batch wrapper to run the PowerShell manage-repo script from any directory.
REM Usage: run-repo-ops.bat -Action reorganize -RepoPath C:\path\to\repo

set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%manage-repo.ps1" %*

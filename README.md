<!-- 14.08.2025 17:25 - README for GitHub: CRLF/LF issue under Windows and Docker, updated with file list -->

# CRLF and LF on Windows and Docker ⚙️

**Two simple batch files to detect and fix EOL issues in server-relevant files when working on Windows but deploying to Linux/Docker.**

## Problem

When working on **Windows**, files are saved with `CRLF` line endings by default.  
**Linux** systems (including those inside Docker containers) expect `LF`.  
For server-relevant files like scripts and configs, having the wrong line endings can cause errors such as:

-  Shell scripts failing with cryptic messages
-  `bash` or `sh` reporting `Command not found`
-  Misinterpretation of carriage return characters

## Solution

This repository provides two batch files created with the help of generative AI:

-  **check-eol.bat** → Scans the project folder for files with incorrect line endings and lists them.
-  **fix-eol.bat** → Automatically converts the EOL of server-relevant files to the recommended format (LF for scripts/configs).

## Supported file types

-  `.sh`, `.py`, `.php`
-  `.conf`, `.ini`, `.env`, `.yml`, `.yaml`
-  `Dockerfile`, `docker-compose.yml`
-  `.sql`, `.cgi`, `.pl`

Files like `.html`, `.css`, `.txt` are ignored since their line endings typically do not cause server issues.

## Usage

1. **Backup your project first!**
2. Run `check-eol.bat` to see which files are non-compliant.
3. If needed, run `fix-eol.bat` to automatically correct the EOLs.

## Important ⚠️

-  Always back up your files before running the fixing script.
-  **No warranty** – use at your own risk.

## License

MIT License – see [LICENSE](LICENSE).

## Included Files 📂

-  `fix-eol-server-to-lf_V_1_DE.bat` – Fixes EOL for server-relevant files (German comments).
-  `fix-eol-server-to-lf_V_1_EN.bat` – Fixes EOL for server-relevant files (English comments).
-  `list-noncompliant-eol_rel_V_1_DE.bat` – Lists non-compliant files (German comments).
-  `list-noncompliant-eol_rel_V_1_EN.bat` – Lists non-compliant files (English comments).

<!-- 14.08.2025 17:25 - End of README -->

This file is a merged representation of the entire codebase, combined into a single document by Repomix.
The content has been processed where comments have been removed, empty lines have been removed, content has been compressed (code blocks are separated by ⋮---- delimiter).

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Code comments have been removed from supported file types
- Empty lines have been removed from all files
- Content has been compressed - code blocks are separated by ⋮---- delimiter
- Files are sorted by Git change count (files with more changes are at the bottom)

## Additional Info

# Directory Structure
```
.gitattributes
core/versioning_manager.py
pack_repo.ps1
```

# Files

## File: pack_repo.ps1
```powershell
# pack_repo.ps1 (fixed version)
# PowerShell script to run Repomix and pack the current folder automatically

# Add global npm bin folder to PATH (if not already added)
$NpmBinPath = "$env:APPDATA\npm"
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $NpmBinPath })) {
    $env:Path += ";$NpmBinPath"
}

# Ensure the script is run from the directory you want to pack
$CurrentDir = Get-Location
$OutputFile = "$($CurrentDir.Path)\packed_repo.md"

# Confirm repomix is available
try {
    repomix --version | Out-Null
} catch {
    Write-Error "❌ Repomix is not installed or not found even after PATH fix. Please reinstall with 'npm install -g repomix'."
    exit
}

# Run repomix with desired options
Write-Output "🚀 Packing repository from: $CurrentDir"
repomix -o "$OutputFile" --compress --remove-comments --remove-empty-lines --style markdown

# Confirm output
if (Test-Path $OutputFile) {
    Write-Output "✅ Repository packed successfully: $OutputFile"
} else {
    Write-Error "❌ Failed to create output file."
}
```

## File: .gitattributes
```
# Auto detect text files and perform LF normalization
* text=auto
```

## File: core/versioning_manager.py
```python
class VersioningManager
⋮----
def __init__(self,p):self.p=pathlib.Path(p);self.b=self.p/'backups';self.pa=self.p/'patches';self.s=self.p/'schemas';self.l=self.p/'logs'/'log.txt';self.v=self.p/'core'/'version.json';self._i()
def _i(self):[d.mkdir(parents=True,exist_ok=True) for d in [self.b,self.pa,self.s,self.p/'logs']];(lambda:json.dump({"version":"0.1.0"},open(self.v,'w')) if not self.v.exists() else None)()
def _is_valid_version(self,v):return bool(re.match(r'^\d+\.\d+\.\d+(-[0-9A-Za-z-.]+)?$',v))
def get_version(self):return json.load(open(self.v))["version"]
def set_version(self,n):[(_ for _ in ()).throw(ValueError("Invalid version string.")) if not self._is_valid_version(n) else None];json.dump({"version":n},open(self.v,'w'));self._log(f"Version updated to {n}")
def backup(self):d=self.b/f"backup_{self.get_version()}";shutil.rmtree(d,ignore_errors=True);shutil.copytree(self.p,d,ignore=shutil.ignore_patterns('backups','patches','logs'));self._log(f"Backup created at {d}")
def patch(self,n,c):json.dump(c,open(self.pa/f"{n}.patch",'w'),indent=4);self._log(f"Patch {n} created.")
def apply_patch(self,n):p=self.pa/f"{n}.patch";[(_ for _ in ()).throw(FileNotFoundError("Patch file does not exist.")) if not p.exists() else None];[(open(self.p/t,'w').write(c)) for t,c in json.load(open(p)).items()];self._log(f"Patch {n} applied.")
def validate_structure(self,f):e=json.load(open(f));m=[i for i in e.get("files",[]) if not (self.p/i).exists()]+[i for i in e.get("folders",[]) if not (self.p/i).is_dir()];return m
def enforce_schema(self,n):s=self.s/f"{n}.json";[(_ for _ in ()).throw(FileNotFoundError("Schema file missing.")) if not s.exists() else None];d=json.load(open(s));[(lambda p,c:[(_ for _ in ()).throw(FileNotFoundError(f"Required file missing: {p}")) if not (self.p/p).exists() else None,(lambda x:[(_ for _ in ()).throw(ValueError(f"Schema mismatch in {p}")) if not difflib.SequenceMatcher(None,x,c).ratio()>0.9 else None])(open(self.p/p).read())]) for p,c in d.get("files",{}).items()];self._log(f"Schema {n} enforced successfully.")
def check_integrity(self):h={str(x.relative_to(self.p)):hashlib.sha256(open(x,'rb').read()).hexdigest() for x in self.p.rglob('*') if x.is_file() and not any(k in x.parts for k in ['backups','patches','logs'])};json.dump(h,open(self.p/'core'/'integrity.json','w'),indent=4);self._log("Integrity hashes updated.")
def compare_integrity(self):i=self.p/'core'/'integrity.json';[(_ for _ in ()).throw(FileNotFoundError("Integrity file missing.")) if not i.exists() else None];r=json.load(open(i));d=[];[(lambda p:[d.append(f"Missing: {f}") if not (self.p/f).exists() else (d.append(f"Modified: {f}") if hashlib.sha256(open(self.p/f,'rb').read()).hexdigest()!=h else None)])(f,h) for f,h in r.items()];return d
def compare_directories(self,d1,d2):dc=filecmp.dircmp(d1,d2);return {"left_only":dc.left_only,"right_only":dc.right_only,"diff_files":dc.diff_files}
def update_schema(self,n):s={"files":[],"folders":[]};[(s["files"].append(str(p.relative_to(self.p))) if p.is_file() else s["folders"].append(str(p.relative_to(self.p)))) for p in self.p.rglob('*')];json.dump(s,open(self.s/f"{n}.json",'w'),indent=4);self._log(f"Schema {n} updated.")
def _log(self,m):open(self.l,'a').write(f"{m}\n")
```

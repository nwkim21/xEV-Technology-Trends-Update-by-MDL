# auto-push.ps1 — Cowork 예약 작업이 갱신한 index.html을 GitHub Pages로 자동 푸시
# 호출: Windows 작업 스케줄러 (매주 월 04:30)

# --- 콘솔/로그 UTF-8 강제 (한글 깨짐 방지) ---
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Continue"
$repoPath = "C:\Users\namwook\git\xEV-Technology-Trends-Update-by-MDL"
$logPath  = Join-Path $repoPath "auto-push.log"

function Log($msg) {
  $line = "$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))  $msg"
  $line | Out-File -FilePath $logPath -Append -Encoding utf8
  Write-Host $line
}

if (-not (Test-Path $repoPath)) {
  Log "ERROR: repo 경로 없음 — $repoPath"
  exit 1
}

Set-Location $repoPath

# git 사용 가능 확인
$gitVersion = git --version 2>$null
if (-not $gitVersion) {
  Log "ERROR: git 명령을 찾을 수 없음. Git for Windows 설치 확인 필요"
  exit 1
}

# 변경사항 확인
$status = git status --porcelain 2>$null
if (-not $status) {
  Log "변경 없음 — push 건너뜀"
  exit 0
}

Log "변경 감지:"
$status -split "`n" | ForEach-Object { Log "  $_" }

# add + commit
git add -A 2>&1 | Out-Null
$commitMsg = "Auto-update $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm'))"
$commitOut = git commit -m $commitMsg 2>&1
$commitOut | ForEach-Object { Log "  $_" }

if ($LASTEXITCODE -ne 0) {
  Log "ERROR: git commit 실패"
  exit 1
}

# push
Log "push 시도 중..."
$pushOut = git push origin main 2>&1
$pushOut | ForEach-Object { Log "  $_" }

if ($LASTEXITCODE -eq 0) {
  Log "푸시 성공"
  Log "→ https://nwkim21.github.io/xEV-Technology-Trends-Update-by-MDL/"
  exit 0
} else {
  Log "ERROR: git push 실패 — 자격증명/네트워크 확인 필요"
  exit 1
}

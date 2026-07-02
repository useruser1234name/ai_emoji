# ai_emoji 🐣 — Claude Code 데스크톱 마스코트

**Claude Code가 코드를 짜는 동안, 내 최애 캐릭터가 화면 구석에서 실시간으로 반응하는 데스크톱 마스코트.**

Claude Code의 **hooks**를 이용해, 지금 무슨 작업을 하는지(코딩 / 커밋 / 푸시 / 테스트 / 배포…)와
사용자의 기분(고마워 / 짜증 / 거절…)을 감지해서, 화면 우측 하단의 캐릭터가 **말풍선 + 표정**으로 반응합니다.
말투는 기본으로 **츤데레**로 세팅되어 있어요. 😳

> 예) 코드를 다 짜면 → *"검토 안 해? 어차피 내가 짠 거 완벽할 텐데. 흥."* 😏
> 커밋하면 → *"이 기록이 나중에 널 구해줄 거라고."* ✍️
> 거절 버튼 누르면 → *"거절이라니... 내 편이어야 되잖아... (훌쩍)"* 😭

---

## ✨ 특징

- 🖼️ **캐릭터 = 사진 / 움짤(GIF) / 이모지** — 아무거나 OK. 상태마다 다른 이미지 지정 가능
- 💬 **상태별 말풍선** — 여러 대사가 랜덤으로 출력, 전부 커스텀 가능
- 😳 **감정 이모지 스티커** — 캐릭터 옆에 상황에 맞는 표정이 랜덤으로 뜸
- 🧠 **작업 인식** — `git commit`, `git push`, `npm test`, `docker build` 등 **명령어를 실제로 읽어서** 구분
- 🗣️ **기분 인식** — "고마워", "짜증나" 같은 **내 메시지 키워드**에 반응
- ⚙️ **`config.json` 하나로 전부 커스텀** — 대사·표정·호칭·크기·속도, **저장 즉시 반영**(재시작 불필요)
- 🖥️ **터미널마다 독립 마스코트** — 여러 Claude Code 세션을 켜면 캐릭터가 화면 하단에 **나란히 하나씩** 뜨고, 각자 자기 세션 상태만 반영
- 🪟 항상 위에 뜨는 투명 창(테두리 없음), 드래그로 이동 / 우클릭으로 닫기

> ⚠️ **이미지는 포함되어 있지 않습니다.** 저작권 때문에 캐릭터 이미지·사진은 리포에 넣지 않았어요.
> 각자 원하는 이미지를 로컬 `images/` 폴더에 넣어 쓰세요 (개인 사용 권장).

---

## 📦 요구사항

- **Windows** (Windows 10/11)
- **Windows PowerShell 5.1** (윈도우 기본 내장) 또는 PowerShell 7+
- **Claude Code** (hooks 지원 버전)

---

## 🚀 설치

### 1) 파일 배치

**자동 설치 (권장)** — 리포를 clone/다운로드 후:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

→ 스크립트를 `~/.claude/mascot/` 로 복사하고, PowerShell 5.1이 한글을 깨뜨리지 않도록 `.ps1`을 UTF-8(BOM)으로 저장해줍니다. (기존 `config.json`은 덮어쓰지 않음)

**수동 설치** — 아래 구조로 직접 복사해도 됩니다:

```
~/.claude/mascot/
├─ mascot.ps1
├─ set-state.ps1
├─ config.json
├─ hooks/
│   ├─ on-prompt.ps1  on-pretool.ps1  on-accept.ps1
│   └─ on-perm.ps1    on-stop.ps1     on-error.ps1
└─ images/            ← 여기에 캐릭터 이미지
```

> 💡 **중요:** `.ps1` 파일은 반드시 **UTF-8 (BOM 포함)** 로 저장되어야 합니다.
> Windows PowerShell 5.1은 BOM 없는 UTF-8의 한글을 깨뜨려서 대사가 안 나오거나 오류가 납니다.
> (`install.ps1`이 자동으로 처리합니다. 직접 편집했다면 "UTF-8 with BOM"으로 저장하세요.)

### 2) hooks 등록

[`settings.hooks.example.json`](settings.hooks.example.json) 의 `"hooks"` 블록을
`~/.claude/settings.json` 에 병합하세요. (이미 `settings.json`이 있으면 최상위 객체 안에 `"hooks": { … }` 만 추가)

경로는 `%USERPROFILE%` 를 사용합니다. 만약 확장이 안 되면 절대경로(`C:\Users\사용자명\.claude\mascot\...`)로 바꾸세요.

### 3) Claude Code 재시작

hooks는 세션 시작 시 로드됩니다. **재시작하면** 그때부터 자동으로 반응해요.
재시작 없이 미리 보고 싶다면:

```powershell
Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"$env:USERPROFILE\.claude\mascot\mascot.ps1"
```

---

## 🎭 작동 방식 (상태 & 트리거)

Claude Code hooks가 상황을 감지해 `state.txt` 에 상태를 기록하면, 마스코트가 그 상태의 대사·표정으로 바뀝니다.

| 상태 | 언제 | 트리거(hook) |
|------|------|------|
| `thinking` | 질문을 보냈을 때 | UserPromptSubmit |
| `coding` | 파일 편집 / 일반 명령 | PreToolUse (Write/Edit/Bash…) |
| `committing` | `git commit` | PreToolUse (명령어 분석) |
| `pushing` | `git push` | PreToolUse |
| `deploy` | `deploy`/vercel/netlify/kubectl… | PreToolUse |
| `docker` | `docker …` | PreToolUse |
| `install` | `npm install`/`pip install`… | PreToolUse |
| `lint` | eslint/prettier/ruff… | PreToolUse |
| `testing` | `npm test`/pytest/jest… | PreToolUse |
| `waiting` | 권한 승인 창이 떴을 때 | Notification / PermissionRequest |
| `rejected` | 권한을 **거절**했을 때 | Stop (미해결 권한 감지) |
| `error` | 도구 실행이 실패했을 때 | PostToolUseFailure |
| `thanks` | "고마워/감사/thanks" 입력 | UserPromptSubmit (키워드) |
| `annoyed` | "짜증/화나/왜 안돼" 입력 | UserPromptSubmit (키워드) |
| `done` | 응답이 끝났을 때 | Stop |
| `idle` | 기본 대기 | — |

> **거절 감지 원리:** 권한창이 뜨면(`Notification`) 표시를 남기고, 도구가 실제로 실행되면(`PostToolUse`) 표시를 지웁니다.
> 응답이 끝났을 때(`Stop`) 표시가 남아있으면 = "실행 안 됨 = 거절"로 판단해 `rejected`(삐짐)로 전환합니다.
> hook 이벤트 미지원 버전에서는 조용히 `done` 으로만 뜨고 오류는 없습니다.

> **수동 테스트:** 아무 상태나 직접 띄워볼 수 있어요 →
> `powershell -File "$env:USERPROFILE\.claude\mascot\set-state.ps1" rejected preview`
> (마지막 인자는 세션 ID. 미리 `mascot.ps1 -SessionId preview` 로 띄워두고 테스트하세요.)

### 🖥️ 여러 터미널 = 여러 마스코트

Claude Code 세션(터미널)마다 **독립된 마스코트**가 하나씩 뜹니다.

- **SessionStart** hook이 세션의 고유 ID로 마스코트를 실행 → 여러 개를 켜면 화면 하단에 **가로로 나란히** 배치됩니다 (겹치지 않게 슬롯 자동 배정).
- 각 마스코트는 자기 세션의 상태 파일(`state-<세션ID>.txt`)만 봐서 **서로 간섭하지 않습니다.**
- **SessionEnd** hook이 그 세션의 마스코트만 닫습니다. (창 우클릭으로 수동 종료도 가능)
- 같은 세션에서 중복 실행되지 않도록 세션별 mutex로 보호됩니다.

---

## 🖼️ 이미지 / 움짤 넣기

`~/.claude/mascot/images/` 폴더에 파일을 넣으면 **즉시 반영**됩니다 (마스코트 재시작 불필요).

### 파일 이름 = 상태 이름

- **상태당 여러 표정(랜덤):** 폴더 `images/<상태>/` 를 만들고 그 안에 사진/움짤을 여러 장 넣으면, 그 상태가 될 때마다 **랜덤으로 한 장**이 뜹니다. (예: `images/done/` 에 웃는 사진 여러 장 → 완료 때마다 다른 표정)
- **상태별 한 장:** `coding.png`, `done.png`, `rejected.gif`, `thanks.png` … 처럼 파일 하나만 둬도 됩니다.
- **한 장으로 통일:** `character.png` (또는 `.gif`/`.jpg`) — 상태별 폴더·파일이 없으면 이걸 사용

### 우선순위

```
images/<상태>/ 폴더(랜덤)  →  <상태>.gif → <상태>.png → <상태>.jpg/.jpeg
  →  character.gif → character.png → character.jpg  →  (없으면) 이모지
```

### 팁

- **배경 투명 PNG/GIF** 를 쓰면 제일 예쁩니다.
- **GIF(움짤)** 지원 — 실제로 프레임이 재생됩니다. 속도는 `config.json`의 `fps`로 조절.
  - 움짤이 깨져 보이면 "un-optimized / full frames"로 다시 내보내세요.
- 가로 크기는 `config.json`의 `charWidth`(기본 150px) 기준으로 표시됩니다.
- 상태별로 표정 다른 사진을 넣으면(예: `rejected`=우는 짤) 대사와 찰떡이 됩니다.

---

## ⚙️ 커스텀 (`config.json`)

`config.json` 을 저장하는 순간 **바로 반영**됩니다. 전체 필드:

```jsonc
{
  "fps": 12,                // 움짤 재생 속도 (클수록 빠름)
  "charWidth": 150,         // 캐릭터(사진/움짤) 가로 px
  "emojiSize": 68,          // 사진 없을 때 나오는 이모지 캐릭터 크기
  "emotionSize": 34,        // 감정 이모지 스티커 크기
  "bubbleFontSize": 15,     // 말풍선 글자 크기
  "bubbleMaxWidth": 280,    // 말풍선 최대 너비 px
  "nickname": "야",         // 대사 속 {name} 이 이 호칭으로 치환됨

  "emojis": {               // 상태별 감정 이모지 (배열 = 랜덤)
    "coding":  ["😤", "⌨️", "💻"],
    "done":    ["😏", "😤", "💅", "✨"],
    "rejected":["😭", "😢", "🥺"]
    // thinking / waiting / committing / pushing / deploy / docker
    // / install / lint / testing / error / thanks / annoyed / idle ...
  },

  "messages": {             // 상태별 말풍선 대사 (배열 = 랜덤)
    "done": [
      "{name}, 다 됐어. 빨리 검토해. 오래 걸리면 나 삐질 거야.",
      "검토 안 해? 어차피 내가 짠 거 완벽할 텐데. 흥."
    ],
    "thanks": [
      "뭐, 뭘 이 정도로... 다, 당연한 걸 한 것뿐이야."
    ]
    // 원하는 상태 이름을 키로 자유롭게 추가/수정
  }
}
```

### 커스텀 포인트

- **대사 바꾸기:** `messages.<상태>` 배열에 문장 추가/수정. 여러 개면 랜덤 출력.
- **호칭 넣기:** 대사 안에 `{name}` 을 쓰면 `nickname` 값으로 치환됩니다.
  예: `nickname: "오빠"` + `"{name}! 빨리 검토해!"` → *"오빠! 빨리 검토해!"*
- **표정 바꾸기:** `emojis.<상태>` 배열에 이모지 추가/수정.
- **크기/속도:** 위 숫자 필드 조절.
- **새 상태 만들기:** `messages`/`emojis`에 새 키를 넣고, 그 상태로 전환하는 hook을 추가하면 됩니다.

> `config.json`은 **UTF-8**로 저장하세요 (BOM은 있어도 없어도 됨).

---

## 🗂️ 폴더 구조

```
ai_emoji/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ install.ps1                    # ~/.claude/mascot 로 설치
├─ settings.hooks.example.json    # settings.json 에 병합할 hooks
├─ mascot.ps1                     # 마스코트 본체 (WPF 창)
├─ set-state.ps1                  # 상태 기록 도우미
├─ config.json                    # 대사·표정·크기 설정 (기본: 츤데레 테마)
├─ hooks/                         # Claude Code hooks 스크립트
│   ├─ _sid.ps1              # 공용: stdin JSON 에서 세션 ID 추출
│   ├─ on-session-start.ps1 # SessionStart → 세션별 마스코트 실행
│   ├─ on-session-end.ps1   # SessionEnd → 세션 마스코트 종료
│   ├─ on-prompt.ps1        # UserPromptSubmit → thinking/thanks/annoyed
│   ├─ on-pretool.ps1       # PreToolUse → committing/pushing/testing/...
│   ├─ on-accept.ps1        # PostToolUse → 권한 표시 해제
│   ├─ on-perm.ps1          # Notification/PermissionRequest → waiting
│   ├─ on-stop.ps1          # Stop → rejected 또는 done
│   └─ on-error.ps1         # PostToolUseFailure → error
└─ images/                        # (비어있음) 여기에 이미지 추가
    └─ README.txt
```

---

## 🛠️ 문제 해결

| 증상 | 해결 |
|------|------|
| 대사에 한글이 깨지거나 스크립트 오류 | `.ps1`을 **UTF-8 (BOM 포함)** 으로 저장. `install.ps1`이 자동 처리 |
| 자동으로 상태가 안 바뀜 | Claude Code **재시작**. `settings.json`의 hooks 경로 확인 |
| 창이 안 뜸 | `mascot.ps1`을 직접 실행해 오류 확인 (위 미리보기 명령) |
| 창이 여러 개 뜸 | 이미 단일 인스턴스 잠금이 있음. 남은 프로세스 종료: `Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" \| ? { $_.CommandLine -like '*-File*mascot.ps1*' } \| Stop-Process -Force` |
| 감정 이모지 스티커가 안 보임 | 사진이 있을 때만 스티커가 뜹니다(이모지 캐릭터일 땐 캐릭터 자체가 표정) |
| GIF가 깨져 보임 | 최적화 GIF는 일부 프레임만 저장됨 → "full frames"로 재출력 |

---

## 📜 저작권 / 디스클레이머

- 이 리포는 **코드·설정·문서만** 포함하며, 캐릭터 이미지·사진·움짤은 포함하지 않습니다.
- 사용자가 추가하는 이미지의 저작권 책임은 사용자 본인에게 있습니다. **개인 PC에서의 사용**을 권장하며, 저작권이 있는 이미지를 재배포하지 마세요.
- 이 프로젝트는 특정 아티스트/작품과 무관한 팬 유틸리티입니다.

## 📄 라이선스

코드는 [MIT License](LICENSE). (이미지는 라이선스 대상이 아니며 포함되지 않음)

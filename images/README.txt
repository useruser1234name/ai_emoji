여기에 캐릭터 이미지(사진/움짤 PNG·JPG·GIF)를 넣으면 마스코트에 나옵니다.
넣는 즉시 반영됩니다 (마스코트 재시작 불필요).

[방법 1] 상태당 여러 표정 랜덤 (권장, 제일 다양함)
  images/<상태>/ 폴더를 만들고 그 안에 사진을 여러 장 넣으세요.
  그 상태가 될 때마다 폴더 안에서 랜덤으로 한 장이 뜹니다.
  예) images/done/     -> 웃는 사진 여러 장 (완료 때마다 다른 표정)
      images/rejected/ -> 서운한 사진 여러 장
      images/error/    -> 놀란 사진 여러 장

[방법 2] 상태별 한 장
  coding.png, done.png, thinking.png, waiting.png, committing.png,
  pushing.png, testing.png, deploy.png, docker.png, install.png,
  lint.png, rejected.png, error.png, thanks.png, annoyed.png, idle.png ...

[방법 3] 한 장으로 통일
  character.png (또는 .gif / .jpg) - 모든 상태에서 이 사진 하나만 사용
  (상태 폴더/파일이 있으면 그게 우선)

우선순위:
  images/<상태>/ 폴더 > <상태>.gif > <상태>.png > <상태>.jpg
    > character.gif > character.png > character.jpg > (이모지)

팁:
- 배경 투명 PNG/GIF면 제일 예쁩니다.
- GIF(움짤)도 재생됩니다. 속도는 config.json 의 fps.
- 가로 크기는 config.json 의 charWidth 기준(기본 150~160px).
- 저작권: 개인 PC 사용 권장. 저작권 있는 이미지는 재배포하지 마세요.

# 발구름 Balgurum 웹사이트

XR 어린이 콘텐츠 브랜드 발구름의 소개 사이트입니다. 빌드 없이 바로 열리는 정적 사이트예요.

## 페이지
- `#about` 발구름 소개
- `#contents` 콘텐츠 (사고뭉치 특공대, 미니게임 8종)
- `#story` 브랜드 스토리

## 로컬에서 보기
`index.html`을 브라우저로 열면 됩니다.

## GitHub Pages로 배포
1. 이 폴더 내용을 GitHub 저장소에 올립니다.
2. 저장소 Settings → Pages → Branch를 `main`, 폴더를 `/ (root)`로 지정합니다.
3. 몇 분 뒤 `https://<아이디>.github.io/<저장소이름>/`에서 열립니다.

## 이미지 교체
`assets/` 폴더의 이미지는 시안에서 잘라낸 임시 이미지입니다. 같은 파일 이름으로 원본 일러스트를 넣으면 그대로 바뀝니다.

## 응원 남기기 페이지 (#cheer)
문의하기 버튼을 누르면 열리는 이스터에그 페이지입니다. GitHub Pages에서는 무료 데이터베이스 서비스인 Supabase에 응원을 저장합니다.

### 응원 저장 (연결 완료)
Supabase 프로젝트 `cmkbfuqavwsgvikfptfm`에 `cheers` 테이블이 만들어져 있고, `index.html`에 주소와 publishable 키가 들어가 있어 GitHub에 올리면 바로 저장됩니다.
- 방문자: 응원 보내기, 공개 응원 읽기만 가능 (수정·삭제·비공개 읽기 불가)
- `supabase-setup.sql`은 적용된 설정의 기록용 사본입니다. 다시 실행할 필요 없어요.
- publishable 키는 웹페이지에 공개돼도 괜찮은 키입니다. secret / service_role 키는 절대 넣지 마세요.

### 응원 확인하기
Supabase 대시보드의 **Table Editor → cheers**에서 모든 응원(비공개 포함)을 볼 수 있습니다. `is_public`이 false인 응원은 제작팀만 보는 응원이에요. 부적절한 응원은 여기서 지우면 됩니다.

### 참고
- 공개 응원 보드는 응원 페이지를 열어둔 동안 30초마다 새로 불러옵니다.
- claude.ai에서 여는 버전은 Supabase 대신 claude.ai 자체 저장소를 그대로 씁니다.

## 채워야 할 곳
- 오프닝 영상: `[영상 링크를 연결할 자리]` 검색

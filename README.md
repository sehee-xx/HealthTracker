![Health_Tracker](https://github.com/sehee-xx/HealthTracker/assets/129670024/198a7ab5-7165-4610-9a75-56925e7ed416)

## Outline

나만의 건강 매니저, **Health Tracker**를 소개합니다.

Health Tracker는 바쁜 일상 속에서 운동과 건강을 기록할 수 있도록 도와줍니다. 

하루하루 쌓이는 기록들을 모아, 발전하는 모습을 확인해보세요!

**개발 환경**

- **Front-end** : Flutter
- **IDE** : Visual Studio Code

## Team

[sehee-xx - Overview](https://github.com/sehee-xx)

[ch02w - Overview](https://github.com/ch02w)

## Intro & Tab Layout

### Splash 화면

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/7f119e57-1780-4a2e-bc75-b5a698c4c506" width="200" height="400"/>

앱을 실행했을 때 3초간 나타나는 `splash` 화면을 구현했습니다.

Splash 화면은 `Lottie`를 사용해서 구현했습니다.

### Drawer

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/30dddd7f-b79b-4c0f-ad19-5dc9bdc3c243" width="200" height="400"/>

Drawer를 구현해 클릭할 때마다 동기 부여가 되는 `랜덤 문구`를 보여주는 기능을 추가했습니다.

Drawer 안에는 Contact, Image, Health, Care `각 탭으로 이동`할 수 있는 버튼을 추가했습니다.

하단에 달리는 사람 애니메이션을 `Lottie`를 사용해 구현했습니다.

## Tab 1: Contacts

### 연락처 리스팅

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/1eb84b1f-e84d-4f95-91f1-e0db3d007ebf" width="200" height="400"/>

같이 운동하는 사람들의 연락처를 저장하고 리스트로 볼 수 있는 화면입니다.

연락처를 `JSON` 형식으로 저장해두고 해당 파일을 불러와서 연락처 리스트를 구현했습니다.

연락처 리스트는 `ListView`를 사용해서 구현했습니다.

### 연락처 추가

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/f0f45737-5247-49f0-a222-c9cfbc8c4ac5" width="200" height="400"/>

우측 하단의 + 버튼을 눌러 이름과 전화번호를 입력해 `연락처를 추가`할 수 있는 기능을 구현했습니다.

`sharedPreference`를 사용해서 추가된 연락처를 기기에 저장해 어플을 재시작 해도 데이터가 유지되도록 만들었습니다.

### 연락처 상세 페이지

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/4e7850b7-2b2d-4d01-aead-e36d477fb45d" width="200" height="400"/>

연락처 상세 페이지에는 이름과 전화번호를 표시하고 전화 걸기 버튼을 추가했습니다.

전화 걸기 버튼을 누르면 `실제 전화 어플로 전환`되고 `번호가 전달`됩니다.

추가로 우측 상단의 버튼을 통해 `연락처 수정`과 `삭제`가 가능하도록 구현했습니다.

### 연락처 수정

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/9f784a06-16af-4dba-8898-9c80a4265507" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/c347b476-3642-406e-91eb-9531e57d1934" width="200" height="400"/>

연락처 상세 페이지에서 수정하기 아이콘을 누르면 `해당 연락처를 불러오고 수정`할 수 있습니다.

수정한 데이터 또한 `sharedPreference`를 사용해 앱을 껐다가 켜도 데이터가 유지되도록 구현했습니다.

### 연락처 삭제

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/ebf31c01-8d5a-497b-8ade-458f57834c72" width="200" height="400"/>

연락처 상세 페이지에서 삭제하기 아이콘을 누르면 `연락처를 삭제`할 수 있습니다.

## Tab 2: Image

### 갤러리

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/b96ef744-31de-4844-a3ac-83b24b2e412c" width="200" height="400"/>

오늘 먹은 식단과, 운동 기록들을 사진으로 정리할 수 있는 탭입니다.

`GridView`를 사용하여 등록된 사진들을 보여주는 갤러리를 구성했습니다.

사진을 탭하면 확대된 사진과 함께 사진에 대한 상세 정보를 확인할 수 있습니다. 

`SharedPreferences`를 사용하여 갤러리에 등록된 사진과 코멘트가 기기 어플 데이터로 저장되어, 어플을 재실행 해도 등록한 사진, 코멘트가 유지되도록 했습니다.

### 사진 추가

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/1a16cce2-3542-43fa-947d-69cccb3d05d4" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/bb34bb5c-9d3f-4ad9-abe7-be02ae66de92" width="200" height="400"/>

우측 하단의 `FloatingActionButton` 을 통해 사진을 추가할 수 있습니다. (카메라 or 갤러리)

사진이 확대된 상태에서 우측 상단의 `휴지통 버튼`을 통해 사진을 삭제할 수 있습니다.

### 코멘트 추가/수정/삭제

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/56fe6eb6-dadf-4ec8-b640-df581a940004" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/83f3f9f7-c00c-4150-99e9-b15b0ac9c101" width="200" height="400"/>

사진 페이지에서는 사용자 본인이 사진에 대해 남긴 코멘트를 확인하거나, 코멘트가 등록되지 않은 사진에 `코멘트를 추가`할 수 있습니다.

코멘트가 추가된 상태에서는 `코멘트를 수정`하거나 삭제할 수 있습니다.

### 사진 필터링

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/7a475eca-38d9-4ef6-ab62-fc016fda0e18" width="200" height="400"/>

갤러리에 필터링 기능을 추가해서 `기간에 대한 필터링`을 사용할 수 있도록 구현했습니다.

우측 상단 필터링 버튼을 누르게 되면, 오늘, 7일, 30일, 전체를 선택할 수 있고, 혹은 원하는 날짜로부터의 사진들을 모아서 확인할 수 있습니다.

## Tab 3: Health

### 운동 기록 탭

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/86c59164-d98f-4fb8-9193-b837315eb314" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/8f657b73-6535-4843-8ef8-2a048abb1b21" width="200" height="400"/>

하루 동안 했던 `운동을 등록`할 수 있는 탭입니다.

아직 운동을 하지 않았다면 `운동 시작하기` 버튼, 

이미 운동을 진행했다면 `운동 추가` 버튼을 통해 운동을 추가할 수 있습니다. 

운동의 종류와 운동 시간을 선택하여 등록하게 되면 추가된 운동이 반영됩니다.

추가된 운동은 `SharedPreferences`를 통해 저장되기 때문에 어플을 재시작해도 상태가 유지됩니다.

### 운동 그래프

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/bac7c5b8-8fcf-4f13-baf2-78fbafc57079" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/09bcf4ae-f207-4d60-8000-0d9cc2d33661" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/ac32ad05-853a-431e-bf05-8bef17399c66" width="200" height="400"/>

운동을 등록하게 되면 `fl_chart`의 `pie chart`에 반영되어 오늘 진행한 운동의 종류와 시간을 쉽게 확인할 수 있습니다.

우측 상단의 버튼을 통해 잘못 등록하거나 삭제가 필요한 `운동을 수정`할 수 있습니다.

### 세부 내용

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/23565c30-76eb-4d1f-b8bb-e70537e24e3e" width="200" height="400"/>

세부 내용 버튼을 누르면 “오늘의 운동” 탭으로 이동하고, `ListView` 형식으로 오늘 했던 운동들을 확인할 수 있습니다.

또한, 각각의 운동 별로 소모된 칼로리 양과, 총 칼로리 소모가 표시됩니다.

### 히스토리

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/5a9574cd-7d67-4973-b721-377df0f54e98" width="200" height="400"/>

히스토리 버튼을 누르면 “운동 히스토리” 탭으로 이동하고, `ListView` 형식으로 지금까지 등록한 운동 시간을 `날짜 별로 확인`할 수 있습니다.

탭 하단에는 최근에 연속으로 운동한 날짜 수와 최근 일주일 간의 총 운동 시간을 확인할 수 있습니다.

## Tab 4: Care

건강 카드, 건강 카드 상세 - 수정, 그래프

### 건강 카드

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/b5595e08-1d61-4201-93b4-2b61797425a9" width="200" height="400"/>

`수면시간, 심박수, 칼로리, 혈당, 걸음수, 체중`을 기록할 수 있는 탭입니다.

`카드 형태`로 구현하였으며, 각 카드를 누르면 해당 데이터의 상세 페이지를 확인할 수 있습니다.

다른 탭에서와 마찬가지로 `sharedPreference`를 사용해 어플을 종료해도 등록/수정한 데이터가 유지됩니다.

### 건강 카드 상세 페이지

<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/a10526f9-78f5-460a-9614-c3d7365d7ecf" width="200" height="400"/>
<img src="https://github.com/sehee-xx/HealthTracker/assets/129670024/5046fd6a-9243-4ecc-9530-f0a37f7d8c88" width="200" height="400"/>

건강 카드의 상세 페이지에서는 `오늘의 데이터를 입력`할 수 있습니다.

또한 카드를 다시 눌러서 `오늘의 데이터를 수정`할 수 있습니다. 

수정된 데이터는 카드와 추이 그래프에 반영됩니다.

### 그래프

하단에는 `그래프`를 넣어서 주간 건강 상태 추이를 확인할 수 있도록 구현했습니다.

그래프는 `LineChart`를 사용해 구현했습니다.

## APK File

[https://drive.google.com/file/d/1z4z7tFtayWx8gGTADpDo-xtz06PVfZ5K/view?usp=sharing](https://drive.google.com/file/d/1ZeSYxwAltRCisvEUnIQ8vi0RcdwNytFX/view?usp=sharing)

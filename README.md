# FDA MAUDE CGM & Insulin Pump Surveillance Platform

<div align="center">

![Platform](https://img.shields.io/badge/Platform-FastAPI%20%2B%20React%2019%20%2B%20SQLite-indigo)
![Data](https://img.shields.io/badge/Database-3.97M%2B%20Reports-emerald)
![License](https://img.shields.io/badge/License-Proprietary-blue)

**FDA MAUDE(Manufacturer and User Facility Device Experience) 빅데이터 기반 연속혈당측정기(CGM) 및 인슐린 펌프 부작용 모니터링 & 분석 통합 플랫폼**

</div>

---

## 🚀 빠른 시작 (Quick Start)

### 실행 방법 (Windows 1-Click)
바탕화면 또는 프로젝트 루트 폴더에서 아래 배치 파일을 더블 클릭하면 백엔드와 프론트엔드가 즉시 구동되고 브라우저가 자동 실행됩니다:

```cmd
run_app.bat
```

* **접속 주소**: `http://localhost:8000`
* **지원 브라우저**: Chrome, Edge, Whale 등 최신 브라우저

---

## 🌟 핵심 기능 및 화면 구성

| 탭 메뉴 | 주요 기능 설명 |
| :--- | :--- |
| **📊 종합 개요 (Overview)** | 총 보고 건수, 사망/상해/오작동/기타 비중 도넛 차트, 상위 10대 제품별 보고 건수 막대 차트 (대표 그룹 vs 원본 명칭, 선형/로그 스케일 지원, 마우스 드래그 크기 조절) |
| **📈 월별 추이 (Trends)** | 월별/분기별/연도별 시계열 추이 분석, 복수 제품 비교, 절대 건수/100% 점유율 막대 그래프, 이동평균(3/6/12개월), 전년 동기 대비(YoY) 증감률 분석 |
| **📑 전체 보고서 (Reports)** | 397만 건 초고속 페이징 조회, FTS5 전문 검색, 3단계 원문 상태 뱃지 (`🟢 원문 O` / `🟡 코드 O` / `⚪ 없음 X`), FDA 공식 웹 원문 바로보기(↗), 원클릭 보관함 저장 |
| **⭐ 관심 보관함 (Bookmarks)** | 중요 MDR 보고서 폴더별 분류, 태그 지정, 사용자 연구 메모 작성, JSON/CSV 백업 내보내기 |
| **🏷️ 문제 코드 분석 (Codes)** | FDA IMDRF 표준 Annex E (환자 증상) 및 Annex A (기기 결함) 발생 빈도 Top 30 랭킹 및 제품별 비중 분석 |
| **🛡️ 안전성 인사이트 (Insights)** | 대표 그룹별 중증 부작용(사망/상해) 발생량 비교, FDA MAUDE 보고 접수 경로(MDR, MedWatch, Foreign 등) 월별/연도별 시계열 분석, 최근 6개월 추세 및 이상 급증 탐지 |

---

## 🛠️ 기술 스택 (Technology Stack)

* **Backend**: Python 3.12, FastAPI, Uvicorn, SQLite3 (FTS5 전문 검색, WAL 모드, 인덱스 최적화)
* **Frontend**: React 19, TypeScript, Tailwind CSS, Vite, Apache ECharts (echarts-for-react), Lucide Icons
* **Data Processing**: OpenFDA Device Event API, IMDRF Standard Annex Codes, Rule-based & AI 3-Stage Summary Generator

---

## 📂 상세 문서 안내

* 📖 **[사용자 상세 매뉴얼 (USER_MANUAL.md)](./USER_MANUAL.md)**: 각 화면별 상세 기능 및 조작법 가이드
* 🏛️ **[시스템 아키텍처 정의서 (ARCHITECTURE.md)](./ARCHITECTURE.md)**: 데이터베이스 설계, API 명세, 프론트엔드 구조
* 📜 **[SW 개발 및 리플랫포밍 이력 (DEVELOPMENT_HISTORY.md)](./DEVELOPMENT_HISTORY.md)**: Streamlit 레거시 한계 극복 및 고성능 플랫폼 구축 이력

---

## ⚡ OpenFDA 실시간 증분 / 전수 동기화 엔진 (Real-time Sync Engine)

OpenFDA Device Event API와 실시간 연동되어 최신 CGM 및 인슐린 펌프 부작용 데이터를 누락 없이 동기화합니다:

* **🚀 `search_after` 커서 페이징**: OpenFDA의 5,000건 / 25,000건 제한을 극복하고, 응답 헤더의 커서 링크를 추적하여 수십만 건의 대량 데이터도 100% 전수 수집
* **💾 스마트 체크포인트 (이어받기)**: 네트워크 불안정이나 API Rate Limit으로 중단되더라도 마지막 수집 지점부터 자동으로 이어서 수집
* **⚡ 초고속 트랜잭션**: SQLite WAL 모드 및 배치 upsert로 수집 즉시 DB 색인 및 월별 시계열 통계 자동 재계산
* **🖥️ 스마트 로그 모니터링**: 프론트엔드 모달에서 실시간 수집 진행률(%) 및 스마트 스크롤 제어 지원

### 실행 방법
1. **대시보드 UI**: 상단 네비게이션의 `[🔄 OpenFDA 데이터 갱신]` 버튼 클릭 ➡️ 기간 지정 후 1-Click 수집
2. **배치 스크립트**:
```cmd
run_collector.bat
```


## Imported Claude Cowork project instructions

현재 폴더에 2개의 pdf 파일이 있음. FDA MAUDE 데이터 베이스에서 2022년과 2024년 CGM 부작용 관련 건수가 적혀 있어.
나는 이 보고서 처럼 FDA에서 제공하는 API를 이용하여 매일 CGM 관련(Dexcom, libre) 부작용 관련 데이터를 수집하고 싶어.
[작업]
1. 매일 아침 9시에 FDA MAUDE 접속(자동)
2. Dexcom, libre 시리즈 CGM 사용으로 인한 부작용 불만접수 검색
3. 불만접수를 EVENT TYPE, BRAND_NAME, 등 관련 데이터베이스 필드 별로 내용을 저장하여 내가 각 필드별로 정렬, 검색을 할 수 있도록했으면 좋겠음
4. 매일 MAUDE 번호와 함께 내용을 요약 (소비자 불만사항, 제조사 대응, 결론)
이걸 Python코드로 만듦

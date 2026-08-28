# libCALCULATION.so 역분석 노트 (AArch64)

## 1) 대상 심볼
`readelf -sW` 기준:

- `Java_com_isens_airsdk_module_Calculation_run7` @ `0x3d574`, size `1464`
- `air1_opcal5_algorithm` @ `0xa8be4`, size `32132`
- 참고: `cgms_algorithm` @ `0x3db2c`

## 2) Java_com_isens_airsdk_module_Calculation_run7 분석
소스는 `reverse/Java_com_isens_airsdk_module_Calculation_run7.asm`.

핵심 동작:

1. JNI 배열 4개를 순회하며 입력 포인터를 획득한다.
   - 루프 인덱스 `w23 = 0..3`
   - `JNIEnv` vtable 오프셋 호출:
     - `#0x568` : `GetObjectArrayElement` 류 호출
     - `#0x558` : 배열 길이 획득 류 호출
     - `#0x5c0` : primitive array element 포인터 획득 류 호출
2. 인덱스 `1` 배열은 레코드 단위 `0x4b(75)` 바이트로 로컬 버퍼(`sp+0x29020`)에 복사.
3. 인덱스 `2` 배열은 레코드 단위 `0x0f(15)` 바이트 구조를 필드 단위로 재배치하여 로컬 상태 버퍼(`sp+0x28d30`)에 적재.
4. 이후 `air1_opcal5_algorithm`을 샘플 단위로 반복 호출:
   - `x0`: index0 입력 포인터
   - `x1`: index1에서 준비한 75-byte 레코드
   - `x2`: 상태 버퍼
   - `x3`: index3 입력 포인터
   - `x4`: 출력 scratch (`sp+0x18a0`)
   - `x5`: 추가 상태 (`sp+0x28`)
5. 반환값(`w0` 하위 8비트)을 결과 레코드 개수로 간주하고, 1개당 `0x9b(155)` 바이트를 출력 버퍼(`sp+0x2130`)에 append.
6. 최종적으로 JNI의 `NewObjectArray`/`SetObjectArrayElement` 류 API를 통해
   - 메인 결과(155-byte 레코드 배열)
   - 보조 버퍼들
   - 원본/중간 상태 버퍼
   를 Java 측으로 되돌린다.

요약 의사코드:

```c
jobjectArray Java_com_isens_airsdk_module_Calculation_run7(JNIEnv* env, jobject thiz, jobjectArray inArr) {
    // 1) inArr[0..3] 획득
    // 2) inArr[1] -> local75[] 복사
    // 3) inArr[2] -> stateBuf[]로 필드 재배치
    // 4) for each sample: n = air1_opcal5_algorithm(...)
    //       if (n>0) append n records (155-byte each) to outBuf
    // 5) jobjectArray result[6] 구성 후 반환
}
```

## 3) air1_opcal5_algorithm 분석
소스는 `reverse/air1_opcal5_algorithm.asm` (약 8k 라인).

### 3.1 함수 시그니처(추정)
호출부( `run7` )와 레지스터 사용으로 추정:

```c
uint8_t air1_opcal5_algorithm(
    void* in0,          // x0
    uint8_t* rec75,     // x1, 75-byte 입력 레코드
    uint8_t* state,     // x2, 대형 상태 버퍼
    void* in3,          // x3
    uint8_t* out155,    // x4, 155-byte 출력 레코드 버퍼(복수개 가능)
    void* auxState      // x5
);
```

### 3.2 초반 검증 및 예외 출력 경로
초기 블록(`0xa8c8c`~`0xa8d68`)에서 다음 검증을 수행:

- `rec75[0x4a] != 0` 이면 에러코드 `0x10`
- 상태 내 특정 카운터/범위 체크 실패 시 에러코드 `0x08`
- 입력 범위 위반 시 에러코드 `0x20`

에러가 발생하면 즉시:

```asm
a8d58: mov x1, x26
a8d5c: mov x2, x22
a8d60: mov x3, x27
a8d64: mov x4, x19
a8d68: bl  0xb0968 <set_exceptional_output>
```

로 점프하여 `set_exceptional_output()`으로 출력을 채운 뒤 복귀.

### 3.3 내부 처리 파이프라인(호출 함수 기준)
`air1_opcal5_algorithm` 내부에서 확인된 주요 하위 알고리즘:

- `eliminate_peak`
- `quick_select`
- `smooth_sg` (Savitzky–Golay 계열로 추정)
- `regress_cal`
- `apply_simple_smooth`
- `check_error`

즉, **피크 제거 → 통계 선택(quick select) → smoothing → 회귀 보정 → 에러 판정** 형태의 파이프라인으로 보임.

### 3.4 메모리 연산 패턴
함수 전반에서 `memset/memmove/memcpy` 호출이 많고, 고정 길이 블록을 반복 이동:

- 75-byte 입력 레코드 window 재배열
- 155-byte 출력 레코드 축적
- 다수의 중간 버퍼를 stack/전역 scratch에 배치

따라서 구조체 기반 고수준 코드가 **최적화 + 인라인 + 벡터화** 된 결과로 보이며,
일반 decompiler에서 지역 변수명/타입이 깨질 확률이 높다.

## 4) “native code로 보고 싶다” 요청에 대한 결과
요청하신 대로 native(AArch64) 코드 자체를 추출해 두었습니다.

- `reverse/Java_com_isens_airsdk_module_Calculation_run7.asm`
- `reverse/air1_opcal5_algorithm.asm`

`air1_opcal5_algorithm`은 크기가 매우 커서(32132 bytes) 상용/GUI decompiler 없이 완전한 C 복원은 제한적이지만,
현재 파일에는 함수 전체 native instruction이 포함되어 있어 블록 단위 수동 역공학이 가능합니다.

## 5) 추가로 정확도를 올리는 방법
1. Ghidra/IDA에서 타입 정의 강제:
   - 75-byte 입력 레코드 구조체
   - 155-byte 출력 레코드 구조체
2. `set_exceptional_output`, `check_error`부터 먼저 타입 복원.
3. `quick_select`, `smooth_sg`, `regress_cal` 하위 함수를 먼저 C 유사코드화 후
   상위 `air1_opcal5_algorithm` 제어 흐름에 재주입.
4. JNI 호출 오프셋을 `jni.h` 함수 테이블과 매칭하여 `run7`의 정확한 Java 타입 복원.


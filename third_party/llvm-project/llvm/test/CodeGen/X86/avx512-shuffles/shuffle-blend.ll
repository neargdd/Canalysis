; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX512F,X86-AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX512F,X64-AVX512F
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=CHECK,AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=CHECK,AVX512BW

define <16 x i32> @shuffle_v8i64(<16 x i32> %t0, <16 x i32> %t1) {
; AVX512F-LABEL: shuffle_v8i64:
; AVX512F:       # %bb.0: # %entry
; AVX512F-NEXT:    vpaddd %zmm1, %zmm0, %zmm2
; AVX512F-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    movb $-86, %al
; AVX512F-NEXT:    kmovw %eax, %k1
; AVX512F-NEXT:    vmovdqa64 %zmm0, %zmm2 {%k1}
; AVX512F-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512F-NEXT:    ret{{[l|q]}}
;
; AVX512BW-LABEL: shuffle_v8i64:
; AVX512BW:       # %bb.0: # %entry
; AVX512BW-NEXT:    vpaddd %zmm1, %zmm0, %zmm2
; AVX512BW-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    movb $-86, %al
; AVX512BW-NEXT:    kmovd %eax, %k1
; AVX512BW-NEXT:    vmovdqa64 %zmm0, %zmm2 {%k1}
; AVX512BW-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512BW-NEXT:    ret{{[l|q]}}
entry:
  %t2 = add nsw <16 x i32> %t0, %t1
  %t3 = sub nsw <16 x i32> %t0, %t1
  %t4 = shufflevector <16 x i32> %t2, <16 x i32> %t3, <16 x i32> <i32 0, i32 1, i32 18, i32 19, i32 4, i32 5, i32 22, i32 23, i32 8, i32 9, i32 26, i32 27, i32 12, i32 13, i32 30, i32 31>
  ret <16 x i32> %t4
}

define <8 x i32> @shuffle_v4i64(<8 x i32> %t0, <8 x i32> %t1) {
; CHECK-LABEL: shuffle_v4i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm2
; CHECK-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vpblendd {{.*#+}} ymm0 = ymm2[0,1],ymm0[2,3],ymm2[4,5],ymm0[6,7]
; CHECK-NEXT:    ret{{[l|q]}}
entry:
  %t2 = add nsw <8 x i32> %t0, %t1
  %t3 = sub nsw <8 x i32> %t0, %t1
  %t4 = shufflevector <8 x i32> %t2, <8 x i32> %t3, <8 x i32> <i32 0, i32 1, i32 10, i32 11, i32 4, i32 5, i32 14, i32 15>
  ret <8 x i32> %t4
}

define <4 x i32> @shuffle_v2i64(<4 x i32> %t0, <4 x i32> %t1) {
; CHECK-LABEL: shuffle_v2i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vpaddd %xmm1, %xmm0, %xmm2
; CHECK-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendd {{.*#+}} xmm0 = xmm2[0,1],xmm0[2,3]
; CHECK-NEXT:    ret{{[l|q]}}
entry:
  %t2 = add nsw <4 x i32> %t0, %t1
  %t3 = sub nsw <4 x i32> %t0, %t1
  %t4 = shufflevector <4 x i32> %t2, <4 x i32> %t3, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  ret <4 x i32> %t4
}

define <2 x i32> @shuffle_v2i32(<2 x i32> %t0, <2 x i32> %t1) {
; CHECK-LABEL: shuffle_v2i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vpaddd %xmm1, %xmm0, %xmm2
; CHECK-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendd {{.*#+}} xmm0 = xmm2[0],xmm0[1],xmm2[2,3]
; CHECK-NEXT:    ret{{[l|q]}}
entry:
  %t2 = add nsw <2 x i32> %t0, %t1
  %t3 = sub nsw <2 x i32> %t0, %t1
  %t4 = shufflevector <2 x i32> %t2, <2 x i32> %t3, <2 x i32> <i32 0, i32 3>
  ret <2 x i32> %t4
}

define <64 x i8> @addb_selectw_64xi8(<64 x i8> %t0, <64 x i8> %t1) {
; X86-AVX512F-LABEL: addb_selectw_64xi8:
; X86-AVX512F:       # %bb.0:
; X86-AVX512F-NEXT:    vextracti64x4 $1, %zmm1, %ymm2
; X86-AVX512F-NEXT:    vextracti64x4 $1, %zmm0, %ymm3
; X86-AVX512F-NEXT:    vpaddb %ymm2, %ymm3, %ymm2
; X86-AVX512F-NEXT:    vpaddb %ymm1, %ymm0, %ymm3
; X86-AVX512F-NEXT:    vinserti64x4 $1, %ymm2, %zmm3, %zmm2
; X86-AVX512F-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; X86-AVX512F-NEXT:    vpternlogq $216, {{\.?LCPI[0-9]+_[0-9]+}}, %zmm2, %zmm0
; X86-AVX512F-NEXT:    retl
;
; X64-AVX512F-LABEL: addb_selectw_64xi8:
; X64-AVX512F:       # %bb.0:
; X64-AVX512F-NEXT:    vextracti64x4 $1, %zmm1, %ymm2
; X64-AVX512F-NEXT:    vextracti64x4 $1, %zmm0, %ymm3
; X64-AVX512F-NEXT:    vpaddb %ymm2, %ymm3, %ymm2
; X64-AVX512F-NEXT:    vpaddb %ymm1, %ymm0, %ymm3
; X64-AVX512F-NEXT:    vinserti64x4 $1, %ymm2, %zmm3, %zmm2
; X64-AVX512F-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; X64-AVX512F-NEXT:    vpternlogq $216, {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %zmm2, %zmm0
; X64-AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: addb_selectw_64xi8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpaddb %zmm1, %zmm0, %zmm2
; AVX512BW-NEXT:    vpsubb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    movl $1, %eax
; AVX512BW-NEXT:    kmovd %eax, %k1
; AVX512BW-NEXT:    vmovdqu16 %zmm0, %zmm2 {%k1}
; AVX512BW-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512BW-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <64 x i8> %t0, %t1
  %t3 = sub nsw <64 x i8> %t0, %t1
  %t4 = shufflevector <64 x i8> %t2, <64 x i8> %t3, <64 x i32> <i32 64, i32 65, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  ret <64 x i8> %t4
}

define <32 x i8> @addb_selectw_32xi8(<32 x i8> %t0, <32 x i8> %t1) {
; CHECK-LABEL: addb_selectw_32xi8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddb %ymm1, %ymm0, %ymm2
; CHECK-NEXT:    vpsubb %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm2[1,2,3,4,5,6,7]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0,1,2,3],ymm2[4,5,6,7]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <32 x i8> %t0, %t1
  %t3 = sub nsw <32 x i8> %t0, %t1
  %t4 = shufflevector <32 x i8> %t2, <32 x i8> %t3, <32 x i32> <i32 32, i32 33, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <32 x i8> %t4
}

define <16 x i8> @addb_selectw_16xi8(<16 x i8> %t0, <16 x i8> %t1) {
; CHECK-LABEL: addb_selectw_16xi8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddb %xmm1, %xmm0, %xmm2
; CHECK-NEXT:    vpsubb %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm2[1,2,3,4,5,6,7]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <16 x i8> %t0, %t1
  %t3 = sub nsw <16 x i8> %t0, %t1
  %t4 = shufflevector <16 x i8> %t2, <16 x i8> %t3, <16 x i32> <i32 16, i32 17, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %t4
}

define <8 x i8> @addb_selectw_8xi8(<8 x i8> %t0, <8 x i8> %t1) {
; CHECK-LABEL: addb_selectw_8xi8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddb %xmm1, %xmm0, %xmm2
; CHECK-NEXT:    vpsubb %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm2[1,2,3,4,5,6,7]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <8 x i8> %t0, %t1
  %t3 = sub nsw <8 x i8> %t0, %t1
  %t4 = shufflevector <8 x i8> %t2, <8 x i8> %t3, <8 x i32> <i32 8, i32 9, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i8> %t4
}

define <32 x i16> @addw_selectd_32xi16(<32 x i16> %t0, <32 x i16> %t1) {
; AVX512F-LABEL: addw_selectd_32xi16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vextracti64x4 $1, %zmm1, %ymm2
; AVX512F-NEXT:    vextracti64x4 $1, %zmm0, %ymm3
; AVX512F-NEXT:    vpaddw %ymm2, %ymm3, %ymm2
; AVX512F-NEXT:    vpaddw %ymm1, %ymm0, %ymm3
; AVX512F-NEXT:    vinserti64x4 $1, %ymm2, %zmm3, %zmm2
; AVX512F-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    movw $1, %ax
; AVX512F-NEXT:    kmovw %eax, %k1
; AVX512F-NEXT:    vmovdqa32 %zmm0, %zmm2 {%k1}
; AVX512F-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512F-NEXT:    ret{{[l|q]}}
;
; AVX512BW-LABEL: addw_selectd_32xi16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpaddw %zmm1, %zmm0, %zmm2
; AVX512BW-NEXT:    vpsubw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    movw $1, %ax
; AVX512BW-NEXT:    kmovd %eax, %k1
; AVX512BW-NEXT:    vmovdqa32 %zmm0, %zmm2 {%k1}
; AVX512BW-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512BW-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <32 x i16> %t0, %t1
  %t3 = sub nsw <32 x i16> %t0, %t1
  %t4 = shufflevector <32 x i16> %t2, <32 x i16> %t3, <32 x i32> <i32 32, i32 33, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <32 x i16> %t4
}

define <16 x i16> @addw_selectd_16xi16(<16 x i16> %t0, <16 x i16> %t1) {
; CHECK-LABEL: addw_selectd_16xi16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddw %ymm1, %ymm0, %ymm2
; CHECK-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0],ymm2[1,2,3,4,5,6,7]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <16 x i16> %t0, %t1
  %t3 = sub nsw <16 x i16> %t0, %t1
  %t4 = shufflevector <16 x i16> %t2, <16 x i16> %t3, <16 x i32> <i32 16, i32 17, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i16> %t4
}

define <16 x i32> @addd_selectq_16xi32(<16 x i32> %t0, <16 x i32> %t1) {
; AVX512F-LABEL: addd_selectq_16xi32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpaddd %zmm1, %zmm0, %zmm2
; AVX512F-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    movb $1, %al
; AVX512F-NEXT:    kmovw %eax, %k1
; AVX512F-NEXT:    vmovdqa64 %zmm0, %zmm2 {%k1}
; AVX512F-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512F-NEXT:    ret{{[l|q]}}
;
; AVX512BW-LABEL: addd_selectq_16xi32:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpaddd %zmm1, %zmm0, %zmm2
; AVX512BW-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    movb $1, %al
; AVX512BW-NEXT:    kmovd %eax, %k1
; AVX512BW-NEXT:    vmovdqa64 %zmm0, %zmm2 {%k1}
; AVX512BW-NEXT:    vmovdqa64 %zmm2, %zmm0
; AVX512BW-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <16 x i32> %t0, %t1
  %t3 = sub nsw <16 x i32> %t0, %t1
  %t4 = shufflevector <16 x i32> %t2, <16 x i32> %t3, <16 x i32> <i32 16, i32 17, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>

  ret <16 x i32> %t4
}

define <8 x i32> @addd_selectq_8xi32(<8 x i32> %t0, <8 x i32> %t1) {
; CHECK-LABEL: addd_selectq_8xi32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm2
; CHECK-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0,1],ymm2[2,3,4,5,6,7]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <8 x i32> %t0, %t1
  %t3 = sub nsw <8 x i32> %t0, %t1
  %t4 = shufflevector <8 x i32> %t2, <8 x i32> %t3, <8 x i32> <i32 8, i32 9, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>

  ret <8 x i32> %t4
}

define <4 x i32> @addd_selectq_4xi32(<4 x i32> %t0, <4 x i32> %t1) {
; CHECK-LABEL: addd_selectq_4xi32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpaddd %xmm1, %xmm0, %xmm2
; CHECK-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3]
; CHECK-NEXT:    ret{{[l|q]}}
  %t2 = add nsw <4 x i32> %t0, %t1
  %t3 = sub nsw <4 x i32> %t0, %t1
  %t4 = shufflevector <4 x i32> %t2, <4 x i32> %t3, <4 x i32> <i32 4, i32 5, i32 2, i32 3>

  ret <4 x i32> %t4
}
; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM
;
; Test cases specifically designed for the "no-capture" argument attribute.
; We use FIXME's to indicate problems and missing attributes.
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
declare i32* @unknown()

; TEST comparison against NULL
;
; int is_null_return(int *p) {
;   return p == 0;
; }
;
; no-capture is missing on %p because it is not dereferenceable
define i32 @is_null_return(i32* %p) #0 {
; CHECK: Function Attrs: nofree noinline norecurse nosync nounwind readnone willreturn uwtable
; CHECK-LABEL: define {{[^@]+}}@is_null_return
; CHECK-SAME: (i32* nofree readnone [[P:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32* [[P]], null
; CHECK-NEXT:    [[CONV:%.*]] = zext i1 [[CMP]] to i32
; CHECK-NEXT:    ret i32 [[CONV]]
;
entry:
  %cmp = icmp eq i32* %p, null
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; TEST comparison against NULL in control flow
;
; int is_null_control(int *p) {
;   if (p == 0)
;     return 1;
;   if (0 == p)
;     return 1;
;   return 0;
; }
;
; no-capture is missing on %p because it is not dereferenceable
define i32 @is_null_control(i32* %p) #0 {
; CHECK: Function Attrs: nofree noinline norecurse nosync nounwind readnone willreturn uwtable
; CHECK-LABEL: define {{[^@]+}}@is_null_control
; CHECK-SAME: (i32* nofree [[P:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[RETVAL:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32* [[P]], null
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    store i32 1, i32* [[RETVAL]], align 4
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32* null, [[P]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[IF_THEN2:%.*]], label [[IF_END3:%.*]]
; CHECK:       if.then2:
; CHECK-NEXT:    store i32 1, i32* [[RETVAL]], align 4
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       if.end3:
; CHECK-NEXT:    store i32 0, i32* [[RETVAL]], align 4
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[RETVAL]], align 4
; CHECK-NEXT:    ret i32 [[TMP0]]
;
entry:
  %retval = alloca i32, align 4
  %cmp = icmp eq i32* %p, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 1, i32* %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %cmp1 = icmp eq i32* null, %p
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  store i32 1, i32* %retval, align 4
  br label %return

if.end3:                                          ; preds = %if.end
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end3, %if.then2, %if.then
  %0 = load i32, i32* %retval, align 4
  ret i32 %0
}

; TEST singleton SCC
;
; double *srec0(double *a) {
;   srec0(a);
;   return 0;
; }
;
define double* @srec0(double* %a) #0 {
; CHECK: Function Attrs: nofree noinline nosync nounwind readnone willreturn uwtable
; CHECK-LABEL: define {{[^@]+}}@srec0
; CHECK-SAME: (double* nocapture nofree readnone [[A:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret double* null
;
entry:
  %call = call double* @srec0(double* %a)
  ret double* null
}

; TEST singleton SCC with lots of nested recursive calls
;
; int* srec16(int* a) {
;   return srec16(srec16(srec16(srec16(
;          srec16(srec16(srec16(srec16(
;          srec16(srec16(srec16(srec16(
;          srec16(srec16(srec16(srec16(
;                        a
;          ))))))))))))))));
; }
;
; Other arguments are possible here due to the no-return behavior.
;
define i32* @srec16(i32* %a) #0 {
; CHECK: Function Attrs: nofree noinline nosync nounwind readnone willreturn uwtable
; CHECK-LABEL: define {{[^@]+}}@srec16
; CHECK-SAME: (i32* nocapture nofree readnone [[A:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32* undef
;
entry:
  %call = call i32* @srec16(i32* %a)
  %call1 = call i32* @srec16(i32* %call)
  %call2 = call i32* @srec16(i32* %call1)
  %call3 = call i32* @srec16(i32* %call2)
  %call4 = call i32* @srec16(i32* %call3)
  %call5 = call i32* @srec16(i32* %call4)
  %call6 = call i32* @srec16(i32* %call5)
  %call7 = call i32* @srec16(i32* %call6)
  %call8 = call i32* @srec16(i32* %call7)
  %call9 = call i32* @srec16(i32* %call8)
  %call10 = call i32* @srec16(i32* %call9)
  %call11 = call i32* @srec16(i32* %call10)
  %call12 = call i32* @srec16(i32* %call11)
  %call13 = call i32* @srec16(i32* %call12)
  %call14 = call i32* @srec16(i32* %call13)
  %call15 = call i32* @srec16(i32* %call14)
  ret i32* %call15
}

; TEST SCC with various calls, casts, and comparisons agains NULL
;
; float *scc_A(int *a) {
;   return (float*)(a ? (int*)scc_A((int*)scc_B((double*)scc_C((short*)a))) : a);
; }
;
; long *scc_B(double *a) {
;   return (long*)(a ? scc_C((short*)scc_B((double*)scc_A((int*)a))) : a);
; }
;
; void *scc_C(short *a) {
;   return scc_A((int*)(scc_A(a) ? scc_B((double*)a) : scc_C(a)));
; }
define float* @scc_A(i32* dereferenceable_or_null(4) %a) {
; IS________OPM: Function Attrs: nofree nosync nounwind readnone
; IS________OPM-LABEL: define {{[^@]+}}@scc_A
; IS________OPM-SAME: (i32* nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR2:[0-9]+]] {
; IS________OPM-NEXT:  entry:
; IS________OPM-NEXT:    [[TOBOOL:%.*]] = icmp ne i32* [[A]], null
; IS________OPM-NEXT:    br i1 [[TOBOOL]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; IS________OPM:       cond.true:
; IS________OPM-NEXT:    [[TMP0:%.*]] = bitcast i32* [[A]] to i16*
; IS________OPM-NEXT:    [[CALL:%.*]] = call dereferenceable_or_null(4) i8* @scc_C(i16* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP0]]) #[[ATTR2]]
; IS________OPM-NEXT:    [[TMP1:%.*]] = bitcast i8* [[CALL]] to double*
; IS________OPM-NEXT:    [[CALL1:%.*]] = call dereferenceable_or_null(4) i64* @scc_B(double* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP1]]) #[[ATTR2]]
; IS________OPM-NEXT:    [[TMP2:%.*]] = bitcast i64* [[CALL1]] to i32*
; IS________OPM-NEXT:    [[CALL2:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP2]]) #[[ATTR2]]
; IS________OPM-NEXT:    [[TMP3:%.*]] = bitcast float* [[CALL2]] to i32*
; IS________OPM-NEXT:    br label [[COND_END:%.*]]
; IS________OPM:       cond.false:
; IS________OPM-NEXT:    br label [[COND_END]]
; IS________OPM:       cond.end:
; IS________OPM-NEXT:    [[COND:%.*]] = phi i32* [ [[TMP3]], [[COND_TRUE]] ], [ [[A]], [[COND_FALSE]] ]
; IS________OPM-NEXT:    [[TMP4:%.*]] = bitcast i32* [[COND]] to float*
; IS________OPM-NEXT:    ret float* [[TMP4]]
;
; IS________NPM: Function Attrs: nofree nosync nounwind readnone
; IS________NPM-LABEL: define {{[^@]+}}@scc_A
; IS________NPM-SAME: (i32* nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR2:[0-9]+]] {
; IS________NPM-NEXT:  entry:
; IS________NPM-NEXT:    [[TOBOOL:%.*]] = icmp ne i32* [[A]], null
; IS________NPM-NEXT:    br i1 [[TOBOOL]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; IS________NPM:       cond.true:
; IS________NPM-NEXT:    [[TMP0:%.*]] = bitcast i32* [[A]] to i16*
; IS________NPM-NEXT:    [[CALL:%.*]] = call dereferenceable_or_null(4) i8* @scc_C(i16* noalias nofree nonnull readnone dereferenceable(4) "no-capture-maybe-returned" [[TMP0]]) #[[ATTR2]]
; IS________NPM-NEXT:    [[TMP1:%.*]] = bitcast i8* [[CALL]] to double*
; IS________NPM-NEXT:    [[CALL1:%.*]] = call dereferenceable_or_null(4) i64* @scc_B(double* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP1]]) #[[ATTR2]]
; IS________NPM-NEXT:    [[TMP2:%.*]] = bitcast i64* [[CALL1]] to i32*
; IS________NPM-NEXT:    [[CALL2:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP2]]) #[[ATTR2]]
; IS________NPM-NEXT:    [[TMP3:%.*]] = bitcast float* [[CALL2]] to i32*
; IS________NPM-NEXT:    br label [[COND_END:%.*]]
; IS________NPM:       cond.false:
; IS________NPM-NEXT:    br label [[COND_END]]
; IS________NPM:       cond.end:
; IS________NPM-NEXT:    [[COND:%.*]] = phi i32* [ [[TMP3]], [[COND_TRUE]] ], [ [[A]], [[COND_FALSE]] ]
; IS________NPM-NEXT:    [[TMP4:%.*]] = bitcast i32* [[COND]] to float*
; IS________NPM-NEXT:    ret float* [[TMP4]]
;
entry:
  %tobool = icmp ne i32* %a, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %0 = bitcast i32* %a to i16*
  %call = call i8* @scc_C(i16* %0)
  %1 = bitcast i8* %call to double*
  %call1 = call i64* @scc_B(double* %1)
  %2 = bitcast i64* %call1 to i32*
  %call2 = call float* @scc_A(i32* %2)
  %3 = bitcast float* %call2 to i32*
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32* [ %3, %cond.true ], [ %a, %cond.false ]
  %4 = bitcast i32* %cond to float*
  ret float* %4
}

; FIXME: the call1 below to scc_B should return dereferenceable_or_null(8) (as the callee does). Something prevented that deduction and needs to be investigated.
define i64* @scc_B(double* dereferenceable_or_null(8) %a) {
; IS________OPM: Function Attrs: nofree nosync nounwind readnone
; IS________OPM-LABEL: define {{[^@]+}}@scc_B
; IS________OPM-SAME: (double* nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR2]] {
; IS________OPM-NEXT:  entry:
; IS________OPM-NEXT:    [[TOBOOL:%.*]] = icmp ne double* [[A]], null
; IS________OPM-NEXT:    br i1 [[TOBOOL]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; IS________OPM:       cond.true:
; IS________OPM-NEXT:    [[TMP0:%.*]] = bitcast double* [[A]] to i32*
; IS________OPM-NEXT:    [[CALL:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP0]]) #[[ATTR2]]
; IS________OPM-NEXT:    [[TMP1:%.*]] = bitcast float* [[CALL]] to double*
; IS________OPM-NEXT:    [[CALL1:%.*]] = call dereferenceable_or_null(4) i64* @scc_B(double* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP1]]) #[[ATTR2]]
; IS________OPM-NEXT:    [[TMP2:%.*]] = bitcast i64* [[CALL1]] to i16*
; IS________OPM-NEXT:    [[CALL2:%.*]] = call dereferenceable_or_null(4) i8* @scc_C(i16* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP2]]) #[[ATTR2]]
; IS________OPM-NEXT:    br label [[COND_END:%.*]]
; IS________OPM:       cond.false:
; IS________OPM-NEXT:    [[TMP3:%.*]] = bitcast double* [[A]] to i8*
; IS________OPM-NEXT:    br label [[COND_END]]
; IS________OPM:       cond.end:
; IS________OPM-NEXT:    [[COND:%.*]] = phi i8* [ [[CALL2]], [[COND_TRUE]] ], [ [[TMP3]], [[COND_FALSE]] ]
; IS________OPM-NEXT:    [[TMP4:%.*]] = bitcast i8* [[COND]] to i64*
; IS________OPM-NEXT:    ret i64* [[TMP4]]
;
; IS________NPM: Function Attrs: nofree nosync nounwind readnone
; IS________NPM-LABEL: define {{[^@]+}}@scc_B
; IS________NPM-SAME: (double* nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR2]] {
; IS________NPM-NEXT:  entry:
; IS________NPM-NEXT:    [[TOBOOL:%.*]] = icmp ne double* [[A]], null
; IS________NPM-NEXT:    br i1 [[TOBOOL]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; IS________NPM:       cond.true:
; IS________NPM-NEXT:    [[TMP0:%.*]] = bitcast double* [[A]] to i32*
; IS________NPM-NEXT:    [[CALL:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree nonnull readnone dereferenceable(8) "no-capture-maybe-returned" [[TMP0]]) #[[ATTR2]]
; IS________NPM-NEXT:    [[TMP1:%.*]] = bitcast float* [[CALL]] to double*
; IS________NPM-NEXT:    [[CALL1:%.*]] = call dereferenceable_or_null(4) i64* @scc_B(double* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP1]]) #[[ATTR2]]
; IS________NPM-NEXT:    [[TMP2:%.*]] = bitcast i64* [[CALL1]] to i16*
; IS________NPM-NEXT:    [[CALL2:%.*]] = call dereferenceable_or_null(4) i8* @scc_C(i16* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP2]]) #[[ATTR2]]
; IS________NPM-NEXT:    br label [[COND_END:%.*]]
; IS________NPM:       cond.false:
; IS________NPM-NEXT:    [[TMP3:%.*]] = bitcast double* [[A]] to i8*
; IS________NPM-NEXT:    br label [[COND_END]]
; IS________NPM:       cond.end:
; IS________NPM-NEXT:    [[COND:%.*]] = phi i8* [ [[CALL2]], [[COND_TRUE]] ], [ [[TMP3]], [[COND_FALSE]] ]
; IS________NPM-NEXT:    [[TMP4:%.*]] = bitcast i8* [[COND]] to i64*
; IS________NPM-NEXT:    ret i64* [[TMP4]]
;
entry:
  %tobool = icmp ne double* %a, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %0 = bitcast double* %a to i32*
  %call = call float* @scc_A(i32* %0)
  %1 = bitcast float* %call to double*
  %call1 = call i64* @scc_B(double* %1)
  %2 = bitcast i64* %call1 to i16*
  %call2 = call i8* @scc_C(i16* %2)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = bitcast double* %a to i8*
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i8* [ %call2, %cond.true ], [ %3, %cond.false ]
  %4 = bitcast i8* %cond to i64*
  ret i64* %4
}

define i8* @scc_C(i16* dereferenceable_or_null(2) %a) {
; CHECK: Function Attrs: nofree nosync nounwind readnone
; CHECK-LABEL: define {{[^@]+}}@scc_C
; CHECK-SAME: (i16* nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR2:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[BC:%.*]] = bitcast i16* [[A]] to i32*
; CHECK-NEXT:    [[CALL:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[BC]]) #[[ATTR2]]
; CHECK-NEXT:    [[BC2:%.*]] = bitcast float* [[CALL]] to i8*
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp ne i8* [[BC2]], null
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[COND_TRUE:%.*]], label [[COND_FALSE:%.*]]
; CHECK:       cond.true:
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i16* [[A]] to double*
; CHECK-NEXT:    [[CALL1:%.*]] = call dereferenceable_or_null(4) i64* @scc_B(double* noalias nofree readnone dereferenceable_or_null(8) "no-capture-maybe-returned" [[TMP0]]) #[[ATTR2]]
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[CALL1]] to i8*
; CHECK-NEXT:    br label [[COND_END:%.*]]
; CHECK:       cond.false:
; CHECK-NEXT:    [[CALL2:%.*]] = call dereferenceable_or_null(4) i8* @scc_C(i16* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[A]]) #[[ATTR2]]
; CHECK-NEXT:    br label [[COND_END]]
; CHECK:       cond.end:
; CHECK-NEXT:    [[COND:%.*]] = phi i8* [ [[TMP1]], [[COND_TRUE]] ], [ [[CALL2]], [[COND_FALSE]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[COND]] to i32*
; CHECK-NEXT:    [[CALL3:%.*]] = call dereferenceable_or_null(4) float* @scc_A(i32* noalias nofree readnone dereferenceable_or_null(4) "no-capture-maybe-returned" [[TMP2]]) #[[ATTR2]]
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float* [[CALL3]] to i8*
; CHECK-NEXT:    ret i8* [[TMP3]]
;
entry:
  %bc = bitcast i16* %a to i32*
  %call = call float* @scc_A(i32* %bc)
  %bc2 = bitcast float* %call to i8*
  %tobool = icmp ne i8* %bc2, null
  br i1 %tobool, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %0 = bitcast i16* %a to double*
  %call1 = call i64* @scc_B(double* %0)
  %1 = bitcast i64* %call1 to i8*
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call2 = call i8* @scc_C(i16* %a)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i8* [ %1, %cond.true ], [ %call2, %cond.false ]
  %2 = bitcast i8* %cond to i32*
  %call3 = call float* @scc_A(i32* %2)
  %3 = bitcast float* %call3 to i8*
  ret i8* %3
}


; TEST call to external function, marked no-capture
;
; void external_no_capture(int /* no-capture */ *p);
; void test_external_no_capture(int *p) {
;   external_no_capture(p);
; }
;
declare void @external_no_capture(i32* nocapture)

define void @test_external_no_capture(i32* %p) #0 {
; CHECK: Function Attrs: noinline nounwind uwtable
; CHECK-LABEL: define {{[^@]+}}@test_external_no_capture
; CHECK-SAME: (i32* nocapture [[P:%.*]]) #[[ATTR3:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @external_no_capture(i32* nocapture [[P]])
; CHECK-NEXT:    ret void
;
entry:
  call void @external_no_capture(i32* %p)
  ret void
}

; TEST call to external var-args function, marked no-capture
;
; void test_var_arg_call(char *p, int a) {
;   printf(p, a);
; }
;
define void @test_var_arg_call(i8* %p, i32 %a) #0 {
; CHECK: Function Attrs: noinline nounwind uwtable
; CHECK-LABEL: define {{[^@]+}}@test_var_arg_call
; CHECK-SAME: (i8* nocapture [[P:%.*]], i32 [[A:%.*]]) #[[ATTR3]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 (i8*, ...) @printf(i8* nocapture [[P]], i32 [[A]])
; CHECK-NEXT:    ret void
;
entry:
  %call = call i32 (i8*, ...) @printf(i8* %p, i32 %a)
  ret void
}

declare i32 @printf(i8* nocapture, ...)


; TEST "captured" only through return
;
; long *not_captured_but_returned_0(long *a) {
;   *a1 = 0;
;   return a;
; }
;
; There should *not* be a no-capture attribute on %a
define i64* @not_captured_but_returned_0(i64* %a) #0 {
; CHECK: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; CHECK-LABEL: define {{[^@]+}}@not_captured_but_returned_0
; CHECK-SAME: (i64* nofree noundef nonnull returned writeonly align 8 dereferenceable(8) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR4:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i64 0, i64* [[A]], align 8
; CHECK-NEXT:    ret i64* [[A]]
;
entry:
  store i64 0, i64* %a, align 8
  ret i64* %a
}

; TEST "captured" only through return
;
; long *not_captured_but_returned_1(long *a) {
;   *(a+1) = 1;
;   return a + 1;
; }
;
; There should *not* be a no-capture attribute on %a
define i64* @not_captured_but_returned_1(i64* %a) #0 {
; CHECK: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; CHECK-LABEL: define {{[^@]+}}@not_captured_but_returned_1
; CHECK-SAME: (i64* nofree nonnull writeonly align 8 dereferenceable(16) "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR4]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 1
; CHECK-NEXT:    store i64 1, i64* [[ADD_PTR]], align 8
; CHECK-NEXT:    ret i64* [[ADD_PTR]]
;
entry:
  %add.ptr = getelementptr inbounds i64, i64* %a, i64 1
  store i64 1, i64* %add.ptr, align 8
  ret i64* %add.ptr
}

; TEST calls to "captured" only through return functions
;
; void test_not_captured_but_returned_calls(long *a) {
;   not_captured_but_returned_0(a);
;   not_captured_but_returned_1(a);
; }
;
define void @test_not_captured_but_returned_calls(i64* %a) #0 {
; IS__TUNIT____: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@test_not_captured_but_returned_calls
; IS__TUNIT____-SAME: (i64* nocapture nofree writeonly align 8 [[A:%.*]]) #[[ATTR4]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i64* @not_captured_but_returned_0(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9:[0-9]+]]
; IS__TUNIT____-NEXT:    [[CALL1:%.*]] = call i64* @not_captured_but_returned_1(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree noinline nosync nounwind willreturn writeonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@test_not_captured_but_returned_calls
; IS__CGSCC____-SAME: (i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A:%.*]]) #[[ATTR5:[0-9]+]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i64* @not_captured_but_returned_0(i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A]]) #[[ATTR10:[0-9]+]]
; IS__CGSCC____-NEXT:    [[CALL1:%.*]] = call i64* @not_captured_but_returned_1(i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A]]) #[[ATTR10]]
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i64* @not_captured_but_returned_0(i64* %a)
  %call1 = call i64* @not_captured_but_returned_1(i64* %a)
  ret void
}

; TEST "captured" only through transitive return
;
; long* negative_test_not_captured_but_returned_call_0a(long *a) {
;   return not_captured_but_returned_0(a);
; }
;
; There should *not* be a no-capture attribute on %a
define i64* @negative_test_not_captured_but_returned_call_0a(i64* %a) #0 {
; IS__TUNIT____: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_0a
; IS__TUNIT____-SAME: (i64* nofree returned writeonly align 8 "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR4]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i64* @not_captured_but_returned_0(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9]]
; IS__TUNIT____-NEXT:    ret i64* [[A]]
;
; IS__CGSCC____: Function Attrs: argmemonly nofree noinline nosync nounwind willreturn writeonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_0a
; IS__CGSCC____-SAME: (i64* nofree noundef nonnull writeonly align 8 dereferenceable(8) [[A:%.*]]) #[[ATTR5]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call noundef nonnull align 8 dereferenceable(8) i64* @not_captured_but_returned_0(i64* nofree noundef nonnull writeonly align 8 dereferenceable(8) [[A]]) #[[ATTR10]]
; IS__CGSCC____-NEXT:    ret i64* [[CALL]]
;
entry:
  %call = call i64* @not_captured_but_returned_0(i64* %a)
  ret i64* %call
}

; TEST captured through write
;
; void negative_test_not_captured_but_returned_call_0b(long *a) {
;   *a = (long)not_captured_but_returned_0(a);
; }
;
; There should *not* be a no-capture attribute on %a
define void @negative_test_not_captured_but_returned_call_0b(i64* %a) #0 {
; IS__TUNIT____: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_0b
; IS__TUNIT____-SAME: (i64* nofree writeonly align 8 [[A:%.*]]) #[[ATTR4]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i64* @not_captured_but_returned_0(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9]]
; IS__TUNIT____-NEXT:    [[TMP0:%.*]] = ptrtoint i64* [[A]] to i64
; IS__TUNIT____-NEXT:    store i64 [[TMP0]], i64* [[A]], align 8
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: argmemonly nofree noinline nosync nounwind willreturn writeonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_0b
; IS__CGSCC____-SAME: (i64* nofree noundef nonnull writeonly align 8 dereferenceable(8) [[A:%.*]]) #[[ATTR5]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i64* @not_captured_but_returned_0(i64* nofree noundef nonnull writeonly align 8 dereferenceable(8) [[A]]) #[[ATTR10]]
; IS__CGSCC____-NEXT:    [[TMP0:%.*]] = ptrtoint i64* [[CALL]] to i64
; IS__CGSCC____-NEXT:    store i64 [[TMP0]], i64* [[A]], align 8
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i64* @not_captured_but_returned_0(i64* %a)
  %0 = ptrtoint i64* %call to i64
  store i64 %0, i64* %a, align 8
  ret void
}

; TEST "captured" only through transitive return
;
; long* negative_test_not_captured_but_returned_call_1a(long *a) {
;   return not_captured_but_returned_1(a);
; }
;
; There should *not* be a no-capture attribute on %a
define i64* @negative_test_not_captured_but_returned_call_1a(i64* %a) #0 {
; IS__TUNIT____: Function Attrs: argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_1a
; IS__TUNIT____-SAME: (i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A:%.*]]) #[[ATTR4]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call noundef nonnull align 8 dereferenceable(8) i64* @not_captured_but_returned_1(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9]]
; IS__TUNIT____-NEXT:    ret i64* [[CALL]]
;
; IS__CGSCC____: Function Attrs: argmemonly nofree noinline nosync nounwind willreturn writeonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_1a
; IS__CGSCC____-SAME: (i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A:%.*]]) #[[ATTR5]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call noundef nonnull align 8 dereferenceable(8) i64* @not_captured_but_returned_1(i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A]]) #[[ATTR10]]
; IS__CGSCC____-NEXT:    ret i64* [[CALL]]
;
entry:
  %call = call i64* @not_captured_but_returned_1(i64* %a)
  ret i64* %call
}

; TEST captured through write
;
; void negative_test_not_captured_but_returned_call_1b(long *a) {
;   *a = (long)not_captured_but_returned_1(a);
; }
;
; There should *not* be a no-capture attribute on %a
define void @negative_test_not_captured_but_returned_call_1b(i64* %a) #0 {
; IS__TUNIT____: Function Attrs: nofree noinline norecurse nosync nounwind willreturn writeonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_1b
; IS__TUNIT____-SAME: (i64* nofree writeonly align 8 [[A:%.*]]) #[[ATTR5:[0-9]+]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call align 8 i64* @not_captured_but_returned_1(i64* nofree writeonly align 8 "no-capture-maybe-returned" [[A]]) #[[ATTR9]]
; IS__TUNIT____-NEXT:    [[TMP0:%.*]] = ptrtoint i64* [[CALL]] to i64
; IS__TUNIT____-NEXT:    store i64 [[TMP0]], i64* [[CALL]], align 8
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree noinline nosync nounwind willreturn writeonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@negative_test_not_captured_but_returned_call_1b
; IS__CGSCC____-SAME: (i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A:%.*]]) #[[ATTR6:[0-9]+]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call align 8 i64* @not_captured_but_returned_1(i64* nofree noundef nonnull writeonly align 8 dereferenceable(16) [[A]]) #[[ATTR10]]
; IS__CGSCC____-NEXT:    [[TMP0:%.*]] = ptrtoint i64* [[CALL]] to i64
; IS__CGSCC____-NEXT:    store i64 [[TMP0]], i64* [[CALL]], align 8
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i64* @not_captured_but_returned_1(i64* %a)
  %0 = ptrtoint i64* %call to i64
  store i64 %0, i64* %call, align 8
  ret void
}

; TEST return argument or unknown call result
;
; int* ret_arg_or_unknown(int* b) {
;   if (b == 0)
;     return b;
;   return unknown();
; }
;
; Verify we do *not* assume b is returned or not captured.
;

define i32* @ret_arg_or_unknown(i32* %b) #0 {
; CHECK: Function Attrs: noinline nounwind uwtable
; CHECK-LABEL: define {{[^@]+}}@ret_arg_or_unknown
; CHECK-SAME: (i32* [[B:%.*]]) #[[ATTR3]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32* [[B]], null
; CHECK-NEXT:    br i1 [[CMP]], label [[RET_ARG:%.*]], label [[RET_UNKNOWN:%.*]]
; CHECK:       ret_arg:
; CHECK-NEXT:    ret i32* [[B]]
; CHECK:       ret_unknown:
; CHECK-NEXT:    [[CALL:%.*]] = call i32* @unknown()
; CHECK-NEXT:    ret i32* [[CALL]]
;
entry:
  %cmp = icmp eq i32* %b, null
  br i1 %cmp, label %ret_arg, label %ret_unknown

ret_arg:
  ret i32* %b

ret_unknown:
  %call = call i32* @unknown()
  ret i32* %call
}

define i32* @ret_arg_or_unknown_through_phi(i32* %b) #0 {
; CHECK: Function Attrs: noinline nounwind uwtable
; CHECK-LABEL: define {{[^@]+}}@ret_arg_or_unknown_through_phi
; CHECK-SAME: (i32* [[B:%.*]]) #[[ATTR3]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32* [[B]], null
; CHECK-NEXT:    br i1 [[CMP]], label [[RET_ARG:%.*]], label [[RET_UNKNOWN:%.*]]
; CHECK:       ret_arg:
; CHECK-NEXT:    br label [[R:%.*]]
; CHECK:       ret_unknown:
; CHECK-NEXT:    [[CALL:%.*]] = call i32* @unknown()
; CHECK-NEXT:    br label [[R]]
; CHECK:       r:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32* [ [[B]], [[RET_ARG]] ], [ [[CALL]], [[RET_UNKNOWN]] ]
; CHECK-NEXT:    ret i32* [[PHI]]
;
entry:
  %cmp = icmp eq i32* %b, null
  br i1 %cmp, label %ret_arg, label %ret_unknown

ret_arg:
  br label %r

ret_unknown:
  %call = call i32* @unknown()
  br label %r

r:
  %phi = phi i32* [ %b, %ret_arg ], [ %call, %ret_unknown ]
  ret i32* %phi
}


; TEST not captured by readonly external function
;
declare i32* @readonly_unknown(i32*, i32*) readonly

define void @not_captured_by_readonly_call(i32* %b) #0 {
; IS__TUNIT____: Function Attrs: noinline nounwind readonly uwtable
; IS__TUNIT____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call
; IS__TUNIT____-SAME: (i32* nocapture readonly [[B:%.*]]) #[[ATTR7:[0-9]+]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown(i32* readonly [[B]], i32* readonly [[B]]) #[[ATTR6:[0-9]+]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: noinline nounwind readonly uwtable
; IS__CGSCC____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call
; IS__CGSCC____-SAME: (i32* nocapture readonly [[B:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown(i32* readonly [[B]], i32* readonly [[B]]) #[[ATTR7:[0-9]+]]
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i32* @readonly_unknown(i32* %b, i32* %b)
  ret void
}


; TEST not captured by readonly external function if return chain is known
;
; Make sure the returned flag on %r is strong enough to justify nocapture on %b but **not** on %r.
;
define i32* @not_captured_by_readonly_call_not_returned_either1(i32* %b, i32* returned %r) {
; IS__TUNIT____: Function Attrs: nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either1
; IS__TUNIT____-SAME: (i32* nocapture readonly [[B:%.*]], i32* readonly returned [[R:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR8]]
; IS__TUNIT____-NEXT:    ret i32* [[CALL]]
;
; IS__CGSCC____: Function Attrs: nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either1
; IS__CGSCC____-SAME: (i32* nocapture readonly [[B:%.*]], i32* readonly returned [[R:%.*]]) #[[ATTR9:[0-9]+]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR9]]
; IS__CGSCC____-NEXT:    ret i32* [[CALL]]
;
entry:
  %call = call i32* @readonly_unknown(i32* %b, i32* %r) nounwind
  ret i32* %call
}

declare i32* @readonly_unknown_r1a(i32*, i32* returned) readonly
define i32* @not_captured_by_readonly_call_not_returned_either2(i32* %b, i32* %r) {
; IS__TUNIT____: Function Attrs: nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either2
; IS__TUNIT____-SAME: (i32* readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR8]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1a(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR8]]
; IS__TUNIT____-NEXT:    ret i32* [[CALL]]
;
; IS__CGSCC____: Function Attrs: nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either2
; IS__CGSCC____-SAME: (i32* readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR9]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1a(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR9]]
; IS__CGSCC____-NEXT:    ret i32* [[CALL]]
;
entry:
  %call = call i32* @readonly_unknown_r1a(i32* %b, i32* %r) nounwind
  ret i32* %call
}

declare i32* @readonly_unknown_r1b(i32*, i32* returned) readonly nounwind
define i32* @not_captured_by_readonly_call_not_returned_either3(i32* %b, i32* %r) {
; IS__TUNIT____: Function Attrs: nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either3
; IS__TUNIT____-SAME: (i32* nocapture readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR8]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1b(i32* nocapture readonly [[B]], i32* readonly [[R]]) #[[ATTR8]]
; IS__TUNIT____-NEXT:    ret i32* [[CALL]]
;
; IS__CGSCC____: Function Attrs: nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either3
; IS__CGSCC____-SAME: (i32* nocapture readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR9]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1b(i32* nocapture readonly [[B]], i32* readonly [[R]]) #[[ATTR9]]
; IS__CGSCC____-NEXT:    ret i32* [[CALL]]
;
entry:
  %call = call i32* @readonly_unknown_r1b(i32* %b, i32* %r)
  ret i32* %call
}

define i32* @not_captured_by_readonly_call_not_returned_either4(i32* %b, i32* %r) nounwind {
; IS__TUNIT____: Function Attrs: nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either4
; IS__TUNIT____-SAME: (i32* readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR8]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1a(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR6]]
; IS__TUNIT____-NEXT:    ret i32* [[CALL]]
;
; IS__CGSCC____: Function Attrs: nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@not_captured_by_readonly_call_not_returned_either4
; IS__CGSCC____-SAME: (i32* readonly [[B:%.*]], i32* readonly [[R:%.*]]) #[[ATTR9]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_unknown_r1a(i32* readonly [[B]], i32* readonly [[R]]) #[[ATTR7]]
; IS__CGSCC____-NEXT:    ret i32* [[CALL]]
;
entry:
  %call = call i32* @readonly_unknown_r1a(i32* %b, i32* %r)
  ret i32* %call
}


declare i32* @unknown_i32p(i32*)
define void @nocapture_is_not_subsumed_1(i32* nocapture %b) {
; CHECK-LABEL: define {{[^@]+}}@nocapture_is_not_subsumed_1
; CHECK-SAME: (i32* nocapture [[B:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = call i32* @unknown_i32p(i32* [[B]])
; CHECK-NEXT:    store i32 0, i32* [[CALL]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %call = call i32* @unknown_i32p(i32* %b)
  store i32 0, i32* %call
  ret void
}

declare i32* @readonly_i32p(i32*) readonly
define void @nocapture_is_not_subsumed_2(i32* nocapture %b) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@nocapture_is_not_subsumed_2
; IS__TUNIT____-SAME: (i32* nocapture [[B:%.*]]) {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32* @readonly_i32p(i32* readonly [[B]]) #[[ATTR6]]
; IS__TUNIT____-NEXT:    store i32 0, i32* [[CALL]], align 4
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@nocapture_is_not_subsumed_2
; IS__CGSCC____-SAME: (i32* nocapture [[B:%.*]]) {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32* @readonly_i32p(i32* readonly [[B]]) #[[ATTR7]]
; IS__CGSCC____-NEXT:    store i32 0, i32* [[CALL]], align 4
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i32* @readonly_i32p(i32* %b)
  store i32 0, i32* %call
  ret void
}

attributes #0 = { noinline nounwind uwtable }
;.
; IS__TUNIT____: attributes #[[ATTR0]] = { nofree noinline norecurse nosync nounwind readnone willreturn uwtable }
; IS__TUNIT____: attributes #[[ATTR1]] = { nofree noinline nosync nounwind readnone willreturn uwtable }
; IS__TUNIT____: attributes #[[ATTR2]] = { nofree nosync nounwind readnone }
; IS__TUNIT____: attributes #[[ATTR3]] = { noinline nounwind uwtable }
; IS__TUNIT____: attributes #[[ATTR4]] = { argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable }
; IS__TUNIT____: attributes #[[ATTR5]] = { nofree noinline norecurse nosync nounwind willreturn writeonly uwtable }
; IS__TUNIT____: attributes #[[ATTR6]] = { readonly }
; IS__TUNIT____: attributes #[[ATTR7]] = { noinline nounwind readonly uwtable }
; IS__TUNIT____: attributes #[[ATTR8]] = { nounwind readonly }
; IS__TUNIT____: attributes #[[ATTR9]] = { nofree nosync nounwind willreturn writeonly }
;.
; IS__CGSCC____: attributes #[[ATTR0]] = { nofree noinline norecurse nosync nounwind readnone willreturn uwtable }
; IS__CGSCC____: attributes #[[ATTR1]] = { nofree noinline nosync nounwind readnone willreturn uwtable }
; IS__CGSCC____: attributes #[[ATTR2]] = { nofree nosync nounwind readnone }
; IS__CGSCC____: attributes #[[ATTR3]] = { noinline nounwind uwtable }
; IS__CGSCC____: attributes #[[ATTR4]] = { argmemonly nofree noinline norecurse nosync nounwind willreturn writeonly uwtable }
; IS__CGSCC____: attributes #[[ATTR5]] = { argmemonly nofree noinline nosync nounwind willreturn writeonly uwtable }
; IS__CGSCC____: attributes #[[ATTR6]] = { nofree noinline nosync nounwind willreturn writeonly uwtable }
; IS__CGSCC____: attributes #[[ATTR7]] = { readonly }
; IS__CGSCC____: attributes #[[ATTR8]] = { noinline nounwind readonly uwtable }
; IS__CGSCC____: attributes #[[ATTR9]] = { nounwind readonly }
; IS__CGSCC____: attributes #[[ATTR10]] = { nounwind willreturn writeonly }
;.
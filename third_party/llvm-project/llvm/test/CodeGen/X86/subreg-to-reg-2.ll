; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin | FileCheck %s
; rdar://6707985

	%XXOO = type { %"struct.XXC::XXCC", ptr, %"struct.XXC::XXOO::$_71" }
	%XXValue = type opaque
	%"struct.XXC::ArrayStorage" = type { i32, i32, i32, ptr, ptr, [1 x ptr] }
	%"struct.XXC::XXArray" = type { %XXOO, i32, ptr }
	%"struct.XXC::XXCC" = type { ptr, ptr }
	%"struct.XXC::XXOO::$_71" = type { [2 x ptr] }

define internal fastcc ptr @t(ptr %out, ptr %tmp9) nounwind {
; CHECK-LABEL: t:
; CHECK:       ## %bb.0: ## %prologue
; CHECK-NEXT:    movq 22222222, %rax
; CHECK-NEXT:    movq %rax, (%rdi)
; CHECK-NEXT:    movl %eax, %eax
; CHECK-NEXT:    movq 32(%rsi,%rax,8), %rax
; CHECK-NEXT:    retq
prologue:
	%array = load ptr, ptr inttoptr (i64 11111111 to ptr)		; <ptr> [#uses=0]
	%index = load ptr, ptr inttoptr (i64 22222222 to ptr)		; <ptr> [#uses=1]
	%tmp = ptrtoint ptr %index to i64		; <i64> [#uses=2]
	store i64 %tmp, ptr %out
	%tmp6 = trunc i64 %tmp to i32		; <i32> [#uses=1]
	br label %bb5

bb5:		; preds = %prologue
	%tmp10 = zext i32 %tmp6 to i64		; <i64> [#uses=1]
	%tmp11 = getelementptr %"struct.XXC::ArrayStorage", ptr %tmp9, i64 0, i32 5, i64 %tmp10		; <ptr> [#uses=1]
	%tmp12 = load ptr, ptr %tmp11, align 8		; <ptr> [#uses=1]
	ret ptr %tmp12
}
;函数声明
declare noalias i8* @malloc(i64 noundef) #1
declare i32 @printf(i8* noundef, ...) #2

;添加一行属性，防止链接错误
attributes #0 = { noinline nounwind optnone sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

;@.str开头的是定义的字符串常量，用于printf的输出。constant表示常量，align 字段描述了程序的对齐属性
;全局变量可以用unnamed_addr标记，表示地址不重要，只有内容。如果常量们有相同的初始化值，则它们可以合并
@.str = private unnamed_addr constant [52 x i8] c"after f3: af[0] = %.2f, af[1] = %.2f, af[2] = %.2f\0A\00", align 1

;这里注意，我们定义的静态全局常量n直接在代码中被替换为了相应的值3（与预处理阶段处理宏定义比较相似）

define dso_local float @f3(float* noundef %0, float noundef %1) #0 {
2:
;分配内存空间，float地址型变量分配8（64位地址），float数值分配4
  %3 = alloca float*, align 8
  %4 = alloca float, align 4
;%5是for循环的控制变量i
  %5 = alloca i32, align 4
  store float* %0, float** %3, align 8
  store float %1, float* %4, align 4
;i置0
  store i32 0, i32* %5, align 4
;循环开始
  br label %6

6:                                                ; preds = %21, %2
;这里类似mips里边循环开始的三条指令，首先是获取i值
  %7 = load i32, i32* %5, align 4
;然后让i值与循环终止条件（i < 3）判断
  %8 = icmp slt i32 %7, 3
;最后进行条件分支，满足则去9，不满足去24，i1是一位int
  br i1 %8, label %9, label %24
;循环主体
9:                                                ; preds = %6
;10~14均为取数，综合起来为从一个数组中取一个指定的内容
  %10 = load float*, float** %3, align 8
;load i
  %11 = load i32, i32* %5, align 4
;因为是64位地址（刚才分配的8字节），所以需要对11进行符号拓展到64位
  %12 = sext i32 %11 to i64
;从索引中取内容，熟悉的地址+偏移量，该指令执行完毕后取到的值存在13中
  %13 = getelementptr inbounds float, float* %10, i64 %12
  %14 = load float, float* %13, align 4
  %15 = load float, float* %4, align 4
;浮点加（a[i] = a[i] + b）
  %16 = fadd float %14, %15
;与上文相同的取数操作
  %17 = load float*, float** %3, align 8
  %18 = load i32, i32* %5, align 4
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds float, float* %17, i64 %19
;将上文加操作的结果存入20所在地址中，即写回
  store float %16, float* %20, align 4
  br label %21

21:                                               ; preds = %9
;这一段就是i++
  %22 = load i32, i32* %5, align 4
  %23 = add nsw i32 %22, 1
  store i32 %23, i32* %5, align 4
;回6，继续循环
  br label %6

24:                                               ; preds = %6
;循环结束，执行后续操作（a[0] = a[0] * b）
  %25 = load float*, float** %3, align 8
  %26 = getelementptr inbounds float, float* %25, i64 0
  %27 = load float, float* %26, align 4
  %28 = load float, float* %4, align 4
;浮点乘，下文操作类似，不再赘述
  %29 = fmul float %27, %28
  %30 = load float*, float** %3, align 8
  %31 = getelementptr inbounds float, float* %30, i64 0
  store float %29, float* %31, align 4
  %32 = load float*, float** %3, align 8
  %33 = getelementptr inbounds float, float* %32, i64 0
  %34 = load float, float* %33, align 4
;返回一个值
  ret float %34
}

define dso_local i32 @main() #0 {
  %1 = alloca float*, align 8
  %2 = alloca float, align 4
  ;malloc
  %3 = call noalias i8* @malloc(i64 noundef 12) #3
  ;强制类型转换，对应(float*)
  %4 = bitcast i8* %3 to float*
  ;与上文一致的数组取元素，存入字面值常量
  store float* %4, float** %1, align 8
  %5 = load float*, float** %1, align 8
  %6 = getelementptr inbounds float, float* %5, i64 0
  store float 2.000000e+00, float* %6, align 4
  %7 = load float*, float** %1, align 8
  %8 = getelementptr inbounds float, float* %7, i64 1
  store float -4.000000e+00, float* %8, align 4
  %9 = load float*, float** %1, align 8
  %10 = getelementptr inbounds float, float* %9, i64 2
  store float 0.000000e+00, float* %10, align 4
  store float 2.500000e+00, float* %2, align 4
  ;取出要传入函数的两个值
  %11 = load float*, float** %1, align 8
  %12 = load float, float* %2, align 4
  ;函数调用
  %13 = call float @f3(float* noundef %11, float noundef %12)
  ;为浮点数进行符号扩展，以便于传入printf中
  %14 = fpext float %13 to double;%14 = a[0](64bit, double)
  %15 = load float*, float** %1, align 8
  %16 = getelementptr inbounds float, float* %15, i64 1;
  %17 = load float, float* %16, align 4
  %18 = fpext float %17 to double;%16 = a[1](64bit, double)
  %19 = load float*, float** %1, align 8
  %20 = getelementptr inbounds float, float* %19, i64 2
  %21 = load float, float* %20, align 4
  %22 = fpext float %21 to double;%22 = a[2](64bit, double)
  ;调用printf进行最终的输出
  %23 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([52 x i8], [52 x i8]* @.str, i64 0, i64 0), double noundef %14, double noundef %18, double noundef %22)
  ret i32 0
}

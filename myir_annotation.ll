;@.str开头的是定义的字符串常量，用于printf的输出。constant表示常量，align 字段描述了程序的对齐属性
;全局变量可以用unnamed_addr标记，表示地址不重要，只有内容。如果常量们有相同的初始化值，则它们可以合并
@.str = private unnamed_addr constant [8 x i8] c"a == b\0A\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"a != b\0A\00", align 1
@.str.2 = private unnamed_addr constant [10 x i8] c"a>0,b<0 \0A\00", align 1
@.str.3 = private unnamed_addr constant [3 x i8] c"%d\00", align 1
;全局变量c，i32就是32位int，dso_local是变量和函数的的运行时的抢占说明符
@c = common dso_local global i32 0, align 4

;f1函数，作用是根据%0和%1中两个量值是否相等来输出不同内容
define dso_local void @f1(i32 %0, i32 %1) #0 {
  ;为变量a，b申请空间
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  ;为变量a，b存入值
  store i32 %0, i32* %3, align 4
  store i32 %1, i32* %4, align 4
  ;取出a，b到%5和%6中
  %5 = load i32, i32* %3, align 4
  %6 = load i32, i32* %4, align 4
  ;ab相等，将%7置为1
  %7 = icmp eq i32 %5, %6
  ;根据%7跳转
  br i1 %7, label %8, label %10

8:                                                ; preds = %2
  %9 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str, i64 0, i64 0))
  br label %12

10:                                               ; preds = %2
  %11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0))
  br label %12

12:                                               ; preds = %10, %8
  %13 = phi i32 [ %9, %8 ], [ %11, %10 ]
  ret void
}

;printf函数声明
declare dso_local i32 @printf(i8*, ...) #1

;f2函数，作用是根据%0和%1两个int量值的正负和大小输出不同内容
define dso_local void @f2(i32 %0, i32 %1) #0 {
  ;为变量a，b申请空间，并存入值
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  store i32 %1, i32* %4, align 4
  ;取出a，b
  %5 = load i32, i32* %3, align 4
  %6 = load i32, i32* %4, align 4
  ;%7存储a*b的结果，并将值存入c
  %7 = mul nsw i32 %5, %6
  store i32 %7, i32* @c, align 4
  ;取出c
  %8 = load i32, i32* @c, align 4
  ;判断c是否小于0
  %9 = icmp slt i32 %8, 0
  ;这里只根据c是否小于0跳转（逻辑短路）
  br i1 %9, label %10, label %16

10:                                               ; preds = %2
  ;c<0时，取出a，b
  %11 = load i32, i32* %3, align 4
  %12 = load i32, i32* %4, align 4
  ;比较a是否大于b
  %13 = icmp sgt i32 %11, %12
  ;跳转
  br i1 %13, label %14, label %16

14:                                               ; preds = %10
  ;print语句
  %15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.2, i64 0, i64 0))
  br label %16

16:                                               ; preds = %14, %10, %2
  ret void
}

;主函数
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  ;为变量a，b申请空间
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  ;将0存入%1
  store i32 0, i32* %1, align 4
  ;读取输入值并存入a，b
  %4 = call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.3, i64 0, i64 0), i32* %2)
  %5 = call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.3, i64 0, i64 0), i32* %3)
  ;获取a，b的值，用于函数调用
  %6 = load i32, i32* %2, align 4
  %7 = load i32, i32* %3, align 4
  ;调用f1
  call void @f1(i32 %6, i32 %7)
  ;获取a，b的值，用于函数调用
  %8 = load i32, i32* %2, align 4
  %9 = load i32, i32* %3, align 4
  ;调用f2
  call void @f2(i32 %8, i32 %9)
  ret i32 0
}

;scanf函数声明
declare dso_local i32 @__isoc99_scanf(i8*, ...) #1

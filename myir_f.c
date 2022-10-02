#include<stdio.h>
#include<stdlib.h>
const static int n = 3;

float f3(float* a,float b){  // 一维浮点数组a内所有值加b，再返回a[0]*b
	for(int i = 0; i < n; i++){
		a[i] += b;
	}
	a[0] *= b;
	return a[0];
}

int main(){
	float* af = (float*)malloc(n * sizeof(float));
	af[0] = 2, af[1] = -4, af[2] = 0;
	float bf = 2.5;
	printf("after f3: af[0] = %.2f, af[1] = %.2f, af[2] = %.2f\n", f3(af, bf), af[1], af[2]);
	return 0;
}

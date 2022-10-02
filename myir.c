#include<stdio.h>
int c;

void f1(int a, int b){
	a == b ? printf("a == b\n") : printf("a != b\n");
	return;
}

void f2(int a,int b){
	c =a*b;
	if(c<0 && a>b){
		printf("a>0,b<0 \n");
	}
	return;
}

int main(){
	int a, b;
	scanf("%d", &a);
	scanf("%d", &b);
	f1(a, b);
	f2(a, b);
	return 0;
}

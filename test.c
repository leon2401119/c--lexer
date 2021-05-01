/* this is a comment */
/* this is a 
multiline comment

*/


int foo(int num){
	int i,total=0;
	for(i=1;i<+num;i++)
		total+=i;
	return total;
}

int main(){
	foo(10);
	return 0;
}

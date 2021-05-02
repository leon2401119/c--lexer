#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include<math.h>
#include"header.h"

#define TABLE_SIZE	256

symtab * hash_table[TABLE_SIZE];
extern int linenumber;

int HASH(char * str){
	int idx=0;
	while(*str){
		idx = idx << 1;
		idx+=*str;
		str++;
	}	
	return (idx & (TABLE_SIZE-1));
}

/*returns the symbol table entry if found else NULL*/

symtab * lookup(char *name){
	int hash_key;
	symtab* symptr;
	if(!name)
		return NULL;
	hash_key=HASH(name);
	symptr=hash_table[hash_key];

	while(symptr){
		if(!(strcmp(name,symptr->lexeme)))
			return symptr;
		symptr=symptr->front;
	}
	return NULL;
}


void insertID(char *name){
	int hash_key;
	symtab* ptr;
	symtab* symptr=(symtab*)malloc(sizeof(symtab));	
	
	hash_key=HASH(name);
	ptr=hash_table[hash_key];
	
	if(ptr==NULL){
		/*first entry for this hash_key*/
		hash_table[hash_key]=symptr;
		symptr->front=NULL;
		symptr->back=symptr;
	}
	else{
		symptr->front=ptr;
		ptr->back=symptr;
		symptr->back=symptr;
		hash_table[hash_key]=symptr;	
	}
	
	strcpy(symptr->lexeme,name);
	symptr->line=linenumber;
	symptr->counter=1;
}

void printSym(symtab* ptr) 
{
	    //printf(" Name = %s \n", ptr->lexeme);
	    //printf(" References = %d \n", ptr->counter);
	    //printf(" First Seen At Line %d\n", ptr->line);

	printf("%-10s%d\n",ptr->lexeme,ptr->counter);

}

void printSymTab()
{
    int i;
    //printf("------- Symbol Table ---------\n");
    printf("\nFrequency of identifiers:\n");
    symtab* all = NULL;
    symtab* tmp;
    for (i=0; i<TABLE_SIZE; i++)
    {
        symtab* symptr;
	symptr = hash_table[i];
	while (symptr != NULL)
	{
	    tmp = (symtab*)malloc(sizeof(symtab));
	    strcpy(tmp->lexeme,symptr->lexeme);
	    tmp->counter = symptr->counter;
	    if(!all){
	    	all = tmp;
		all->front = NULL;
		all->back = all;
	    }
	    else{
		symtab* cur = all;
		if(strcmp(cur->lexeme,tmp->lexeme)>0){
			tmp->front = all;
			all->back = tmp;
			tmp->back = tmp;
			all = tmp;
		}
		else{
			while(cur->front&&strcmp(cur->front->lexeme,tmp->lexeme)<0)
				cur = cur->front;
	    		tmp->back = cur;
			tmp->front = cur->front;
			if(cur->front)
				cur->front->back = tmp;
			cur->front = tmp;
		}
	    }
	    symptr=symptr->front;
	}
    }
    symtab* last;
    while(all){
	last = all;
	printSym(all);
	all = all->front;
	free(last);
    }
}

void freeSymTab(){
	int i;
	symtab *cur,*tmp;
	for(i=0;i<TABLE_SIZE;i++){
		cur = hash_table[i];
		while(cur){
			tmp = cur;
			cur = cur->front;
			free(tmp);
		}
	}
}

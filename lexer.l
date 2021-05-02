%option noyywrap 
%{
#include <stdio.h>
#include <stdbool.h>
#include "header.h" 
int linenumber=0;
bool verbose = false;
symtab * lookup();
symtab * ptr;
void     insertID();
void 	 printSymTab();
void	 freeSymTab();
/* You need to define for all tokens in C--, here are some examples */
enum token{
	CONST_INT,
	CONST_FLOAT,
	CONST_STRING,
	IDENTIFIER,
	OP_ADD,
	OP_SUB,
	OP_MUL,
	OP_DIV,
	OP_SMALLER,
	OP_LARGER,
	OP_SMALLEREQ,
	OP_LARGEREQ,
	OP_NOTEQ,
	OP_EQ,
	OP_OR,
	OP_AND,
	OP_NOT,
	OP_BITWISE_OR,
	OP_BITWISE_AND,
	OP_BITWISE_NOT,
	OP_ASSIGN,
	LPAREN,
	RPAREN,
	LBRACE,
	RBRACE,
	LBRACKET,
	RBRACKET,
	SEMICOL,
	COMA,
	DOT,
	ARROW,
	RSV_RETURN,
	RSV_TYPEDEF,
	RSV_IF,
	RSV_ELSE,
	RSV_FOR,
	RSV_WHILE,
	RSV_INT,
	RSV_FLOAT,
	RSV_VOID,
	ERROR = 100
};
%}

letter [a-zA-Z]
digit [0-9]
sep [ \t]


%%
("_"|{letter})+({letter}|{digit}|"_")*	{
	if(!strcmp(yytext,"return")){
		//return RSV_RETURN;
	}
	else if(!strcmp(yytext,"typedef")){
		//return RSV_TYPEDEF;
	}
	else if(!strcmp(yytext,"int")){
		//return RSV_INT;
	}
	else if(!strcmp(yytext,"float")){
		//return RSV_FLOAT:
	}
        else if(!strcmp(yytext,"void")){
                //return RSV_VOID:
        }
        else if(!strcmp(yytext,"if")){
                //return RSV_IF:
        }
        else if(!strcmp(yytext,"else")){
                //return RSV_ELSE:
        }
        else if(!strcmp(yytext,"for")){
                //return RSV_FOR:
        }
        else if(!strcmp(yytext,"while")){
                //return RSV_WHILE:
        }
	else{
		if(verbose)
			printf("got an id %s\n",yytext);
		symtab* entry = lookup(yytext);
		if(!entry)
			insertID(yytext);
		else
			entry->counter++;
		//return IDENTIFIER;
	}
}
"-"?{digit}+"f"?			{
	if(yytext[yyleng-1]!='f'){
		if(verbose)
			printf("got an int constant %s\n",yytext);
		//return CONST_INT;
	}
	else{
		if(verbose)
			printf("got a float constant %s\n",yytext);
		//return CONST_FLOAT;
	}
}
"-"?({digit}+"."{digit}*|"."{digit}+)"f"?       {
        if(verbose)
		printf("got a float constant %s\n",yytext);
        //return CONST_FLOAT;
}
"\""[^"]+"\""				{
	if(verbose)
		printf("got a string constant %s\n",yytext);
	//return CONST_STRING;
}
"/*"([^*]|(\*)+[^*/])*(\*)+"/"		{ 
	// regex like "/*"(.|\n)*"*/" is incorrect 
	// because if we have anything (e.g. functions) 
	// in between two comments they will be treated
	// as (.|\n)* and will be sent here all at once
	
	int linenumber_old = linenumber;
	printf("%s\n",yytext);
	while(*yytext){
		linenumber+=(*yytext=='\n')?1:0;
		yytext++;
	}
	if(verbose){
		if(linenumber_old!=linenumber){
			printf("multi-line comment detected from line %d to %d\n",linenumber_old,linenumber);
		}
		else
			printf("single-line comment detected on line %d\n",linenumber);
	}
}
\n					linenumber++;
"{"					;//return LBRACE;
"}"					;//return RBRACE;
"("					;//return LPAREN;
")"					;//return RPAREN;
"["					;//return LBRACKET;
"]"					;//return RBRACKET;
";"					;//return SEMICOL;
","					;//return COMA;
"."					;//return DOT;
"->"					;//return ARROW;
"="					;//return OP_ASSIGN;
"+"					;//return OP_ADD;
"-"					;//return OP_SUB;
"*"					;//return OP_MUL;
"/"					;//return OP_DIV;
"<"					;//return OP_SMALLER;
">"					;//return OP_LARGER;
"<="					;//return OP_SMALLEREQ;
">="					;//return OP_LARGEREQ;
"!="					;//return OP_NOTEQ;
"=="					;//return OP_EQ;
"||"					;//return OP_OR;
"&&"					;//return OP_AND;
"!"					;//return OP_NOT;
"|"					;//return OP_BITWISE_OR;
"&"					;//return OP_BITWISE_AND;
"~"					;//return OP_BITWISE_NOT;
{sep}					;
.					{
	printf("Unexpected token %s at line %d\n",yytext,linenumber);
	return ERROR;
}

%%
int main()
{
	yylex();
	printSymTab();
	freeSymTab();
	if(verbose)
		printf("total lines = %d\n",linenumber);
}

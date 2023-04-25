%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int lineNumber = 1;
char printstatement[100000];

#define KEYWORD 2
#define OPERATOR 3
#define NUMBER 4
#define IDENTIFIER 5
#define PUNCTUATOR 6
#define STRING 7
#define COMMENT 8
#define MULTICOMMENTSTART 9
#define MULTICOMMENTEND 10
#define HEADERS 11


%}
multicommentstart "\/\*"
multicommentend "\*\/"
headers "\#.*"
integer [0-9]+
float {integer}"."{integer}
exponent {float}+"e"{integer}
number {integer}|{float}|{exponent}

arithmeticOperator "\+"|"-"|"\*"|"\/"|"%"|"\+\+"|"--"
assignmentOperator "="
comparisionOperator "=="|"!="|">"|"<"|">="|"<="
logicalOperator "&&"|"\|\|"|"!"
operator {arithmeticOperator}|{assignmentOperator}|{comparisionOperator}|{logicalOperator}

keyword "int"|"float"|"char"|"printf"|"scanf"|"for"|"if"|"else"|"case"|"switch"|"while"|"void"
identifier [_a-zA-Z][_a-zA-Z0-9]*

punctuator ";"|"\("|"\)"|"\{"|"\}"|"\["|"\]"|"\."|","


string \"([^\\\"]|\\.)*\"


space [ ]
tab [	]
line [\n]

%%

\/\/.* return COMMENT;
{multicommentstart} return MULTICOMMENTSTART;
{multicommentend} return MULTICOMMENTEND;
{space}* {;}
{tab}* {;}
{line} {lineNumber++;}
\#.* return HEADERS;
{keyword} return KEYWORD;
{operator} return OPERATOR;
{number} return NUMBER;
{identifier} return IDENTIFIER;
{punctuator} return PUNCTUATOR;
{string} return STRING;


%%

//Cprogram

void checkCorrectPrintf(){
    int startquote = 7;
    int len;
    for(int i=8; i < strlen(printstatement); i++){
        if(printstatement[i]=='"'){
            len = i-startquote-1;
        }
    }
    int pos = 8;
    char inpstring[1000];
    memset(inpstring,'\0',1000*sizeof(char));
    strncpy(inpstring,printstatement+(pos-1),len);
    int percentcount = 0;
    for(int i=0; i < strlen(inpstring); i++){
        if(inpstring[i]=='%') percentcount++;
    }
    int commacount = 0;
    for(int i=len+startquote+2; i < strlen(printstatement); i++){
        if(inpstring[i]==',') commacount++;
    }
    if(commacount != percentcount){
        printf("\n\nInvalid printf Statement\n\n");
        // exit(1);
    }
}

int main(int argc, char* argv[]){
    int lexemeId = 0, singleCommentLine=0, multiComment=0, MultiCommentLine=0,pf = 0;
    if(argc != 2){
        printf("Usage ./a.out fileName.c");
        return -1;
    }

    char* fileName = argv[1];
    yyin = fopen(fileName, "r");
    lexemeId = yylex();
    while(lexemeId){
        if(lineNumber == singleCommentLine){
            lexemeId = yylex();
            continue;
        }
        // if(lineNumber!=dqline && dqline!=0)
		// {
		// 	if(dq%2!=0)
		// 		printf("\n******** ERROR!! INCOMPLETE STRING at Line %d ********\n\n", dqline);
		// 	dq=0;
		// }
        if(lexemeId==2 && multiComment==0){
            if(!strcmp(yytext, "printf")){
                memset(printstatement, '\0', 100000*sizeof(char));
                strcat(printstatement,yytext);
                printf("%s\t\t\tKEYWORD\t\t\t\t\tLine %d\n", yytext, lineNumber);
                lexemeId = yylex();
                // printf("\n\n %s endyytext", yytext);
                if(!yytext == '('){
                    printf("error in printf (");
                }
                strcat(printstatement,yytext);
                printf("%s\t\t\tPUNCTUATOR\t\t\t\tLine %d\n", yytext, lineNumber);
                pf = 1;

                lexemeId = yylex();
                continue;
            }
            else{
                printf("%s\t\t\tKEYWORD\t\t\t\t\tLine %d\n", yytext, lineNumber);

            }
        }
        if(lexemeId==3 && multiComment==0){
            printf("%s\t\t\tOPERATOR\t\t\t\tLine %d\n", yytext, lineNumber);
            if(pf){
                strcat(printstatement,yytext);
            }
        }
        if(lexemeId==4 && multiComment==0){
            printf("%s\t\t\tNUMBER\t\t\t\t\tLine %d\n", yytext, lineNumber);
            if(pf){
                strcat(printstatement,yytext);
            }
        }
        if(lexemeId==5 && multiComment==0){
            printf("%s\t\t\tIDENTIFIER\t\t\t\tLine %d\n", yytext, lineNumber);
            if(pf){
                strcat(printstatement,yytext);
            }
        }
        if(lexemeId==6 && multiComment==0){
            printf("%s\t\t\tPUNCTUATOR\t\t\t\tLine %d\n", yytext, lineNumber);
            if(pf){
                if(*yytext == ';'){
                    pf = 0;
                    checkCorrectPrintf();
                }
                else{
                    strcat(printstatement,yytext);
                }
                
            }
        }
        if(lexemeId==7 && multiComment==0){
            printf("%s\t\tSTRING\t\t\t\t\tLine %d\n", yytext, lineNumber);
            if(pf){
                strcat(printstatement,yytext);
            }
        }
        if(lexemeId==8){
            printf("%s\t\t\tSingleline Comment\t\t\tLine %d\n", yytext, lineNumber);
            singleCommentLine = lineNumber;
        }
        if(lexemeId==9){
            printf("%s\t\t\tMultiLine Comment Start\t\t\tLine %d\n", yytext, lineNumber);
            MultiCommentLine = lineNumber;
            multiComment = 1;
        }
        if(lexemeId==10 && multiComment==0){
            printf("\nMultiComment Error !!!!!\n");
            MultiCommentLine = lineNumber;
            multiComment = 1;
        }
        if(lexemeId==10 && multiComment==1){
            printf("%s\t\t\tMultiLine Comment End\t\t\tLine %d\n", yytext, lineNumber);
            multiComment = 0;
        }
        if(lexemeId==11 && multiComment==0){
            printf("%s\t\t\t\t\tHeader\t\t\t\t\tLine %d\n", yytext, lineNumber);
        }

        lexemeId = yylex();
    } 
    if(multiComment==1){
        printf("MultiComment erroe!!!!");
    }

    // return 0;
}

int yywrap(){
    return 1;
}

%{
void yyerror (char *s);

#include <stdio.h>
#include <stdlib.h>

int symbols[52];
int symbolVal(char symbol);
void updateSymbolVal(char symbol, int val);
%}

%union {int num; char id;} //share same memory area
%start line
%token print
%token exit_command
%token <num> number
%token <id> identifier
%type <num> line exp term
%type <id> assignment

%%

/* descriptions of expected inputs    correspondig actions (in C) */

line    : assignment ';'        {;}         /* a = 5;   does nothing */
        | exit_command ';'      {exit(EXIT_SUCCESS);}
        | print exp ';'         {printf("Printing %d\n", $2);} /* print a; */
        | line assignment ';'   {;}
        | line print exp ';'    {printf("Printing %d\n", $3);}
        | line exit_command ';' {exit(EXIT_SUCCESS);}
        ;

assignment : identifier '=' exp { updateSymbolVal($1, $3); }
           ;

exp     : term                  {$$ = $1;}
        | exp '+' term          {$$ = $1 + $3;}
        | exp '-' term          {$$ = $1 - $3;}
        ;

term    : number                {$$ = $1;}
        | identifier            { $$ = symbolVal($1); }
        ;

%% 

/* C code */

/* returns the index of the symbol */
int computeSymbolIndex(char token)
{
  int idx = -1;
  if(islower(token)) {
    idx = token - 'a' + 26; /* lower case will go from 26 to 51, token = a    0 - 0 + 26 = 26 */
  } else if(isupper(token)) {
    idx = token - 'A'; /* upper case will go from 0 to 25, token = B     27 - 26 = 1 */
  }
  return idx;
}

/* return the value of a given symbol */
int symbolVal(char symbol)
{
  int bucket = computeSymbolIndex(symbol);
  return symbols[bucket];
}

/* udpates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
  int bucket = computeSymbolIndex(symbol);
  symbols[bucket] = val;
}

int main (void) {
  /* init sumbol table */
  int i;
  for(i=0; i<52; i++) {
    symbols[i] = 0;
  }

  return yyparse();
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}



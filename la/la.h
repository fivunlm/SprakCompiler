//
// Created by FernandoDamian on 4/12/2015.
//

#ifndef SPRAKCOMPILER_LA_H
#define SPRAKCOMPILER_LA_H

#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>


/* -------------------------------------------------------------------------- */
/*                           DEFINCION CONSTANTES                             */
/* -------------------------------------------------------------------------- */
#define FINAL_STATE 15
#define MAXLONG 30
#define TAMMAX 100
#define TAMTOKEN 1000
#define CANTPR 19

#define USHRT_MAX   65535
#define FLOAT_MAX     3.40282347e+38F
#define FLOAT_PREC    16

//DEFINES TEMPORALES

#define PR_MAIN 0
#define PR_VAR 1
#define PR_AS 2
#define PR_ENDVAR 3
#define PR_IF 4
#define PR_THEN 5
#define PR_ELSE 6
#define PR_FI 7
#define PR_FOR 8
#define PR_TO 9
#define PR_STEP 10
#define PR_ROF 11
#define PR_DO 12
#define PR_WHILE 13
#define PR_WPRINT 14
#define PR_FILTERC 15
#define PR_INTEGER 16
#define PR_FLOAT 17
#define PR_STRING 18

#define ID 20
#define CTE_ENT 21
#define CTE_REAL 22
#define CTE_STRING 23
#define OP_PABRE 24
#define OP_PCIERRA 25
#define OP_OR 26
#define OP_AND 27
#define OP_NOT 28
#define OP_MENOR 29
#define OP_MENORIGUAL 30
#define OP_MAYOR 31
#define OP_MAYORIGUAL 32
#define OP_IGUAL 33
#define OP_DISTINTO 34
#define OP_SUMA 35
#define OP_RESTA 36
#define OP_MULTIPLI 37
#define OP_DIVISION 38
#define OP_CABRE 39
#define OP_CCIERRA 40
#define OP_ASIG 41
#define OP_LLABRE 42
#define OP_LLCIERRA 43
#define OP_CONCAT 44
#define SEP_DECIMAL 45
#define SEP_SENT 46
#define OP_TIPO 47
#define SEP_LISTA 48
#define OP_GUION 49

/* -------------------------------------------------------------------------- */
/*                           DECLARACION PROTOTIPOS                           */
/* -------------------------------------------------------------------------- */

// FUNCIONES GENERALES
void readCharacter();
void saveToken();
int  getColumnNumber( char );
void cleanToken();

char * buscarEnTOS(int);
int insertInTOS();
void showTOS();

int getReserverWordNumber();
void addReservedWords();
void makeValidations();


// FUNCIONES LÉXICO
void Init_ID();
void Add_ID();
void Inf_ID();

void Init_Constant();
void Init_Constant_Float();

void Agregar_Constant();
void Inf_Constant();

void Init_Comment();
void Inf_Comment();
void Add_Comment();
void Finish_Comment();

void Init_StringConstant();
void Add_StringConstant();
void Inf_StringConstant();

void Inf_Assignment();

void Inf_Less();

void Inf_LessEqual();

void Inf_Great();

void Inf_GreatEqual();

void Init_Different();
void Inf_Different();

void Init_Equal();
void Inf_Equal();

void Init_Or();
void Inf_Or();

void Init_And();
void Inf_And();

void Inf_Addition();

void Inf_Minus();

void Inf_Multiply();

void Inf_Division();

void Inf_OpenParentesis();

void Inf_ClosingParentesis();

void Inf_OpenBrace();

void Inf_ClosingBrace();

void Inf_Not();

void None();

void CharacterNotValid();

void Init_Concatenation();

void Inf_Concatenation();

void Inf_Separator();

void Inf_Type();

void Inf_ListSeparator();

void Inf_Undesrcore();

int yylex();

void analizeToFile(char *fileToAnalize);

#endif //SPRAKCOMPILER_LA_H

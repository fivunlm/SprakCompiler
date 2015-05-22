%{

#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "pila.h"

#define FINAL_STATE     19
#define MAXLONG         30
#define TAMMAX          100
#define TAMTOKEN        1000
#define CANTPR          19

#define USHRT_MAX       65535
#define FLOAT_MAX       3.40282347e+38F
#define FLOAT_PREC      16

%}

%token PR_MAIN
%token PR_ENDMAIN
%token PR_WHILE
%token PR_ENDWHILE
%token PR_IF
%token PR_ELSE
%token PR_ENDIF
%token PR_FLOAT
%token PR_INT
%token PR_STR
%token PR_CONST
%token PR_PUT
%token PR_GET
%token PR_AND
%token PR_OR
%token PR_DECLARE
%token PR_ENDDECLARE
%token PR_QEQUAL
%token PR_NOT

%token ID
%token CTE_ENT
%token CTE_REAL
%token CTE_STRING
%token OP_PABRE
%token OP_PCIERRA
%token OP_MENOR
%token OP_MENORIGUAL
%token OP_MAYOR
%token OP_MAYORIGUAL
%token OP_IGUAL
%token OP_DISTINTO
%token OP_SUMA
%token OP_RESTA
%token OP_MULTIPLI
%token OP_DIVISION
%token OP_CABRE
%token OP_CCIERRA
%token OP_ASIG
%token OP_LLABRE
%token OP_LLCIERRA
%token OP_CONCAT
%token SEP_DECIMAL
%token SEP_SENT
%token OP_TIPO
%token SEP_LISTA
%token OP_INT
%token SEP_COMMA


%%

PROGRAMA : PR_MAIN DECLARACIONES LISTA_SENTENCIAS PR_ENDMAIN;

DECLARACIONES : PR_DECLARE OP_PABRE LISTA_DECLARACIONES OP_PCIERRA PR_ENDDECLARE;
LISTA_DECLARACIONES : LISTA_DECLARACIONES SEP_COMMA DECLARACION | DECLARACION;
DECLARACION :  ID SEP_LISTA TIPO  ;
TIPO : PR_INT | PR_FLOAT | PR_STR;

LISTA_SENTENCIAS : LISTA_SENTENCIAS SENTENCIA | SENTENCIA;
SENTENCIA : ASIGNACION | IF | WHILE | PUT | GET | QEQUAL | UNARYIF;

ASIGNACION : ID OP_ASIG EXPRESION 
    { 
        insertInPolish(polishPosition++, TOS[$2].nombre);
        insertInPolish( polishPosition++,":=");
    } | ID OP_ASIG CONCATENACION;

EXPRESION : EXPRESION OP_SUMA TERMINO { insertInPolish( polishPosition++,"+"); }
    | EXPRESION OP_RESTA TERMINO { insertInPolish( polishPosition++,"-"); } | TERMINO;
TERMINO : TERMINO OP_MULTIPLI FACTOR | TERMINO OP_DIVISION FACTOR | FACTOR;
FACTOR : ID { insertInPolish(polishPosition++, TOS[$1].nombre); }
    | CTE_ENT { insertInPolish(polishPosition++, TOS[$1].nombre); } 
    | CTE_REAL { insertInPolish(polishPosition++, TOS[$1].nombre); } 
    | OP_PABRE EXPRESION OP_PCIERRA;

CONCATENACION : CTE_STRING OP_CONCAT CTE_STRING | CTE_STRING OP_CONCAT ID | ID OP_CONCAT CTE_STRING | ID OP_CONCAT ID;

IF: PR_IF OP_PABRE CONDICIONES { insertInPolish( polishPosition++, "CMP");
                                 push(&polishStack, polishPosition);
                                 polishPosition++;
                                insertInPolish(polishPosition++, branch_op); } 
    OP_PCIERRA LISTA_SENTENCIAS ENDIF;

ENDIF : PR_ELSE {
        char aux[50];
        sprintf(aux, "%d", polishPosition+2);
        insertInPolish(pop(&polishStack), aux);
        push(&polishStack, polishPosition);
        stack_print(&polishStack);
        polishPosition++;
        insertInPolish(polishPosition++, "BI");
    } LISTA_SENTENCIAS PR_ENDIF {
        char aux[50];
        sprintf(aux, "%d", polishPosition);
        insertInPolish(pop(&polishStack), aux);
        stack_print(&polishStack);
    } | PR_ENDIF {
        char aux[50];
        sprintf(aux, "%d", polishPosition);
        insertInPolish(pop(&polishStack), aux);
        stack_print(&polishStack);
    } ;

CONDICIONES : CONDICION PR_AND CONDICION | CONDICION PR_OR CONDICION | PR_NOT CONDICION | CONDICION;
CONDICION:  COND_LI COMP COND_LD |
            OP_PABRE CONDICION OP_PCIERRA;

COND_LI: EXPRESION;
COND_LD: EXPRESION;
COMP: OP_MAYOR { strcpy(branch_op, "BLE"); } 
    | OP_MAYORIGUAL { strcpy(branch_op, "BLT"); }
    | OP_MENOR { strcpy(branch_op, "BGE"); }
    | OP_MENORIGUAL { strcpy(branch_op, "BGT"); }
    | OP_IGUAL { strcpy(branch_op, "BNE"); } 
    | OP_DISTINTO { strcpy(branch_op, "BEQ"); };

WHILE : PR_WHILE OP_PABRE CONDICIONES OP_PCIERRA LISTA_SENTENCIAS PR_ENDWHILE;

PUT : PR_PUT OUT 
    { 
        insertInPolish(polishPosition++, TOS[$2].nombre);
        insertInPolish(polishPosition++, "PUT");
    };
OUT : ID | CTE_ENT | CTE_REAL | CTE_STRING;
GET : PR_GET ID
    { 
        insertInPolish(polishPosition++, TOS[$2].nombre);
        insertInPolish(polishPosition++, "GET");
    }; 

QEQUAL : PR_QEQUAL OP_PABRE EXPRESION SEP_LISTA LISTA_EXPRESIONES OP_PCIERRA;
LISTA_EXPRESIONES : LISTA_EXPRESIONES SEP_COMMA EXPRESION | EXPRESION; 

UNARYIF : ID OP_ASIG CONDICIONES OP_INT VALOR SEP_LISTA VALOR;
VALOR : UNARYIF | EXPRESION | CTE_STRING;


%%

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

void Init_LessEqual();
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

void Init_MayorIgual();
void Inf_Int();

int yylex();
int yyparse();

void analizeToFile(char *fileToAnalize);

FILE * inputFile;          // Archivo de entrada.

// Ficheros Temporales
FILE * tokenFile;         // Archivo de Tokens
FILE * tosFile;           // Archivo de TOS ( Table Of Symbols )

char readedChar;           // Caracter leido.
int tokenNumber = -1;        // Valor que devuelve el yylex.
int tokenSize = 0;         // Se utiliza para validar los tama?os de los ID y ConstantSTR.
char token[1000];         // Almacena el token armado.
int openStringConstant;        // Para validar que las ctes string esten bien formadas. Por ahora no la estamos usando.
int openComment;           // Para validar que los comentarios son cerrados.
int error = 0;            // para identificar si hubo o no error.
int nroLinea = 1;         // Para identificar en que l?nea se produjo el error.
int ptoInicio = 0;        // Para completar el nro segun corresponda EJ:.36 => 0.36
int symbolTableIndex = 0;           // ?ndice de la TOS
int columnCount = 1;
int rowCount = 1;

int polishPosition = 0;
char branch_op[5];
char polishTokens[10000][60];
Stack polishStack;
int cont_exp = 0;

void insertInPolish( int pos, char * data )
{
    strcpy(polishTokens[pos], data);
}
void insertIntInPolish( int pos, int data )
{
    char aux[100];
    sprintf(aux, "%d",data);
    strcpy(polishTokens[pos], aux);
}


void mostrar_polaca()
{
    for( int i =0 ; i<=polishPosition ; i++)
    {
        printf("%d: %s, ", i, polishTokens[i]);
    }
}

//Variable global provisoria

/* IDENTIFICADORES ---------------------------------------------------------- */
void Init_ID()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    //Posible ID
    tokenNumber = ID;
}

void Add_ID()
{
    if ( strlen( token ) < MAXLONG )
    {
        token[++tokenSize] = readedChar;
    }
    else
    {
        printf( "\n ERROR: La cantidad Maxima de caracteres para un IDENTIFICADOR es de 30. \n" );
        printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
        exit( 1 );
    }
}

void Inf_ID()
{
    if ( error == 0 )
    {
        switch ( getReserverWordNumber() )
        {
            case 0:
                tokenNumber = ID;
                yylval = insertInTOS(); //TOS
                break;
            case 1:
                tokenNumber = PR_MAIN;
                yylval = 1;
                break;

            case 2:
                tokenNumber = PR_ENDMAIN;
                yylval = 2;
                break;
            case 3:
                tokenNumber = PR_WHILE;
                yylval = 3;
                break;
            case 4:
                tokenNumber = PR_ENDWHILE;
                yylval = 4;
                break;
            case 5:
                tokenNumber = PR_IF;
                yylval = 5;
                break;
            case 6:
                tokenNumber = PR_ELSE;
                yylval = 6;
                break;
            case 7:
                tokenNumber = PR_ENDIF;
                yylval = 7;
                break;
            case 8:
                tokenNumber = PR_FLOAT;
                yylval = 9;
                break;
            case 9:
                tokenNumber = PR_INT;
                yylval = 9;
                break;
            case 10:
                tokenNumber = PR_STR;
                yylval = 10;
                break;
            case 11:
                tokenNumber = PR_CONST;
                yylval = 11;
                break;
            case 12:
                tokenNumber = PR_PUT;
                yylval = 12;
                break;
            case 13:
                tokenNumber = PR_GET;
                yylval = 13;
                break;
            case 14:
                tokenNumber = PR_AND;
                yylval = 14;
                break;
            case 15:
                tokenNumber = PR_OR;
                yylval = 15;
                break;
            case 16:
                tokenNumber = PR_DECLARE;
                yylval = 16;
                break;
            case 17:
                tokenNumber = PR_ENDDECLARE;
                yylval = 17;
                break;
            case 18:
                tokenNumber = PR_QEQUAL;
                yylval = 18;
                break;
            case 19:
                tokenNumber = PR_NOT;
                yylval = 19;
                break;

        }
        ungetc(( int ) readedChar, inputFile );
    }
    else
    {
        tokenNumber = 0;
    }
}

/* CONSTANTE NUMERICAS ------------------------------------------------------ */
void Init_Constant()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;        //guardamos el primer readedChar del ID en la cadena auxiliar
    tokenSize++;
    //Posible CTE
    tokenNumber = CTE_ENT;
}

void Init_Constant_Float()
{
    if ( tokenNumber != CTE_ENT )
    {
        cleanToken();
        tokenSize = 0;
    }

    token[tokenSize] = readedChar;        //guardamos el primer readedChar del ID en la cadena auxiliar
    tokenSize++;
    //Posible CTE
    tokenNumber = CTE_REAL;
}

void Agregar_Constant()
{
    token[tokenSize] = readedChar;
    tokenSize++;
}

void Inf_Constant()
{
    if ( tokenNumber == CTE_ENT )
    {
        int cte = atoi( token );
        if (( strlen( token ) > 5 ) || ( cte > USHRT_MAX ))
        {
            printf( "\n ERROR: # Se excede el rango para un ENTERO. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }
    }

    if ( tokenNumber == CTE_REAL )
    {
        if ( strcmp( token, "." ) == 0 )
        {
            printf( "\n - ERROR: Constante REAL incompleta, se esperana un digito \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }

        int i = 0, decimales = -1;

        for ( i = 0; i < strlen( token ); i++ )
        {
            if ( token[i] == '.' || decimales > -1 )
                decimales++;
        }

        if ( decimales > FLOAT_PREC )
        {
            printf( "\n ERROR: # Se excede el rango de presicion para un REAL. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }

        double cte = atof( token );

        if ( cte > FLOAT_MAX )
        {
            printf( "\n ERROR: # Se excede el rango para un REAL. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }

    }

    yylval = insertInTOS(); // TOS
    ungetc(( int ) readedChar, inputFile );
}

void Inf_Comma()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = SEP_COMMA;
}

/* CONSTANTE STRING --------------------------------------------------------- */
void Init_StringConstant()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    openStringConstant++;
    //Posible CTE_STRING
    tokenNumber = CTE_STRING;
}

void Add_StringConstant()
{
    if ( strlen( token ) < MAXLONG )
    {
        token[++tokenSize] = readedChar;
    }
    else
    {
        printf( "\n ERROR: La cantidad Maxima de caracteres para una Constante STRING es de 30. \n" );
        printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
        exit( 1 );
    }
}

void Inf_StringConstant()
{
    token[++tokenSize] = readedChar;
    if ( error == 0 )
    {
        tokenNumber = CTE_STRING;
        yylval = insertInTOS(); //TOS
        openStringConstant--;
    }
    else
    {
        tokenNumber = 0;
        openStringConstant = 0;
    }
}

/* COMENTARIOS -------------------------------------------------------------- */
void Init_Comment()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_RESTA;
}

void Inf_Comment()
{
    cleanToken();
    openComment++;
    None();
    tokenNumber = -1;
}

void Add_Comment()
{
    cleanToken();
    None();
}

void Finish_Comment()
{
    openComment--;
    None();
}

/* SEPARADOR ---------------------------------------------------------------- */
void Inf_Separator()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = SEP_SENT;
}

/* NADA --------------------------------------------------------------------- */
void None()
{
    cleanToken();
    tokenSize = 0;
}

/* CARACTER NO VALIDO ------------------------------------------------------- */
void CharacterNotValid()
{
    if ( strcmp( token, "." ) == 0 )
        printf( "\n - ERROR: Se esperaba un digito \n" );

    if( readedChar != '/' )
        printf( "\n - ERROR: Se esperaba una / para iniciar comentario ");

    printf( "\n - Analisis Lexico INTERRUMPIDO - Carater NO VALIDO (Linea: %d, Columna: %d)\n", rowCount, columnCount );
    exit( 0 );
}

/* ASIGNACION --------------------------------------------------------------- */
void Init_Assignment()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_ASIG;
}

void Inf_Assignment()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_ASIG;
    //ungetc(( int ) readedChar, inputFile ); //Segun Automata
}

/* SUMA --------------------------------------------------------------------- */
void Inf_Addition()
{
    tokenNumber = OP_SUMA;
    ungetc(( int ) readedChar, inputFile ); //Segun Automata
}

/* RESTA -------------------------------------------------------------------- */
void Inf_Minus()
{
    tokenNumber = OP_RESTA;
    ungetc(( int ) readedChar, inputFile ); //Segun Automata
}

/* PRODUCTO ----------------------------------------------------------------- */
void Inf_Multiply()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MULTIPLI;
}

/* DIVISION ----------------------------------------------------------------- */
void Inf_Division()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_DIVISION;
}

/* CONCATENA ---------------------------------------------------------------- */
void Init_Concatenation()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    //Posible SUMA
    tokenNumber = OP_SUMA;
}

void Inf_Concatenation()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_CONCAT;

    //ungetc((int)readedChar, inputFile);
}

/* IGUAL -------------------------------------------------------------------- */
void Init_Equal()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    //Posible ASIG
    tokenNumber = OP_IGUAL;
}

void Inf_Equal()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_IGUAL;
}

/* DISTINTO ----------------------------------------------------------------- */
void Init_Different()
{

    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    //Posible MENOR
    tokenNumber = OP_MENOR; // TODO: Check this
}

void Inf_Different()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_DISTINTO;
}

/* MENOR -------------------------------------------------------------------- */
void Inf_Less()
{
    tokenNumber = OP_MENOR;
    ungetc(( int ) readedChar, inputFile );  //Segun Automata
}

/* MAYOR -------------------------------------------------------------------- */
void Inf_GreatEqual()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MAYORIGUAL;
}

/* MAYORoIGUAL -------------------------------------------------------------- */
void Init_MayorIgual()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MAYOR;
}

void Inf_Great()
{
    tokenNumber = OP_MAYOR;
    ungetc(( int ) readedChar, inputFile ); //segun automata
}

/* MENORoIGUAL -------------------------------------------------------------- */
void Init_LessEqual()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MENOR;
}

void Inf_LessEqual()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MENORIGUAL;
}

/* PARENTESIS --------------------------------------------------------------- */
void Inf_OpenParentesis()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_PABRE;
}

void Inf_ClosingParentesis()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_PCIERRA;
}

/* LLAVE -------------------------------------------------------------------- */
void Inf_OpLLAbre()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_LLABRE;
}

void Inf_OpLLCierra()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_LLCIERRA;
}

/* CORCHETES ---------------------------------------------------------------- */
void Inf_OpenBrace()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_CABRE;
}

void Inf_ClosingBrace()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_CCIERRA;
}

/* OPERADOR DECLARACION DE TIPO DE VARIABLE --------------------------------- */
void Inf_Type()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_TIPO;
}

/* SEPARADOR DE UNA LISTA DE VARIALBLES O TIPOS ----------------------------- */
void Inf_ListSeparator()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = SEP_LISTA;
}

/* GUION ----------------------------- */
void Inf_Int()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_INT;
}
/* -------------------------------------------------------------------------- */
/*                           ESTRUCTURAS ESPECIALES                           */
/* -------------------------------------------------------------------------- */

// TABLA SIMBOLOS
struct tablaDeSimbolo
{
    char nombre[100];
    char tipo[11];
    char valor[100];
    char ren[31];
    int longitud;
};

struct tablaDeSimbolo TOS[TAMMAX];

//MATRIZ PUNTERO A FUNCION
void (* proceso[20][20])() =
        {
                { Init_ID, Init_Constant, Init_Concatenation, Init_Comment, Inf_Multiply, Inf_Division, Inf_OpenParentesis, Inf_ClosingParentesis, Init_Constant_Float, Init_Equal, Inf_Separator, Init_StringConstant, Init_MayorIgual, Init_LessEqual, Init_Assignment, None, Inf_Int, Inf_ListSeparator, Inf_OpenBrace, Inf_ClosingBrace},
                { Add_ID, Add_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID, Inf_ID},
                { Inf_Constant, Agregar_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Init_Constant_Float, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant},
                { Inf_Addition, Inf_Addition, Inf_Concatenation, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition},
                { Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_GreatEqual, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great},
                { Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_LessEqual, Inf_Less, Inf_Less, Inf_Different, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less},
                { Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Inf_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant},
                { Inf_Constant, Agregar_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant, Inf_Constant},
                { Inf_Minus, Inf_Minus, Inf_Minus, None, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus},
                { CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, Inf_Comment, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid, CharacterNotValid},
                { None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, Finish_Comment, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, None, None, Inf_Comment, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { None, None, None, Finish_Comment, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None},
                { Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_Assignment, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator, Inf_ListSeparator},
                {None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None},

        };

//MATRIZ ESTADOS
static int nEstado[20][20] =
        {
                {1,2,3,8,19,19,19,19,7,19,19,6,4,5,18,0,19,19,19,19},
                {1,1,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {19,2,19,19,19,19,19,19,7,19,19,19,19,19,19,19,19,19,19,19},
                {19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {6,6,6,6,6,6,6,6,6,6,6,19,6,6,6,6,6,6,6,6},
                {19,7,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {19,19,19,9,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {-1,-1,-1,-1,-1,10,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                {10,10,10,13,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10},
                {10,10,10,12,10,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10},
                {-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                {10,10,10,14,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10},
                {10,10,10,14,10,15,10,10,10,10,10,10,10,10,10,10,10,10,10,10},
                {15,15,15,15,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15},
                {15,15,15,17,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15},
                {15,15,15,10,15,16,15,15,15,15,15,15,15,15,15,15,15,15,15,15},
                {19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},


        };

/* -------------------------------------------------------------------------- */
/* cleanToken(): Limpia buffer de tokenFile                                    */
/* -------------------------------------------------------------------------- */
void cleanToken()
{
    int i;
    for ( i = 0; i <= MAXLONG; i++ )
        token[i] = '\0';
}

/* -------------------------------------------------------------------------- */
/* readCharacter(): Lee un readedChar del archivo                                */
/* -------------------------------------------------------------------------- */
void readCharacter()
{
    readedChar = fgetc( inputFile );

    if( readedChar == '\n' )
    {
        rowCount++;
        columnCount = 1;
    }
    else
    {
        columnCount++;
    }
}

/* -------------------------------------------------------------------------- */
/* saveToken(): Muestra el token por pantalla y lo guarda en tabla tokenFile  */
/* -------------------------------------------------------------------------- */
void saveToken()
{
    switch ( tokenNumber )
    {
        case ID:
            printf( "< ID       : %s >\n", token );
            fprintf(tokenFile, "< ID       : %s >\n", token );
            break;
        case PR_MAIN:
            printf( "< PR MAIN  : %s >\n", token );
            fprintf(tokenFile, "< PR MAIN  : %s >\n", token );
            break;
        case PR_ENDMAIN:
            printf( "< PR ENDMAIN  : %s >\n", token );
            fprintf(tokenFile, "< PR ENDMAIN  : %s >\n", token );
            break;
        case PR_WHILE:
            printf( "< PR WHILE  : %s >\n", token );
            fprintf(tokenFile, "< PR WHILE  : %s >\n", token );
            break;
        case PR_ENDWHILE:
            printf( "< PR ENDWHILE  : %s >\n", token );
            fprintf(tokenFile, "< PR ENDWHILE  : %s >\n", token );
            break;
        case PR_IF:
            printf( "< PR IF  : %s >\n", token );
            fprintf(tokenFile, "< PR IF  : %s >\n", token );
            break;
        case PR_ENDIF:
            printf( "< PR ENDIF  : %s >\n", token );
            fprintf(tokenFile, "< PR ENDIF  : %s >\n", token );
            break;
        case PR_FLOAT:
            printf( "< PR FLOAT  : %s >\n", token );
            fprintf(tokenFile, "< PR FLOAT  : %s >\n", token );
            break;
        case PR_INT:
            printf( "< PR INT  : %s >\n", token );
            fprintf(tokenFile, "< PR INT  : %s >\n", token );
            break;
        case PR_STR:
            printf( "< PR STR  : %s >\n", token );
            fprintf(tokenFile, "< PR STR  : %s >\n", token );
            break;
        case PR_CONST:
            printf( "< PR CONST  : %s >\n", token );
            fprintf(tokenFile, "< PR CONST  : %s >\n", token );
            break;
        case PR_PUT:
            printf( "< PR PUT  : %s >\n", token );
            fprintf(tokenFile, "< PR PUT  : %s >\n", token );
            break;
        case PR_GET:
            printf( "< PR GET  : %s >\n", token );
            fprintf(tokenFile, "< PR GET  : %s >\n", token );
            break;
        case PR_AND:
            printf( "< PR AND  : %s >\n", token );
            fprintf(tokenFile, "< PR AND  : %s >\n", token );
            break;
        case PR_OR:
            printf( "< PR OR  : %s >\n", token );
            fprintf(tokenFile, "< PR OR  : %s >\n", token );
            break;
        case PR_DECLARE:
            printf( "< PR DECLARE  : %s >\n", token );
            fprintf(tokenFile, "< PR DECLARE  : %s >\n", token );
            break;
        case PR_ENDDECLARE:
            printf( "< PR ENDDECLARE  : %s >\n", token );
            fprintf(tokenFile, "< PR ENDDECLARE  : %s >\n", token );
            break;
        case PR_QEQUAL:
            printf( "< PR QEQUAL  : %s >\n", token );
            fprintf(tokenFile, "< PR QEQUAL  : %s >\n", token );
            break;
        case PR_NOT:
            printf( "< PR NOT  : %s >\n", token );
            fprintf(tokenFile, "< PR NOT  : %s >\n", token );
            break;

        case CTE_ENT:
            printf( "< CTE ENT  : %s >\n", token );
            fprintf(tokenFile, "< CTE ENT  : %s >\n", token );
            break;
        case CTE_REAL:
            printf( "< CTE REAL : %s >\n", token );
            fprintf(tokenFile, "< CTE REAL : %s >\n", token );
            break;
        case CTE_STRING:
            printf( "< CTE_STR  : %s >\n", token );
            fprintf(tokenFile, "< CTE_STR  : %s >\n", token );
            break;
        case OP_PABRE:
            printf( "< ABRE PAR : %s >\n", token );
            fprintf(tokenFile, "< ABRE PAR : %s >\n", token );
            break;
        case OP_PCIERRA:
            printf( "< CIERR PAR: %s >\n", token );
            fprintf(tokenFile, "< CIERR PAR: %s >\n", token );
            break;
        case OP_MENOR:
            printf( "< OP_MENOR : %s >\n", token );
            fprintf(tokenFile, "< OP_MENOR : %s >\n", token );
            break;
        case OP_MENORIGUAL:
            printf( "< OP_MENIGU: %s >\n", token );
            fprintf(tokenFile, "< OP_MENIGU: %s >\n", token );
            break;
        case OP_MAYOR:
            printf( "< OP_MAYOR : %s >\n", token );
            fprintf(tokenFile, "< OP_MAYOR : %s >\n", token );
            break;
        case OP_MAYORIGUAL:
            printf( "< OP_MAYIGU: %s >\n", token );
            fprintf(tokenFile, "< OP_MAYIGU: %s >\n", token );
            break;
        case OP_IGUAL:
            printf( "< OP_IGUAL : %s >\n", token );
            fprintf(tokenFile, "< OP_IGUAL : %s >\n", token );
            break;
        case OP_DISTINTO:
            printf( "< OP_DISTIN: %s >\n", token );
            fprintf(tokenFile, "< OP_DISTIN: %s >\n", token );
            break;
        case OP_SUMA:
            printf( "< OP_SUMA  : %s >\n", token );
            fprintf(tokenFile, "< OP_SUMA  : %s >\n", token );
            break;
        case OP_RESTA:
            printf( "< OP_RESTA : %s >\n", token );
            fprintf(tokenFile, "< OP_RESTA : %s >\n", token );
            break;
        case OP_MULTIPLI:
            printf( "< OP_MULTI : %s >\n", token );
            fprintf(tokenFile, "< OP_MULTI : %s >\n", token );
            break;
        case OP_DIVISION:
            printf( "< OP_DIV   : %s >\n", token );
            fprintf(tokenFile, "< OP_DIV   : %s >\n", token );
            break;
        case OP_CABRE:
            printf( "< ABRE COR : %s >\n", token );
            fprintf(tokenFile, "< ABRE COR : %s >\n", token );
            break;
        case OP_CCIERRA:
            printf( "< CIERR COR: %s >\n", token );
            fprintf(tokenFile, "< CIERR COR: %s >\n", token );
            break;
        case OP_ASIG:
            printf( "< OP_ASIG  : %s >\n", token );
            fprintf(tokenFile, "< OP_ASIG  : %s >\n", token );
            break;
        case OP_LLABRE:
            printf( "< ABRE LLA : %s >\n", token );
            fprintf(tokenFile, "< ABRE LLA : %s >\n", token );
            break;
        case OP_LLCIERRA:
            printf( "< CIERR LLA: %s >\n", token );
            fprintf(tokenFile, "< CIERR LLA: %s >\n", token );
            break;
        case OP_CONCAT:
            printf( "< OP_CONCAT: %s >\n", token );
            fprintf(tokenFile, "< OP_CONCAT: %s >\n", token );
            break;
        case SEP_SENT:
            printf( "< SEPA_SENT: %s >\n", token );
            fprintf(tokenFile, "< SEPA_SENT: %s >\n", token );
            break;
        case OP_TIPO:
            printf( "< OP_TIPO  : %s >\n", token );
            fprintf(tokenFile, "< OP_TIPO  : %s >\n", token );
            break;
        case SEP_LISTA:
            printf( "< SEP_LISTA: %s >\n", token );
            fprintf(tokenFile, "< SEP_LISTA: %s >\n", token );
            break;
        case OP_INT:
            printf( "< OP_INT : %s >\n", token );
            fprintf(tokenFile, "< OP_INT : %s >\n", token );
            break;
    }

    //fprintf( tokenFile, "[ %s ] \n", token );
}

/* -------------------------------------------------------------------------- */
/* getColumnNumber(): Retorna la columna que corresponde al caracter ingresado    */
/* -------------------------------------------------------------------------- */
int getColumnNumber( char character )
{
    // LETRAS
    if ( character <= 'z' && character >= 'a' )
        return 0;
    if ( character <= 'Z' && character >= 'A' )
        return 0;

    // DIGITOS
    if ( character >= '0' && character <= '9' )
        return 1;

    // OTROS CARACTERES
    switch ( character )
    {
        case '+':
            return 2;
            break;
        case '-':
            return 3;
            break;
        case '*':
            return 4;
            break;
        case '/':
            return 5;
            break;
        case '(':
            return 6;
            break;
        case ')':
            return 7;
            break;
        case '.':
            return 8;
            break;
        case '=':
            return 9;
            break;
        case ';':
            return 10;
            break;
        case '"':
            return 11;
            break;
        case '>':
            return 12;
            break;
        case '<':
            return 13;
            break;
        case ':':
            return 14;
            break;
        case ' ':
            return 15;
            break;
        case '\t':
            return 15;
            break;
        case '\n':
            return 15;
            break;
        case '?':
            return 16;
            break;
        case ',':
            return 17;
            break;
        case '[':
            return 18;
            break;
        case ']':
            return 19;
            break;
        case EOF:
            return EOF;
            break;
    }

    //
    // Cualquier otro caracter es ignorado
    //
    if ( openStringConstant == 0 && openComment == 0 )
    {
        printf( "\n ERROR: Caracter no reconocido: '%c'. \n", character );
        printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
        exit( 1 );
    }

}

/* -------------------------------------------------------------------------- */
/* buscarEnTOS(): Busca en la TOS un simbolo por el indice                    */
/* -------------------------------------------------------------------------- */
char * buscarEnTOS( int index )
{
    return TOS[index].nombre;
}

/* -------------------------------------------------------------------------- */
/* insertInTOS(): Inserta en la TOS o si ya existe devuelve la posicion       */
/* -------------------------------------------------------------------------- */
int insertInTOS()
{
    int i, j, x = 0;
    int ii = 0;
    char aux[100];
    char auxStr[100];

    if ( tokenNumber == CTE_STRING )
    {
        strcpy( auxStr, " " );

        for ( j = 0; j < strlen( token ); j++ )
        {
            if ( token[j] != '"' )
            {
                auxStr[x] = token[j];
                x++;
            }
        }

        auxStr[strlen( token ) - 1] = '\0';
    }


    for ( i = 0; i < symbolTableIndex; i++ )
    {
        if ( tokenNumber == ID )
        {
            if ( strcmp( TOS[i].nombre, token ) == 0 )
                return i;
        }
        else if ( tokenNumber == CTE_STRING )
        {
            if ( strcmp( TOS[i].valor, auxStr ) == 0 )
                return i;
        }
        else
        {
            if ( strcmp( TOS[i].valor, token ) == 0 )
                return i;
        }
    }

    switch ( tokenNumber )
    {
        case ID:
            strcat( aux, token );
            strcpy( TOS[symbolTableIndex].nombre, token );
            strcpy( TOS[symbolTableIndex].tipo, "ID" );
            symbolTableIndex++;
            break;
        case CTE_ENT:
            strcpy( aux, "_" );
            strcat( aux, token );
            strcpy( TOS[symbolTableIndex].nombre, aux );
            strcpy( TOS[symbolTableIndex].tipo, "CTE_ENT" );
            strcpy( TOS[symbolTableIndex].valor, token );
            symbolTableIndex++;
            break;
        case CTE_REAL:
            strcpy( aux, "_" );
            strcat( aux, token );
            strcpy( TOS[symbolTableIndex].nombre, aux );
            strcpy( TOS[symbolTableIndex].tipo, "CTE_REAL" );
            strcpy( TOS[symbolTableIndex].valor, token );
            symbolTableIndex++;
            break;
        case CTE_STRING:
            strcpy( aux, "_" );
            strcat( aux, auxStr );
            strcpy( TOS[symbolTableIndex].nombre, aux );
            strcpy( TOS[symbolTableIndex].tipo, "CTE_STRING" );
            strcpy( TOS[symbolTableIndex].valor, auxStr );
            TOS[symbolTableIndex].longitud = ( strlen( auxStr ));
            symbolTableIndex++;
            break;
    }

    return symbolTableIndex - 1;
}

void showTOS()
{
    int i;

    printf("\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n");
    fprintf( tosFile, "\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n" );

    printf ("Nro\t | Nombre\t\t\t | Tipo\t | Valor\n");
    fprintf( tosFile, "Nro\t | Nombre\t\t\t | Tipo\t | Valor\t | Longitud \n" );
    for ( i = 0; i < symbolTableIndex; i++ )
    {
        printf ("%d     \t | %s     \t\t\t | %s     \t | %s \n",i,TOS[i].nombre, TOS[i].tipo, TOS[i].valor);
        fprintf( tosFile, "%d     \t | %s     \t\t\t | %s     \t | %s \t | %d \n", i, TOS[i].nombre, TOS[i].tipo,
                 TOS[i].valor, TOS[i].longitud );
    }
    printf("\n--------------------------------------------------------------------------------\n");
    fprintf( tosFile, "\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n" );
}

/* -------------------------------------------------------------------------- */
/* getReserverWordNumber(): Varifica si un ID es una palabra reservada           */
/* -------------------------------------------------------------------------- */
int getReserverWordNumber()
{
    int i;
    for ( i = 0; i < CANTPR; i++ )
    {
        if ( strcmp( TOS[i].nombre, token ) == 0 ) // strcmpi lo hacia sin diferenciar Mayus/Minus
        {
            return ++i;
        }
    }

    return 0;
}

/* -------------------------------------------------------------------------- */
/* addReservedWords(): Agrega las Palabras reservadas a la Tabla de Simbolos  */
/* -------------------------------------------------------------------------- */
void addReservedWords()
{
    symbolTableIndex = 0;
    strcpy( TOS[symbolTableIndex].nombre, "MAIN" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ENDMAIN" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "WHILE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ENDWHILE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "IF" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ELSE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ENDIF" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "FLOAT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "INT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "STR" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "CONST" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "PUT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "GET" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "AND" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "OR" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "DECLARE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ENDDECLARE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "QEQUAL" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "NOT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;
}

void makeValidations()
{
    if ( openComment != 0 )
    {
        printf( "\n ERROR: COMENTARIO no cerrado correctamente (no balancea). \n" );
        error = 1;
    }

    if ( openStringConstant != 0 )
    {
        printf( "\n ERROR: CTE STRING no cerrada correctamente (no balancea). \n" );
        error = 1;
    }

    if ( tokenNumber == CTE_ENT || tokenNumber == CTE_REAL )
    {
        Inf_Constant();
    }
}

/* -------------------------------------------------------------------------- */
/*                               FUNCION YYLEX                                */
/* -------------------------------------------------------------------------- */
int yylex()
{
    int currentState = 0;
    int column;

    readCharacter();

    if ( readedChar == EOF)
    {
        tokenNumber = EOF;
        return tokenNumber;
    }

    while ( currentState != FINAL_STATE )
    {
        column = getColumnNumber( readedChar );

        //
        // Ejecuto la funcion correspondiente de la matriz
        //
        ( *proceso[currentState][column] )();

        // Luego cambio de estado
        currentState = nEstado[currentState][column];

        if ( currentState != FINAL_STATE )
        {
            readCharacter();

            if ( readedChar == EOF)
            {
                makeValidations();

                if ( tokenNumber == ID && error == 0 )
                    Inf_ID();

                if ( currentState == 0 )
                    return EOF;

                return tokenNumber;
            }
        }
    }

    //saveToken();
    return tokenNumber;
}

/**
 * Creates a file with the tokenFile for the corresponding inputFile
 */
void analizeToFile( char * fileToAnalize )
{

    addReservedWords();

    if (( inputFile = fopen( fileToAnalize, "r" )) == NULL)
    {
        printf( "No se puede abrir el archivo de entrada" );
        getch();
        exit( 1 );
    }


    if (( tokenFile = fopen( "prueba.txt", "w" )) == NULL)
    {
        printf( "No se puede crear el archivo de prueba.txt" );
        getch();
        exit( 1 );
    }

    // Go to the end of the filw writing the tokenFile

    while ( feof( inputFile ) == 0 )
    {
        if ( yylex() != EOF)
        {
            if ( error == 0 )
                saveToken();
        }
    }


    if ( fclose( inputFile ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de entrada" );
        getch();
        exit( 1 );
    }

    if ( fclose( tokenFile ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de tokenFile" );
        getch();
        exit( 1 );
    }

    if ( error == 0 )
    {
        printf( "\n - Compilacion EXITOSA - \n" );

        if (( tosFile = fopen( "tos.txt", "w" )) == NULL)
        {
            printf( "No se puede crear el archivo de la tabla de TOS" );
            getch();
            exit( 1 );
        }

        showTOS();

        if ( fclose( tosFile ) != 0 )
        {
            printf( "No se puede CERRAR el archivo de la tabla de tos" );
            getch();
            exit( 1 );
        }
    }

    if ( error == 1 )
        printf( "\n - Compilacion con ERRORES - \n" );
}


int yyerror(char * s)
{
    printf("ERROR: %s (%d,%d)\n", s, rowCount, columnCount);
}

int main (int argc, char *argv[])
{
    addReservedWords();
    init(&polishStack);

    if (( inputFile = fopen( "pruebagral.txt", "r" )) == NULL)
    {
        printf( "No se puede abrir el archivo de entrada" );
        getch();
        exit( 1 );
    }


    if (( tokenFile = fopen( "prueba.txt", "w" )) == NULL)
    {
        printf( "No se puede crear el archivo de prueba.txt" );
        getch();
        exit( 1 );
    }

    while (feof(inputFile)== 0)
    {
        yyparse();
    }

    if ( fclose( inputFile ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de entrada" );
        getch();
        exit( 1 );
    }

    if ( fclose( tokenFile ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de tokenFile" );
        getch();
        exit( 1 );
    }

    if ( error == 0 )
    {
         printf( "\n - Compilacion EXITOSA - \n" );

        if (( tosFile = fopen( "tos.txt", "w" )) == NULL)
        {
            printf( "No se puede crear el archivo de la tabla de TOS" );
            getch();
            exit( 1 );
        }

        printf( "\n - Tira POLACA: - \n" );
        mostrar_polaca();
        showTOS();
        stack_print(&polishStack);

        if ( fclose( tosFile ) != 0 )
        {
            printf( "No se puede CERRAR el archivo de la tabla de tos" );
            getch();
            exit( 1 );
        }
    }

    if ( error == 1 )
        printf( "\n - Analisis Lexico completo con ERRORES - \n" );

}
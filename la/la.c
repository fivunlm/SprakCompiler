#include "la.h"

// TODO: La tabla de simbolos contiene las palabras reservadas creo que esto no es una practica recomendada

/* -------------------------------------------------------------------------- */
/*                             VARIABLES GLOBALES                             */
/* -------------------------------------------------------------------------- */

FILE * inputFile;          // Archivo de entrada.

// Ficheros Temporales
FILE * tokenFile;         // Archivo de Tokens
FILE * tosFile;           // Archivo de TOS ( Table Of Symbols )

char readedChar;           // Caracter leido.
int tokenNumber = -1;        // Valor que devuelve el yylex.
int tokenSize = 0;         // Se utiliza para validar los tamaños de los ID y ConstantSTR.
char token[1000];         // Almacena el token armado.
int openStringConstant;        // Para validar que las ctes string esten bien formadas. Por ahora no la estamos usando.
int openComment;           // Para validar que los comentarios son cerrados.
int error = 0;            // para identificar si hubo o no error.
int nroLinea = 1;         // Para identificar en que línea se produjo el error.
int ptoInicio = 0;        // Para completar el nro segun corresponda EJ:.36 => 0.36
int symbolTableIndex = 0;           // Índice de la TOS

//Variable global provisoria

int yylval;

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
                tokenNumber = PR_VAR;
                yylval = 2;
                break;
            case 3:
                tokenNumber = PR_AS;
                yylval = 3;
                break;
            case 4:
                tokenNumber = PR_ENDVAR;
                yylval = 4;
                break;
            case 5:
                tokenNumber = PR_IF;
                yylval = 5;
                break;
            case 6:
                tokenNumber = PR_THEN;
                yylval = 6;
                break;
            case 7:
                tokenNumber = PR_ELSE;
                yylval = 7;
                break;
            case 8:
                tokenNumber = PR_FI;
                yylval = 8;
                break;
            case 9:
                tokenNumber = PR_FOR;
                yylval = 9;
                break;
            case 10:
                tokenNumber = PR_TO;
                yylval = 10;
                break;
            case 11:
                tokenNumber = PR_STEP;
                yylval = 11;
                break;
            case 12:
                tokenNumber = PR_ROF;
                yylval = 12;
                break;
            case 13:
                tokenNumber = PR_DO;
                yylval = 13;
                break;
            case 14:
                tokenNumber = PR_WHILE;
                yylval = 14;
                break;
            case 15:
                tokenNumber = PR_WPRINT;
                yylval = 15;
                break;
            case 16:
                tokenNumber = PR_FILTERC;
                yylval = 16;
                break;
            case 17:
                tokenNumber = PR_INTEGER;
                yylval = 17;
                break;
            case 18:
                tokenNumber = PR_FLOAT;
                yylval = 18;
                break;
            case 19:
                tokenNumber = PR_STRING;
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
    openComment = 0;
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
    if ( strcmp( token, "&" ) == 0 )
        printf( "\n - ERROR: Se esperaba & \n" );

    if ( strcmp( token, "|" ) == 0 )
        printf( "\n - ERROR: Se esperaba | \n" );

    if ( strcmp( token, "." ) == 0 )
        printf( "\n - ERROR: Se esperaba un digito \n" );

    printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
    exit( 0 );
}

/* ASIGNACION --------------------------------------------------------------- */
void Inf_Assignment()
{
    tokenNumber = OP_ASIG;
    ungetc(( int ) readedChar, inputFile ); //Segun Automata
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
    tokenNumber = OP_ASIG;
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
void Inf_LessEqual()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_MENORIGUAL;
}

/* OR  ---------------------------------------------------------------------- */
void Init_Or()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
}

void Inf_Or()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_OR;
}

/* AND ---------------------------------------------------------------------- */
void Init_And()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
}

void Inf_And()
{
    tokenSize++;
    token[tokenSize] = readedChar;
    tokenNumber = OP_AND;
}

/* NOT ---------------------------------------------------------------------- */
void Inf_not()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_NOT;
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
void Inf_Undesrcore()
{
    cleanToken();
    tokenSize = 0;
    token[tokenSize] = readedChar;
    tokenNumber = OP_GUION;
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
void (* proceso[16][27])() =
        {
//                   0 |            1  |            2  |            3  |            4  |            5  |             6  |            7  |                 8  |            9  |           10  |           11  |           12  |              13  |            14  |               15  |           16  |           17  |           18  |            19  |           20  |           21  |           22  |           23  |           24  |            25  |            26  |
//                   + |            -  |            *  |            /  |           Let |           Dig |             =  |            <  |                 >  |            &  |            |  |            !  |            "  |               .  |             [  |           	 ]   |            {  | 	         }   |            (  |             )  |            ,  |            _  |            ;  |           tab |           blan|            ent |             :  |
/*E0*/    { Init_Concatenation, Init_Comment, Inf_Multiply, Inf_Division, Init_ID,     Init_Constant, Init_Equal, Init_Different,   Init_MayorIgual, Init_And,    Init_Or,     Inf_not, Init_StringConstant,  Init_Constant_Float, Inf_OpenBrace, Inf_ClosingBrace, Inf_OpLLAbre,   Inf_OpLLCierra, Inf_OpenParentesis, Inf_ClosingParentesis, Inf_ListSeparator, Inf_Undesrcore, Inf_Separator, None, None, None, Inf_Type },
/*E1*/
          { Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID, Add_ID, Add_ID,     Inf_ID,         Inf_ID,         Inf_ID,             Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,            Inf_ID,          Inf_ID,            Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,          Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID },
/*E2*/
          { Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Agregar_Constant,    Inf_Constant,        Inf_Constant,        Inf_Constant,            Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Init_Constant_Float, Inf_Constant,         Inf_Constant,           Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,         Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant },
/*E3*/
          { Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Agregar_Constant,    Inf_Constant,        Inf_Constant,        Inf_Constant,            Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,      CharacterNotValid,     Inf_Constant,         Inf_Constant,           Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,         Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant,        Inf_Constant },
/*E4*/
          { Inf_Minus, Inf_Minus, Inf_Minus, Inf_Comment, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus, Inf_Minus },
/*E5*/
          { Add_Comment,    Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment },
/*E6*/
          { Add_Comment, Finish_Comment,     Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment, Add_Comment },
/*E7*/
          { Inf_Concatenation, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition, Inf_Addition },
/*E8*/
          { Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Equal, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment, Inf_Assignment },
/*E9*/
          { Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_LessEqual, Inf_Less, Inf_Different, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less, Inf_Less },
/*E10*/
          { CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid, Inf_And,                   CharacterNotValid,   CharacterNotValid,   CharacterNotValid, CharacterNotValid,     CharacterNotValid,    CharacterNotValid,      CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,    CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid },
/*E11*/
          { CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,       CharacterNotValid, Inf_Or,                CharacterNotValid,   CharacterNotValid, CharacterNotValid,     CharacterNotValid,    CharacterNotValid,      CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,    CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid },
/*E12*/
          { Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_GreatEqual, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great, Inf_Great },
/*E13*/
          { Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Inf_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant, Add_StringConstant,                                   CharacterNotValid,   CharacterNotValid },
/*E14*/
          { CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,       CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid, CharacterNotValid,     CharacterNotValid,    CharacterNotValid,      CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,    CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid },
/*E15*/
          { CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,       CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid, CharacterNotValid,     CharacterNotValid,    CharacterNotValid,      CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,    CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid,   CharacterNotValid }
        };

//MATRIZ ESTADOS
static int nEstado[16][27] =
        {
//        0 |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  | 10  | 11  | 12  | 13  | 14  | 15  | 16  | 17  | 18 |  19  | 20  | 21  | 22  | 23  | 24  |  25 |  26 |
//        + |  -  |  *  |  /  | Let | Dig |  =  |  <  |  >  |  &  |  |  |  !  |  "  |  .  |  [  |  ]  |  {  |  }  | (  |   )  |  ,  |  _  |  ;  | tab | blan|  ent|   : |
/*E0*/ { 7,  4,  15, 15, 1,  2,  8,  9,  12, 10, 11, 15, 13, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 0,  0,  0,  15 },
/*E1*/
       { 15, 15, 15, 15, 1,  1,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E2*/
       { 15, 15, 15, 15, 15, 2,  15, 15, 15, 15, 15, 15, 15, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E3*/
       { 15, 15, 15, 15, 15, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E4*/
       { 15, 15, 15, 5,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E5*/
       { 5,  5,  5,  6,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5 },
/*E6*/
       { 5,  0,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5 },
/*E7*/
       { 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E8*/
       { 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E9*/
       { 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E10*/
       { 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14 },
/*E11*/
       { 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14 },
/*E12*/
       { 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15 },
/*E13*/
       { 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 15, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13 },
/*E14*/
       { 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14 },
/*E15*/
       { 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14 }
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
            break;
        case PR_MAIN:
            printf( "< PR MAIN  : %s >\n", token );
            break;
        case PR_VAR:
            printf( "< PR VAR   : %s >\n", token );
            break;
        case PR_AS:
            printf( "< PR AS   : %s >\n", token );
            break;
        case PR_ENDVAR:
            printf( "< PR ENDVAR: %s >\n", token );
            break;
        case PR_IF:
            printf( "< PR IF    : %s >\n", token );
            break;
        case PR_THEN:
            printf( "< PR THEN  : %s >\n", token );
            break;
        case PR_ELSE:
            printf( "< PR ELSE  : %s >\n", token );
            break;
        case PR_FI:
            printf( "< PR FI    : %s >\n", token );
            break;
        case PR_FOR:
            printf( "< PR FOR   : %s >\n", token );
            break;
        case PR_TO:
            printf( "< PR TO    : %s >\n", token );
            break;
        case PR_STEP:
            printf( "< PR STEP  : %s >\n", token );
            break;
        case PR_ROF:
            printf( "< PR ROF   : %s >\n", token );
            break;
        case PR_DO:
            printf( "< PR DO    : %s >\n", token );
            break;
        case PR_WHILE:
            printf( "< PR WHILE : %s >\n", token );
            break;
        case PR_WPRINT:
            printf( "< PR WPRINT: %s >\n", token );
            break;
        case PR_FILTERC:
            printf( "< PR FILTER: %s >\n", token );
            break;
        case PR_STRING:
            printf( "< PR_STRING : %s >\n", token );
            break;
        case PR_INTEGER:
            printf( "< PR_INTEGER : %s >\n", token );
            break;
        case PR_FLOAT:
            printf( "< PR_FLOAT : %s >\n", token );
            break;
        case CTE_ENT:
            printf( "< CTE ENT  : %s >\n", token );
            break;
        case CTE_REAL:
            printf( "< CTE REAL : %s >\n", token );
            break;
        case CTE_STRING:
            printf( "< CTE_STR  : %s >\n", token );
            break;
        case OP_PABRE:
            printf( "< ABRE PAR : %s >\n", token );
            break;
        case OP_PCIERRA:
            printf( "< CIERR PAR: %s >\n", token );
            break;
        case OP_OR:
            printf( "< OP_OR    : %s >\n", token );
            break;
        case OP_AND:
            printf( "< OP_AND   : %s >\n", token );
            break;
        case OP_NOT:
            printf( "< OP_NOT   : %s >\n", token );
            break;
        case OP_MENOR:
            printf( "< OP_MENOR : %s >\n", token );
            break;
        case OP_MENORIGUAL:
            printf( "< OP_MENIGU: %s >\n", token );
            break;
        case OP_MAYOR:
            printf( "< OP_MAYOR : %s >\n", token );
            break;
        case OP_MAYORIGUAL:
            printf( "< OP_MAYIGU: %s >\n", token );
            break;
        case OP_IGUAL:
            printf( "< OP_IGUAL : %s >\n", token );
            break;
        case OP_DISTINTO:
            printf( "< OP_DISTIN: %s >\n", token );
            break;
        case OP_SUMA:
            printf( "< OP_SUMA  : %s >\n", token );
            break;
        case OP_RESTA:
            printf( "< OP_RESTA : %s >\n", token );
            break;
        case OP_MULTIPLI:
            printf( "< OP_MULTI : %s >\n", token );
            break;
        case OP_DIVISION:
            printf( "< OP_DIV   : %s >\n", token );
            break;
        case OP_CABRE:
            printf( "< ABRE COR : %s >\n", token );
            break;
        case OP_CCIERRA:
            printf( "< CIERR COR: %s >\n", token );
            break;
        case OP_ASIG:
            printf( "< OP_ASIG  : %s >\n", token );
            break;
        case OP_LLABRE:
            printf( "< ABRE LLA : %s >\n", token );
            break;
        case OP_LLCIERRA:
            printf( "< CIERR LLA: %s >\n", token );
            break;
        case OP_CONCAT:
            printf( "< OP_CONCAT: %s >\n", token );
            break;
        case SEP_SENT:
            printf( "< SEPA_SENT: %s >\n", token );
            break;
        case OP_TIPO:
            printf( "< OP_TIPO  : %s >\n", token );
            break;
        case SEP_LISTA:
            printf( "< SEP_LISTA: %s >\n", token );
            break;
        case OP_GUION:
            printf( "< OP_GUION : %s >\n", token );
            break;
    }

    fprintf( tokenFile, "[ %s ] \n", token );
}

/* -------------------------------------------------------------------------- */
/* getColumnNumber(): Retorna la columna que corresponde al caracter ingresado    */
/* -------------------------------------------------------------------------- */
int getColumnNumber( char character )
{
    // TODO: Cambiar los numeros de columna de acuerdo a las nuestras

    // LETRAS
    if ( character <= 'z' && character >= 'a' )
        return 4;
    if ( character <= 'Z' && character >= 'A' )
        return 4;

    // DIGITOS
    if ( character >= '0' && character <= '9' )
        return 5;

    // OTROS CARACTERES
    switch ( character )
    {
        case '"':
            return 12;
            break;
        case '=':
            return 6;
            break;
        case '<':
            return 7;
            break;
        case '>':
            return 8;
            break;
        case '!':
            return 11;
            break;
        case '|':
            return 10;
            break;
        case '&':
            return 9;
            break;
        case '+':
            return 0;
            break;
        case '-':
            return 1;
            break;
        case '*':
            return 2;
            break;
        case '/':
            return 3;
            break;
        case '(':
            return 18;
            break;
        case ')':
            return 19;
            break;
        case '[':
            return 14;
            break;
        case ']':
            return 15;
            break;
        case '{':
            return 16;
            break;
        case '}':
            return 17;
            break;
        case ';':
            return 22;
            break;
        case ',':
            return 20;
            break;
        case '.':
            return 13;
            break;
        case '\n':
            return 25;
            break;
        case '\t':
            return 23;
            break;
        case ' ':
            return 24;
            break;
        case '\0':
            return 24;
            break;
        case ':':
            return 26;
            break;
        case '_':
            return 21;
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

    strcpy( TOS[symbolTableIndex].nombre, "VAR" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "AS" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ENDVAR" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "IF" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "THEN" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ELSE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "FI" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "FOR" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "TO" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "STEP" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "ROF" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "DO" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "WHILE" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "WPRINT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "FILTERC" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "INTEGER" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "FLOAT" );
    strcpy( TOS[symbolTableIndex].tipo, "PR" );
    symbolTableIndex++;

    strcpy( TOS[symbolTableIndex].nombre, "STRING" );
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

    if (( strcmp( token, "&" ) == 0 ) || ( strcmp( token, "|" ) == 0 ))
    {
        printf( "\n ERROR: Se esperaba %s \n", token );
        exit( 1 );
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


    if (( tokenFile = fopen( "tokenFile.txt", "w" )) == NULL)
    {
        printf( "No se puede crear el archivo de tokenFile" );
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
        printf( "\n - Analisis Lexico COMPLETO - \n" );

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
        printf( "\n - Analisis Lexico completo con ERRORES - \n" );
}
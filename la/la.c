#include "la.h"

/* -------------------------------------------------------------------------- */
/*                            DEFINICION FUNCIONES                            */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*                             VARIABLES GLOBALES                             */
/* -------------------------------------------------------------------------- */

FILE * input;          // ARCHIVO ENTRADA.

//Ficheros Temporales
FILE * tokens;         //Archivo de Tokens
FILE * tos;            //Archivo de TOS

char caracter;          // CARACTER LEIDO.
int NroToken = -1;          // Valor que devuelve el yylex.
int TamToken = 0;          // Se utiliza para validar los tamaños de los ID y CteSTR.
char token[1000];     // Almacena el token armado.
int cteStrAbierta;    // Para validar que las ctes string esten bien formadas. Por ahora no la estamos usando.
int comAbierto;       // Para validar que los comentarios son cerrados.
int error = 0;        // para identificar si hubo o no error.
int nroLinea = 1;          // Para identificar en que línea se produjo el error.
int ptoInicio = 0;      // Para completar el nro segun corresponda EJ:.36 => 0.36
int TOStop = 0;          // Índice de la TOS

//Variable global provisoria

int yylval;

/* IDENTIFICADORES ---------------------------------------------------------- */
void Iniciar_ID()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    //Posible ID
    NroToken = ID;
}

void Agregar_ID()
{
    if ( strlen( token ) < MAXLONG )
    {
        token[++TamToken] = caracter;
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
        switch ( esPalabraReservada())
        {
            case 0:
                NroToken = ID;
                yylval = insertarTOS(); //TOS
                break;
            case 1:
                NroToken = PR_MAIN;
                yylval = 1;
                break;
            case 2:
                NroToken = PR_VAR;
                yylval = 2;
                break;
            case 3:
                NroToken = PR_AS;
                yylval = 3;
                break;
            case 4:
                NroToken = PR_ENDVAR;
                yylval = 4;
                break;
            case 5:
                NroToken = PR_IF;
                yylval = 5;
                break;
            case 6:
                NroToken = PR_THEN;
                yylval = 6;
                break;
            case 7:
                NroToken = PR_ELSE;
                yylval = 7;
                break;
            case 8:
                NroToken = PR_FI;
                yylval = 8;
                break;
            case 9:
                NroToken = PR_FOR;
                yylval = 9;
                break;
            case 10:
                NroToken = PR_TO;
                yylval = 10;
                break;
            case 11:
                NroToken = PR_STEP;
                yylval = 11;
                break;
            case 12:
                NroToken = PR_ROF;
                yylval = 12;
                break;
            case 13:
                NroToken = PR_DO;
                yylval = 13;
                break;
            case 14:
                NroToken = PR_WHILE;
                yylval = 14;
                break;
            case 15:
                NroToken = PR_WPRINT;
                yylval = 15;
                break;
            case 16:
                NroToken = PR_FILTERC;
                yylval = 16;
                break;
            case 17:
                NroToken = PR_INTEGER;
                yylval = 17;
                break;
            case 18:
                NroToken = PR_FLOAT;
                yylval = 18;
                break;
            case 19:
                NroToken = PR_STRING;
                yylval = 19;
                break;
        }
        ungetc((int) caracter, input );
    }
    else
    {
        NroToken = 0;
    }
}

/* CONSTANTE NUMERICAS ------------------------------------------------------ */
void Iniciar_Cte()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;        //guardamos el primer caracter del ID en la cadena auxiliar
    TamToken++;
    //Posible CTE
    NroToken = CTE_ENT;
}

void Iniciar_Cte_Float()
{
    if ( NroToken != CTE_ENT )
    {
        limpiarToken();
        TamToken = 0;
    }

    token[TamToken] = caracter;        //guardamos el primer caracter del ID en la cadena auxiliar
    TamToken++;
    //Posible CTE
    NroToken = CTE_REAL;
}

void Agregar_Cte()
{
    token[TamToken] = caracter;
    TamToken++;
}

void Inf_Cte()
{
    if ( NroToken == CTE_ENT )
    {
        int cte = atoi( token );
        if ((strlen( token ) > 5) || (cte > USHRT_MAX))
        {
            printf( "\n ERROR: # Se excede el rango para un ENTERO. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }
    }

    if ( NroToken == CTE_REAL )
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

        if ( decimales > FLT_PREC )
        {
            printf( "\n ERROR: # Se excede el rango de presicion para un REAL. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }

        double cte = atof( token );

        if ( cte > FLT_MAX )
        {
            printf( "\n ERROR: # Se excede el rango para un REAL. \n" );
            printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
            exit( 1 );
        }

    }

    yylval = insertarTOS(); // TOS
    ungetc((int) caracter, input );
}

/* CONSTANTE STRING --------------------------------------------------------- */
void Inciar_CteStr()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    cteStrAbierta++;
    //Posible CTE_STRING
    NroToken = CTE_STRING;
}

void Agregar_CteStr()
{
    if ( strlen( token ) < MAXLONG )
    {
        token[++TamToken] = caracter;
    }
    else
    {
        printf( "\n ERROR: La cantidad Maxima de caracteres para una Constante STRING es de 30. \n" );
        printf( "\n - Analisis Lexico INTERRUMPIDO - \n" );
        exit( 1 );
    }
}

void Inf_CteStr()
{
    token[++TamToken] = caracter;
    if ( error == 0 )
    {
        NroToken = CTE_STRING;
        yylval = insertarTOS(); //TOS
        cteStrAbierta--;
    }
    else
    {
        NroToken = 0;
        cteStrAbierta = 0;
    }
}

/* COMENTARIOS -------------------------------------------------------------- */
void Iniciar_Com()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_RESTA;
}

void Inf_com()
{
    limpiarToken();
    comAbierto++;
    Nada();
    NroToken = -1;
}

void Agregar_Com()
{
    limpiarToken();
    Nada();
}

void Fin_Com()
{
    comAbierto = 0;
    Nada();
}

/* SEPARADOR ---------------------------------------------------------------- */
void Inf_Sep()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = SEP_SENT;
}

/* NADA --------------------------------------------------------------------- */
void Nada()
{
    limpiarToken();
    TamToken = 0;
}

/* CARACTER NO VALIDO ------------------------------------------------------- */
void Caract_No_Val()
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
void Inf_Asignacion()
{
    NroToken = OP_ASIG;
    ungetc((int) caracter, input ); //Segun Automata
}

/* SUMA --------------------------------------------------------------------- */
void Inf_OpSuma()
{
    NroToken = OP_SUMA;
    ungetc((int) caracter, input ); //Segun Automata
}

/* RESTA -------------------------------------------------------------------- */
void Inf_OpResta()
{
    NroToken = OP_RESTA;
    ungetc((int) caracter, input ); //Segun Automata
}

/* PRODUCTO ----------------------------------------------------------------- */
void Inf_OpProducto()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_MULTIPLI;
}

/* DIVISION ----------------------------------------------------------------- */
void Inf_OpDivision()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_DIVISION;
}

/* CONCATENA ---------------------------------------------------------------- */
void Iniciar_concat()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    //Posible SUMA
    NroToken = OP_SUMA;
}

void Inf_OpConcat()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_CONCAT;

    //ungetc((int)caracter, input);
}

/* IGUAL -------------------------------------------------------------------- */
void Iniciar_Igual()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    //Posible ASIG
    NroToken = OP_ASIG;
}

void Inf_Igual()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_IGUAL;
}

/* DISTINTO ----------------------------------------------------------------- */
void Iniciar_Dist()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    //Posible MENOR
    NroToken = OP_MENOR;
}

void Inf_Distinto()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_DISTINTO;
}

/* MENOR -------------------------------------------------------------------- */
void Inf_Menor()
{
    NroToken = OP_MENOR;
    ungetc((int) caracter, input );  //Segun Automata
}

/* MAYOR -------------------------------------------------------------------- */
void Inf_MayorIgual()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_MAYORIGUAL;
}

/* MAYORoIGUAL -------------------------------------------------------------- */
void Iniciar_MayorIgual()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_MAYOR;
}

void Inf_Mayor()
{
    NroToken = OP_MAYOR;
    ungetc((int) caracter, input ); //segun automata
}

/* MENORoIGUAL -------------------------------------------------------------- */
void Inf_MenorIgual()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_MENORIGUAL;
}

/* OR  ---------------------------------------------------------------------- */
void Iniciar_Or()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
}

void Inf_OpOr()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_OR;
}

/* AND ---------------------------------------------------------------------- */
void Iniciar_And()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
}

void Inf_OpAnd()
{
    TamToken++;
    token[TamToken] = caracter;
    NroToken = OP_AND;
}

/* NOT ---------------------------------------------------------------------- */
void Inf_not()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_NOT;
}

/* PARENTESIS --------------------------------------------------------------- */
void Inf_OpParAbre()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_PABRE;
}

void Inf_OpParCierra()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_PCIERRA;
}

/* LLAVE -------------------------------------------------------------------- */
void Inf_OpLLAbre()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_LLABRE;
}

void Inf_OpLLCierra()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_LLCIERRA;
}

/* CORCHETES ---------------------------------------------------------------- */
void Inf_OpCorchAbre()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_CABRE;
}

void Inf_OpCorchCierra()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_CCIERRA;
}

/* OPERADOR DECLARACION DE TIPO DE VARIABLE --------------------------------- */
void Inf_OpTipo()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_TIPO;
}

/* SEPARADOR DE UNA LISTA DE VARIALBLES O TIPOS ----------------------------- */
void Inf_SepLista()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = SEP_LISTA;
}

/* GUION ----------------------------- */
void Inf_Guion()
{
    limpiarToken();
    TamToken = 0;
    token[TamToken] = caracter;
    NroToken = OP_GUION;
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
/*E0*/    {Iniciar_concat, Iniciar_Com,    Inf_OpProducto, Inf_OpDivision, Iniciar_ID,     Iniciar_Cte,    Iniciar_Igual,  Iniciar_Dist,   Iniciar_MayorIgual, Iniciar_And,    Iniciar_Or,     Inf_not,        Inciar_CteStr,  Iniciar_Cte_Float, Inf_OpCorchAbre, Inf_OpCorchCierra, Inf_OpLLAbre,   Inf_OpLLCierra, Inf_OpParAbre,  Inf_OpParCierra, Inf_SepLista,   Inf_Guion,      Inf_Sep,        Nada,           Nada,           Nada,           Inf_OpTipo},
/*E1*/
          {Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Agregar_ID,     Agregar_ID,     Inf_ID,         Inf_ID,         Inf_ID,             Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,            Inf_ID,          Inf_ID,            Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,          Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID,         Inf_ID},
/*E2*/
          {Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Agregar_Cte,    Inf_Cte,        Inf_Cte,        Inf_Cte,            Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Iniciar_Cte_Float, Inf_Cte,         Inf_Cte,           Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,         Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte},
/*E3*/
          {Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Agregar_Cte,    Inf_Cte,        Inf_Cte,        Inf_Cte,            Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Caract_No_Val,     Inf_Cte,         Inf_Cte,           Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,         Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte,        Inf_Cte},
/*E4*/
          {Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_com,        Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,        Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,       Inf_OpResta,     Inf_OpResta,       Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,     Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta,    Inf_OpResta},
/*E5*/
          {Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,        Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,       Agregar_Com,     Agregar_Com,       Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,     Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com},
/*E6*/
          {Agregar_Com,    Fin_Com,        Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,        Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,       Agregar_Com,     Agregar_Com,       Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,     Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com,    Agregar_Com},
/*E7*/
          {Inf_OpConcat,   Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,         Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,        Inf_OpSuma,      Inf_OpSuma,        Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,      Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma,     Inf_OpSuma},
/*E8*/
          {Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Igual,      Inf_Asignacion, Inf_Asignacion,     Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion,    Inf_Asignacion,  Inf_Asignacion,    Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion,  Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion, Inf_Asignacion},
/*E9*/
          {Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_MenorIgual, Inf_Menor,      Inf_Distinto,       Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,         Inf_Menor,       Inf_Menor,         Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,       Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor,      Inf_Menor},
/*E10*/
          {Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,      Inf_OpAnd,      Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,     Caract_No_Val,   Caract_No_Val,     Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,   Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val},
/*E11*/
          {Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,      Caract_No_Val,  Inf_OpOr,       Caract_No_Val,  Caract_No_Val,  Caract_No_Val,     Caract_No_Val,   Caract_No_Val,     Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,   Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val},
/*E12*/
          {Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_MayorIgual, Inf_Mayor,      Inf_Mayor,          Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,         Inf_Mayor,       Inf_Mayor,         Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,       Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor,      Inf_Mayor},
/*E13*/
          {Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr,     Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Inf_CteStr,     Agregar_CteStr,    Agregar_CteStr,  Agregar_CteStr,    Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr,  Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Agregar_CteStr, Caract_No_Val,  Caract_No_Val},
/*E14*/
          {Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,      Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,     Caract_No_Val,   Caract_No_Val,     Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,   Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val},
/*E15*/
          {Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,      Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,     Caract_No_Val,   Caract_No_Val,     Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,   Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val,  Caract_No_Val}
        };

//MATRIZ ESTADOS
static int nEstado[16][27] =
        {
//        0 |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  | 10  | 11  | 12  | 13  | 14  | 15  | 16  | 17  | 18 |  19  | 20  | 21  | 22  | 23  | 24  |  25 |  26 |
//        + |  -  |  *  |  /  | Let | Dig |  =  |  <  |  >  |  &  |  |  |  !  |  "  |  .  |  [  |  ]  |  {  |  }  | (  |   )  |  ,  |  _  |  ;  | tab | blan|  ent|   : |
/*E0*/ {7,  4,  15, 15, 1,  2,  8,  9,  12, 10, 11, 15, 13, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 0,  0,  0,  15},
/*E1*/
       {15, 15, 15, 15, 1,  1,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E2*/
       {15, 15, 15, 15, 15, 2,  15, 15, 15, 15, 15, 15, 15, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E3*/
       {15, 15, 15, 15, 15, 3,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E4*/
       {15, 15, 15, 5,  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E5*/
       {5,  5,  5,  6,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5},
/*E6*/
       {5,  0,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5},
/*E7*/
       {15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E8*/
       {15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E9*/
       {15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E10*/
       {14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14},
/*E11*/
       {14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14},
/*E12*/
       {15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
/*E13*/
       {13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 15, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13},
/*E14*/
       {14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14},
/*E15*/
       {14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14}
        };

/* -------------------------------------------------------------------------- */
/* limpiarToken(): Limpia buffer de tokens                                    */
/* -------------------------------------------------------------------------- */
void limpiarToken()
{
    int i;
    for ( i = 0; i <= MAXLONG; i++ )
        token[i] = '\0';
}

/* -------------------------------------------------------------------------- */
/* leerCaracter(): Lee un caracter del archivo                                */
/* -------------------------------------------------------------------------- */
void leerCaracter()
{
    caracter = fgetc( input );
}

/* -------------------------------------------------------------------------- */
/* mostrarToken(): Muestra el token por pantalla y lo guarda en tabla tokens  */
/* -------------------------------------------------------------------------- */
void mostrarToken()
{
    switch ( NroToken )
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

    fprintf( tokens, "[ %s ] \n", token );
}

/* -------------------------------------------------------------------------- */
/* leerColumna(): Retorna la columna que corresponde al caracter ingresado    */
/* -------------------------------------------------------------------------- */
int leerColumna( char caracter )
{
    //LETRAS
    if ( caracter <= 'z' && caracter >= 'a' )
        return 4;
    if ( caracter <= 'Z' && caracter >= 'A' )
        return 4;

    //DIGITOS
    if ( caracter >= '0' && caracter <= '9' )
        return 5;

    //OTROS CARACTERES
    switch ( caracter )
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

    //Cualquier otro caracter es ignorado
    if ( cteStrAbierta == 0 && comAbierto == 0 )
    {
        printf( "\n ERROR: Caracter no reconocido: '%c'. \n", caracter );
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
/* insertarTOS(): Inserta en la TOS o si ya existe devuelve la posicion       */
/* -------------------------------------------------------------------------- */
int insertarTOS()
{
    int i, j, x = 0;
    int ii = 0;
    char aux[100];
    char auxStr[100];

    if ( NroToken == CTE_STRING )
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


    for ( i = 0; i < TOStop; i++ )
    {
        if ( NroToken == ID )
        {
            if ( strcmp( TOS[i].nombre, token ) == 0 )
                return i;
        }
        else if ( NroToken == CTE_STRING )
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

    switch ( NroToken )
    {
        case ID:
            strcat( aux, token );
            strcpy( TOS[TOStop].nombre, token );
            strcpy( TOS[TOStop].tipo, "ID" );
            TOStop++;
            break;
        case CTE_ENT:
            strcpy( aux, "_" );
            strcat( aux, token );
            strcpy( TOS[TOStop].nombre, aux );
            strcpy( TOS[TOStop].tipo, "CTE_ENT" );
            strcpy( TOS[TOStop].valor, token );
            TOStop++;
            break;
        case CTE_REAL:
            strcpy( aux, "_" );
            strcat( aux, token );
            strcpy( TOS[TOStop].nombre, aux );
            strcpy( TOS[TOStop].tipo, "CTE_REAL" );
            strcpy( TOS[TOStop].valor, token );
            TOStop++;
            break;
        case CTE_STRING:
            strcpy( aux, "_" );
            strcat( aux, auxStr );
            strcpy( TOS[TOStop].nombre, aux );
            strcpy( TOS[TOStop].tipo, "CTE_STRING" );
            strcpy( TOS[TOStop].valor, auxStr );
            TOS[TOStop].longitud = (strlen( auxStr ));
            TOStop++;
            break;
    }

    return TOStop - 1;
}

void mostrarTOS()
{
    int i;

    //printf("\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n");
    fprintf( tos, "\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n" );

    //printf ("Nro\t | Nombre\t\t\t | Tipo\t | Valor\n");
    fprintf( tos, "Nro\t | Nombre\t\t\t | Tipo\t | Valor\t | Longitud \n" );
    for ( i = 0; i < TOStop; i++ )
    {
        //  printf ("%d     \t | %s     \t\t\t | %s     \t | %s \n",i,TOS[i].nombre, TOS[i].tipo, TOS[i].valor);
        fprintf( tos, "%d     \t | %s     \t\t\t | %s     \t | %s \t | %d \n", i, TOS[i].nombre, TOS[i].tipo,
                 TOS[i].valor, TOS[i].longitud );
    }
    //printf("\n--------------------------------------------------------------------------------\n");
    fprintf( tos, "\n------------------------------ TABLA DE  SIMBOLOS ------------------------------\n" );
}

/* -------------------------------------------------------------------------- */
/* esPalabraReservada(): Varifica si un ID es una palabra reservada           */
/* -------------------------------------------------------------------------- */
int esPalabraReservada()
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
/* agregarPalabrasReservadas(): Agrega las Palabras reservadas a la Tabla de S*/
/* -------------------------------------------------------------------------- */
void agregarPalabrasReservadas() //19
{
    TOStop = 0;
    strcpy( TOS[TOStop].nombre, "MAIN" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "VAR" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "AS" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "ENDVAR" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "IF" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "THEN" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "ELSE" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "FI" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "FOR" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "TO" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "STEP" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "ROF" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "DO" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "WHILE" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "WPRINT" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "FILTERC" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "INTEGER" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "FLOAT" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;

    strcpy( TOS[TOStop].nombre, "STRING" );
    strcpy( TOS[TOStop].tipo, "PR" );
    TOStop++;
}

void Validaciones()
{
    if ( comAbierto != 0 )
    {
        printf( "\n ERROR: COMENTARIO no cerrado correctamente (no balancea). \n" );
        error = 1;
    }

    if ( cteStrAbierta != 0 )
    {
        printf( "\n ERROR: CTE STRING no cerrada correctamente (no balancea). \n" );
        error = 1;
    }

    if ((strcmp( token, "&" ) == 0) || (strcmp( token, "|" ) == 0))
    {
        printf( "\n ERROR: Se esperaba %s \n", token );
        exit( 1 );
    }

    if ( NroToken == CTE_ENT || NroToken == CTE_REAL )
    {
        Inf_Cte();
    }
}

/* -------------------------------------------------------------------------- */
/*                               FUNCION YYLEX                                */
/* -------------------------------------------------------------------------- */
int yylex() //FUNCION  QUE LEE HASTA FINAL DE TOKEN O EOF
{
    int estado = 0;
    int columna;

    leerCaracter();

    if ( caracter == EOF)
    {
        NroToken = EOF;
        return NroToken;
    }

    while ( estado != ESTADO_FINAL )
    {
        columna = leerColumna( caracter );

        //Ejecuto la funcion de la matriz
        (*proceso[estado][columna])();

        //Luego cambio de estado
        estado = nEstado[estado][columna];

        if ( estado != ESTADO_FINAL )
        {
            leerCaracter();

            if ( caracter == EOF)
            {
                Validaciones();

                if ( NroToken == ID && error == 0 )
                    Inf_ID();

                if ( estado == 0 )
                    return EOF;

                return NroToken;
            }
        }
    }

    return NroToken;
}

/**
 * Creates a file with the tokens for the corresponding input
 */
void analizeToFile( char * fileToAnalize )
{

    agregarPalabrasReservadas();

    if ((input = fopen( fileToAnalize, "r" )) == NULL)
    {
        printf( "No se puede abrir el archivo de entrada" );
        getch();
        exit( 1 );
    }


    if ((tokens = fopen( "tokens.txt", "w" )) == NULL)
    {
        printf( "No se puede crear el archivo de tokens" );
        getch();
        exit( 1 );
    }

    // Go to the end of the filw writing the tokens

    while ( feof( input ) == 0 )
    {
        if ( yylex() != EOF)
        {
            if ( error == 0 )
                mostrarToken();
        }
    }


    if ( fclose( input ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de entrada" );
        getch();
        exit( 1 );
    }

    if ( fclose( tokens ) != 0 )
    {
        printf( "No se puede CERRAR el archivo de tokens" );
        getch();
        exit( 1 );
    }

    if ( error == 0 )
    {
        printf( "\n - Analisis Lexico COMPLETO - \n" );

        if ((tos = fopen( "tos.txt", "w" )) == NULL)
        {
            printf( "No se puede crear el archivo de la tabla de TOS" );
            getch();
            exit( 1 );
        }

        mostrarTOS();

        if ( fclose( tos ) != 0 )
        {
            printf( "No se puede CERRAR el archivo de la tabla de tos" );
            getch();
            exit( 1 );
        }
    }

    if ( error == 1 )
        printf( "\n - Analisis Lexico completo con ERRORES - \n" );
}

%{
#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>




char Version[]="V1.22";


#define FILAS 21
#define COL 30

#define EST_FIN 20

#define LARGO_TOK 31

#define LIM_CTE 65535 // Ver cual es el limite mas adecuado..

#define CANTPALRSV 15

#define CANTVAR 200


%}

%token OP_MENOS
%token OP_MULT
%token OP_DIV
%token SEP_DECIMAL
%token LETRA
%token OP_ASIGN
%token OP_DIST
%token OP_MEN_IG
%token OP_MENOR
%token OP_MAYOR
%token OP_MAY_IG
%token OP_OR
%token OP_AND
%token CORCH_A
%token CORCH_C
%token PAR_A
%token PAR_C
%token LLA_A
%token LLA_C
%token PTO_Y_COMA
%token COMA
%token COM
%token COMILLA_S
%token DIG
%token DOS_PTOS
%token OP_COMP
%token CTE_STR
%token ID
%token CTE_REAL
%token ERROR
%token REAL
%token IF
%token ENDIF
%token ELSE
%token OP_NOT
%token INLIST
%token RENAME
%token TRUNC
%token INT
%token CTE_INT
%token OP_CONCATENA
%token WHILE
%token ENDWHILE
%token ROUND
%token DEFINE
%token ENDDEFINE
%token STRING
%token PRINT
%token OP_MAS


%start programa

%%

programa: bloquedecl sentencias {
						Ind_pgm = crearTerceto(TIPO_TERCETO_2,"END",-1,-1); 
						GrabaArchivoBinarioTs();
						fileTercetoBinToText();
						fileIntermediaToAssembler();

						}
	| sentencias	        {
						Ind_pgm = crearTerceto(TIPO_TERCETO_2,"END",-1,-1);
						GrabaArchivoBinarioTs();
						fileTercetoBinToText();
						fileIntermediaToAssembler();

						}
	;

bloquedecl: DEFINE declaraciones ENDDEFINE 
          ;

sentencias: sentencias sentencia
          | sentencia
          ;

sentencia: IF condicions sentencias {
							modificarTerceto(desapilar(pilaPos), 2); 
							Ind_if = crearTerceto(TIPO_TERCETO_5,"JMP",-1,-1);
							apilar (pilaPos,Ind_if);
						}
						ELSE sentencias ENDIF  {
							modificarTerceto(desapilar(pilaPos), 1);
							desapilar(pilaCond);
						}
	| IF condicions sentencias ENDIF		{
							modificarTerceto(desapilar(pilaPos), 1);
							desapilar(pilaCond);
						}
	| IF condicionc sentencias {
							modificarTerceto(desapilar(pilaPos), 2); 
							Ind_if = crearTerceto(TIPO_TERCETO_5,"JMP",-1,-1);
							apilar (pilaPos,Ind_if);
						}
						ELSE sentencias ENDIF  {
							modificarTerceto(desapilar(pilaPos), 1);
							desapilar(pilaCond);
						}
	| IF condicionc sentencias ENDIF	  {
							modificarTerceto(desapilar(pilaPos), 1);
							desapilar(pilaCond);
						}
	| WHILE condicions {desapilar(pilaExp);} sentencias ENDWHILE     { Ind_While = crearTerceto(TIPO_TERCETO_5,"JMP",desapilar(pilaCond),-1);
                                                     modificarTerceto(desapilar(pilaPos), 1); }

	| WHILE condicionc {desapilar(pilaExp);} sentencias ENDWHILE     { Ind_While = crearTerceto(TIPO_TERCETO_5,"JMP",desapilar(pilaCond),-1);
                                                     modificarTerceto(desapilar(pilaPos), 1); }
              
	| RENAME PAR_A I COMA I PAR_C  { renombrar($3, $5);
						}
	| asignacion
	| output	                                         
	; 

condicions: comp_Li	
	  ;

condicionc: comp_Li OP_AND comp_Ld { desapilar(pilaPos);
				     desapilar(pilaPos);
				     Ind_cond=crearTerceto(TIPO_TERCETO_4,"AND",Ind_compLi,Ind_compLd);
				     Ind_cond=crearTerceto(TIPO_TERCETO_4,"JZ",Ind_cond,-1);
				     apilar(pilaPos,Ind_cond);
				     desapilar(pilaExp);
				     desapilar(pilaExp);
				    }
	
          | comp_Li OP_OR comp_Ld  { desapilar(pilaPos);
				     desapilar(pilaPos);
				     Ind_cond=crearTerceto(TIPO_TERCETO_4,"OR",Ind_compLi,Ind_compLd);
				     Ind_cond=crearTerceto(TIPO_TERCETO_4,"JZ",Ind_cond,-1);
				     apilar(pilaPos,Ind_cond);
				     desapilar(pilaExp);
				     desapilar(pilaExp);
				    }	
	  ;

comp_Li: condicion {Ind_compLi=Ind_comp;
                    Ind_cond=crearTerceto(TIPO_TERCETO_4,opcomp,Ind_comp,-1);
	            apilar(pilaPos,Ind_cond);
	            apilar(pilaCond,Ind_condLi);	
		   }
       ;

comp_Ld: condicion {Ind_compLd=Ind_comp;
                    Ind_cond=crearTerceto(TIPO_TERCETO_4,opcomp,Ind_comp,-1);
	            apilar(pilaPos,Ind_cond);
		   }
       ;

condicion: cond_Li opercomp cond_Ld {Ind_comp=crearTerceto(TIPO_TERCETO_4,"CMP",Ind_condLi,Ind_condLd);
				    }

	 | INLIST PAR_A I COMA CORCH_A listactes CORCH_C PAR_C  { finlist($3);	 						
	 	}
	 ;

cond_Li: expresion {Ind_condLi=Ind_exp;
		   }
       ;

cond_Ld: expresion {Ind_condLd=Ind_exp;
		   }
       ;


declaraciones: declaraciones declaracion  
             | declaracion 
	     ;

declaracion: tipodato DOS_PTOS listaID {int i; 
					for(i=0;i<posi_tipo;i++)
					  strcpy(Tabla_Sim[variables_tipo[i]].tipo,tipo_dato);
					posi_tipo=0;}						 	
	   ;

asignacion: I OP_ASIGN expresion	{Ind_asig = crearTerceto(TIPO_TERCETO_3,":=",$1,Ind_exp); 
				         agregarTipoATerceto(Ind_asig, verificarTipo('A', buscarTipo($1), Ind_exp_tipo)); 
				         Ind_asig_tipo = ts_Operacion[buscarTipo($1)][Ind_exp_tipo];
					 }

          | asignacionmult              
                
          ;

asignacionmult: I OP_ASIGN asignacion  {Ind_asignacionmult = crearTerceto(TIPO_TERCETO_3,":=",$1,Ind_exp);
								agregarTipoATerceto(Ind_asig, verificarTipo('A', buscarTipo($1), Ind_exp_tipo)); 
				        Ind_asig_tipo = ts_Operacion[buscarTipo($1)][Ind_exp_tipo];
                agregarTipoATerceto(Ind_asignacionmult, verificarTipo('A', buscarTipo($1), Ind_exp_tipo));
								Ind_asig_tipo = ts_Operacion[buscarTipo($1)][Ind_exp_tipo];
								crearTerceto(TIPO_TERCETO_2,"free",$1,-1);
				        }
	      ;


expresion: expresion OP_MAS termino {Ind_exp=crearTerceto(TIPO_TERCETO_4,"ADD",desapilar(pilaExp),Ind_ter);
				     agregarTipoATerceto(Ind_exp,verificarTipo('+',Ind_exp_tipo,Ind_ter_tipo));
				     Ind_exp_tipo=ts_Operacion[Ind_exp_tipo][Ind_ter_tipo];
				     apilar(pilaExp, Ind_exp);
				     }

	 				| expresion OP_MENOS termino { Ind_exp=crearTerceto(TIPO_TERCETO_4,"SUB",desapilar(pilaExp),Ind_ter);
				        agregarTipoATerceto(Ind_exp,verificarTipo('-',Ind_exp_tipo,Ind_ter_tipo));
				        Ind_exp_tipo=ts_Operacion[Ind_exp_tipo][Ind_ter_tipo];
				        apilar(pilaExp, Ind_exp);
				      													}
	 				| termino {Ind_exp = Ind_ter; 
		    		Ind_exp_tipo = Ind_ter_tipo;
		    		apilar(pilaExp, Ind_exp);			
                    }	
	 ;


termino: termino OP_MULT factor {Ind_ter=crearTerceto(TIPO_TERCETO_4,"MUL",Ind_ter,Ind_fact);
				 agregarTipoATerceto(Ind_ter,verificarTipo('*',Ind_ter_tipo,Ind_fact_tipo));
				 Ind_ter_tipo=ts_Operacion[Ind_ter_tipo][Ind_fact_tipo];
				}

       | termino OP_DIV factor  {Ind_ter=crearTerceto(TIPO_TERCETO_4,"DIV",Ind_ter,Ind_fact);
				 agregarTipoATerceto(Ind_ter,verificarTipo('/',Ind_ter_tipo,Ind_fact_tipo));
				 Ind_ter_tipo=ts_Operacion[Ind_ter_tipo][Ind_fact_tipo];				 
				}  
       | factor	{Ind_ter=Ind_fact;
		 Ind_ter_tipo=Ind_fact_tipo;
		 }
       ;

factor: I { $$=$1;
	    Ind_fact=crearTerceto(TIPO_TERCETO_1,"",$1,-1);
	    Ind_fact_tipo=buscarTipo($1);
	   }	 
 
      | constante {Ind_fact=crearTerceto(TIPO_TERCETO_1,"",$1,-1);
	           Ind_fact_tipo=buscarTipo($1);
		   }   

      | PAR_A expresion PAR_C {Ind_fact=Ind_exp;
			       Ind_fact_tipo=Ind_exp_tipo;						
				}	

      | ROUND PAR_A I PAR_C    {Ind_fact = crearTerceto(TIPO_TERCETO_2,"round",$3,-1);
                                 Ind_fact_tipo= verificarTipo('*',TIPO_REAL,buscarTipo($3));      }	

      | TRUNC PAR_A I PAR_C    {Ind_fact = crearTerceto(TIPO_TERCETO_2,"trunc",$3,-1);
                                 Ind_fact_tipo= verificarTipo('*',TIPO_REAL,buscarTipo($3));     }	
      ;

opercomp: OP_COMP       {strcpy(opcomp,"JNE");}
	| OP_DIST	{strcpy(opcomp,"JE");}
	| OP_MAYOR	{strcpy(opcomp,"JBE");}
	| OP_MENOR	{strcpy(opcomp,"JNBE");}
	| OP_MEN_IG	{strcpy(opcomp,"JNB");}
	| OP_MAY_IG	{strcpy(opcomp,"JB");}
	;

listaID: I {variables_tipo[posi_tipo]=$1;
	    posi_tipo++;
	    }
       | listaID COMA I {variables_tipo[posi_tipo]=$3;
         		 posi_tipo++;
	                 }
	;

tipodato: REAL {strcpy(tipo_dato,"REAL");}
    	| INT {strcpy(tipo_dato,"INT");}
    	| STRING {strcpy(tipo_dato,"STRING");}
    	;

listactes: constante { apilar(pilaCte, $1); }
	 | listactes COMA constante { apilar(pilaCte, $3); }
	 ;

output: PRINT PAR_A CS PAR_C {Ind_out = crearTerceto(TIPO_TERCETO_2,"output",$3,-1);}	
      | PRINT PAR_A I PAR_C  {Ind_out = crearTerceto(TIPO_TERCETO_2,"output",$3,-1);}   
      | PRINT PAR_A C PAR_C  {Ind_out = crearTerceto(TIPO_TERCETO_2,"output",$3,-1);}	
      | PRINT PAR_A CE PAR_C {Ind_out = crearTerceto(TIPO_TERCETO_2,"output",$3,-1);}	
      ;


I: ID
 ;


constante: C  
         | CE 
         | CS
         ;

C: CTE_REAL	
 ;

CE: CTE_INT 
  ;

CS: CTE_STR	
  ;


%%


	/*Estructura de la tabla de simbolos:*/
typedef struct {
	char nombre[LARGO_TOK+1];	/*Tiene un caracter mas para un '_' que puede llevar adelante*/
	char tipo[15];
	char valor[LARGO_TOK];
	char longitud[5];
	char alias[LARGO_TOK+1];
	} Fila_TS;

Fila_TS Tabla_Sim[CANTVAR];


struct tpila *pilaPos;
struct tpila *pilaCond;
struct tpila *pilaExp;
struct tpila *pilaCte;

int tam_tabla=0;	/*Me dice el tamanio de la tabla de simbolos (cant de filas ocupadas).*/

char tipo_dato[15];

int variables_tipo[50];

int posi_tipo=0;


int buscar_en_tabla(char nom_aux[LARGO_TOK]);
int agrega_en_tabla(char nom_aux[LARGO_TOK]);
void mostrar_TS(void);
void limpiaAux(Fila_TS *);
FILE * openFile(char *,char *);


int MatrTrans[FILAS][COL];
void llenar_matriz(void);
int yylex(void); // devuelve entero de define
int yyerror(char *);
int dime_evento(char);
int primTok=1;
int leer(char*);
int esRsv();	/*Funcion que indica si el tipo de token recibido es palabra reservada.*/
void GrabaArchivoBinarioTs();

char *palabrasRsv[CANTPALRSV] = {"DEFINE", "ENDDEFINE", "REAL",
	"PRINT", "IF", "ENDIF", "ELSE", "WHILE", "ENDWHILE", "RENAME", "INLIST", "TRUNC", "ROUND", "INT", "STRING"};
	
int iPalabraRsv[CANTPALRSV] = {DEFINE, ENDDEFINE, REAL, PRINT, IF, ENDIF, ELSE, WHILE, ENDWHILE, RENAME, INLIST, TRUNC, ROUND, INT, STRING};

/*NOTA: Si se agrega una palabra reservada recordar modificar el fefine de cantPalRsv*/

int yylval;		/*Posicion del ultimo token en la tabla de simbolos*/




FILE *entra, *sale, *TS;
char arch[21];
char token[LARGO_TOK];
char c;	/*Caracter leido.*/
int tipotoken=0;
int tipotoken_aux=0;
int est=0;	/*est es el estado actual en el automata finito*/


/*Identificadores*/
void Inic_id(void);
void Cont_id(void);
void Fin_id(void);

/*Constantes*/
void Inic_cte(void);
void Cont_cte(void);
void Fin_cte_real(void);
void Fin_cte_int(void);
void Sep_decimal(void);

/*Constantes string*/
void Inic_cte_str(void);
void Cont_cte_str(void);
void Fin_cte_str(void);

/*Operadores aritmeticos*/
void Op_suma(void);
void Op_resta(void);
void Op_mul(void);
void Op_div(void);
void Op_concatena(void);

void Error(void);
void Nada(void);

/*Asignacion*/
void Inic_asig(void);
void Dos_ptos(void);
void Op_asig(void);

/*Comentarios*/
void Inic_com(void);
void Cont_com(void);
void Fin_com(void);

/*Operador de comparacion*/
void Inic_comp(void);
void Op_comp(void);

/*Operador distinto*/
void Inic_dist(void);
void Op_dist(void);

void Inic_menor(void);
void Op_menor(void);
void Op_men_ig(void);

void Inic_mayor(void);
void Op_mayor(void);
void Op_may_ig(void);

void Inic_or(void);
void Op_or(void);

void Inic_and(void);
void Op_and(void);

void Op_not(void);

void Corch_a(void);
void Corch_c(void);

void Par_a(void);
void Par_c(void);

void Lla_a(void);
void Lla_c(void);

void Pto_coma(void);
void Coma(void);
void Comilla_s(void);





/*Matriz de punteros a funciones semanticas*/
void (*proc_ptr[FILAS][COL])(void) = {
/* [+,-,*,/,alpha,digito,.,:,=,!,<,>,|,&,[,],(,),{,},",;,,,#,_,@,%,espacio,\n,\t] */
{Op_suma,Op_resta,Op_mul,Inic_com,Inic_id,Inic_cte,Sep_decimal,Inic_asig,Inic_comp,Inic_dist,Inic_menor,Inic_mayor,Inic_or,Inic_and,Corch_a,Corch_c,Par_a,Par_c,Lla_a,Lla_c,Inic_cte_str,Pto_coma,Coma,Error,Error,Op_concatena,Error,Nada,Nada,Nada},
{Fin_id,Fin_id,Fin_id,Fin_id,Cont_id,Cont_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Cont_id,Cont_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id},
{Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Cont_cte,Sep_decimal,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int,Fin_cte_int},
{Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Cont_cte,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real},
{Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Cont_com,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div,Op_div},
{Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com},
{Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com},
{Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com},
{Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com},
{Cont_com,Cont_com,Cont_com,Fin_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com,Cont_com},
{Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Op_asig,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos,Dos_ptos},
{Error,Error,Error,Error,Error,Error,Error,Error,Op_comp,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
{Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_men_ig,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor,Op_menor},
{Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Op_and,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
{Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Op_or,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
{Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_dist,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not,Op_not},
{Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_may_ig,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor,Op_mayor},
{Error,Error,Error,Error,Inic_cte_str,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Inic_cte_str,Inic_cte_str,Inic_cte_str,Inic_cte_str,Error,Error,Error},
{Error,Error,Error,Error,Cont_cte_str,Cont_cte_str,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Fin_cte_str,Error,Error,Cont_cte_str,Cont_cte_str,Cont_cte_str,Cont_cte_str,Cont_cte_str,Error,Error},
{Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
{Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error}};

#define TIPO_ENTERO 0
#define TIPO_REAL 1
#define TIPO_STRING 2
#define ERROR_TIPO 3

int Ind_out=0;
int Ind_comp=0;
int Ind_compLi=0;
int Ind_compLd=0;
int Ind_exp=0;
int Ind_condLi=0;
int Ind_condLd=0;
int Ind_cond=0;
int Ind_fact=0;
int Ind_ter=0;
int Ind_fact_tipo=0;
int Ind_exp_tipo=0;
int Ind_ter_tipo=0;
int Ind_asig=0;
int Ind_asig_tipo=0;
int Ind_if=0;
int Ind_pgm=0;
int Ind_While=0;
int Ind_asignacionmult=0;
int Ind_concatena=0;
int Ind_opeconca=0;
int Ind_opeconca_tipo=0;


char opcomp[5];

int crearPilas();
void renombrar(int, int);
void finlist(int);

#include "pila.h"
#include "terceto.h"
#include "ttipos.h"
#include "assembler.h"




int main(void)
{

clrscr();
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

printf("Analizador Lexico %s Copyleft 2011\n\n", Version);
printf("Desarrolladores:\n\t-Eduardo Palau\n\t-Diego Estrella\n\t-Ariel Bachiller\n\n\n");


printf("Escriba el nombre del archivo de entrada: ");
scanf("%s", arch);
printf("Abriendo: %s...\n\n", arch);


	/*Apertura de archivo de entrada:*/
entra= fopen(arch, "r");
if( !entra )
	{
	printf("Error al abrir el archivo!\n");
	getch();
	exit(-1);
	}
printf("Carga exitosa!\n\n");



	/*Creacion archivo de salida.*/
sale=fopen("tokens.txt", "w");
if( !sale )
	{
	printf("Error al crear el archivo de salida!\n");
	getch();
	exit(-2);
	}


llenar_matriz();

crearPilas();

cargarTablaSintesis();

yyparse();

/*while( !feof(entra) )
	{
	yyparse();
	}
*/


fclose(sale);
fclose(entra);
getch();
mostrar_TS();


printf("Se ha creado un archivo con los tokens.\n Presione una tecla para terminar...");
getch();


return 0;
}/*fin main()*/







/*dime_evento: me dice el numero de columna de la matriz del autómata.*/
int dime_evento(char car)
{
int colu=-1;

	/*Comparacion del caracter de entrada*/
switch(car)
	{
	case '+': colu=0; break;
	case '-': colu=1; break;
	case '*': colu=2; break;
	case '/': colu=3; break;
	case '.': colu=6; break;
	case ':': colu=7; break;
	case '=': colu=8; break;
	case '!': colu=9; break;
	case '<': colu=10; break;
	case '>': colu=11; break;
	case '|': colu=12; break;
	case '&': colu=13; break;
	case '[': colu=14; break;
	case ']': colu=15; break;
	case '(': colu=16; break;
	case ')': colu=17; break;
	case '{': colu=18; break;
	case '}': colu=19; break;
	case '\"': colu=20; break;
	case ';': colu=21; break;
	case ',': colu=22; break;
	case '#': colu=23; break;
	case '_': colu=24; break;
	case '@': colu=25; break;
	case '%': colu=26; break;
	case ' ': colu=27; break;
	case '\n' : colu=28; break;
	case '\t': colu=29; break;
	default:
		/*Es letra o numero?*/
	if( isalpha(c) )
		colu=4;
	else
		if( isdigit(c) )
			colu=5;
		else
			{
			printf("\nError! Caracter no reconocido (por el analizador lexico).\n");
			getch();
			exit(-9);
			}/*fin else(isdigit(c))*/

      }/*fin switch(c)*/


return colu;
}	/*fin dime_evento(char)*/



int crearPilas()
{
    if ((crearPila(&pilaPos)) == -1) 
	{
		printf("error al crear la pila \n");
	    	system("PAUSE");
    		return -1;
	}
	if ((crearPila(&pilaExp)) == -1) 
	{
		printf("error al crear la pila \n");
	    	system("PAUSE");
    		return -1;
	}
	if ((crearPila(&pilaCte)) == -1) 
	{
		printf("error al crear la pila \n");
	    	system("PAUSE");
    		return -1;
	}
	if ((crearPila(&pilaCond)) == -1) 
	{
		printf("error al crear la pila \n");
	    	system("PAUSE");
    		return -1;
	}
   return 0;
}

void renombrar(int viejo, int nuevo)
{
	if ( strcmp(Tabla_Sim[viejo].alias, "") ==0)
	{
		if ( strcmp(Tabla_Sim[nuevo].tipo, "ND") ==0)
		{
			strcpy(Tabla_Sim[viejo].alias, Tabla_Sim[nuevo].nombre);
		}
		else
		{
			printf("Error al Renombrar: el nombre %s ya esta siendo utilizado\n",Tabla_Sim[nuevo].alias);
			getch();
			exit(1);
		}			
	}	
	else
	{
		printf("Error al Renombrar: %s ya tiene alias o es un alias utilizado\n",Tabla_Sim[viejo].alias);
		getch();
		exit(1);
	}

}

void finlist(int pid)
{
	if( (strcmp(Tabla_Sim[pid].tipo, "INT") ==0) || (strcmp(Tabla_Sim[pid].tipo, "REAL") ==0) )
		{
			Ind_condLi=crearTerceto(TIPO_TERCETO_1,"",pid,-1);
			Ind_condLd=crearTerceto(TIPO_TERCETO_1,"",desapilar(pilaCte),-1);
			Ind_comp=crearTerceto(TIPO_TERCETO_4,"CMP",Ind_condLi,Ind_condLd);
			Ind_cond=crearTerceto(TIPO_TERCETO_4,"JE",Ind_comp,-1);
			apilar(pilaPos,Ind_cond);
	    apilar(pilaCond,Ind_condLi);	
			while(!vacia(pilaCte))
			{
				Ind_condLi=crearTerceto(TIPO_TERCETO_1,"",pid,-1);
				Ind_condLd=crearTerceto(TIPO_TERCETO_1,"",desapilar(pilaCte),-1);
				Ind_comp=crearTerceto(TIPO_TERCETO_4,"CMP",Ind_condLi,Ind_condLd);
				Ind_cond=crearTerceto(TIPO_TERCETO_4,"JE",Ind_comp,-1);
				apilar(pilaPos,Ind_cond);
			}
			while(!vacia(pilaPos))
				modificarTerceto(desapilar(pilaPos), 1);
			strcpy(opcomp,"JNE");
			Ind_condLi=desapilar(pilaCond);
		}
	else
		{
			printf("Error en Inlist: El Id %s no es numerico\n",Tabla_Sim[pid].nombre);
			getch();
			exit(1);
		}
}

/*Graba la TS a un archvo binario, que sera usado en todas las etapas
*de la compilacion
*/
void GrabaArchivoBinarioTs()
{
     FILE * tsBin = openFile("TS_bin.txt","wb");
     int k;
     for(k=0;k<tam_tabla;k++)
         fwrite(&Tabla_Sim[k],sizeof(Fila_TS),1,tsBin);
     fclose(tsBin);
}


void limpiaAux(Fila_TS *aux)
{
strcpy(aux->nombre,"");
strcpy(aux->tipo,"");
strcpy(aux->valor,"");
strcpy(aux->longitud,"");
strcpy(aux->alias,"");

}



FILE* openFile(char *fileName, char *mode)
{
     FILE* file = fopen(fileName, mode);
     if (file == NULL)
     {
          printf( "No se puede abrir el archivo %s.\n", fileName);
          exit( 1 );
     }
     return file;
}





int yylex(void)
{
int columna;

tipotoken_aux=-34;

c= (char)getc(entra);

/*printf("a ver q lei....  %c\n", c);*/


est= 0;
strncpy(token,"", LARGO_TOK);	/*"limpio" la variable*/

while( est != EST_FIN  && !feof(entra) )
	{
	columna= dime_evento(c); /*obtengo la columna de la matriz*/
	(*proc_ptr[est][columna])(); //me dice la función semantica
	est = MatrTrans[est][columna]; //recorre matriz de estados y devuelve nuevo estado
	c= (char)getc(entra);
	}

if( feof(entra) )
	{
	if( tipotoken_aux==ERROR ) // siempre inicio tipotoken_aux == ERROR solo cuando es ID
		{
		printf("Fin de archivo de prueba inesperado.\n");
		printf("Presione una tecla para terminar...\n");
		getch();
		return -1; //exit(ERROR)
		}

	else
		{
		/*if(tipotoken_aux==0)
			tipotoken_aux=-34;

		else*/
			//printf("\n Su archivo de prueba ha finalizado\n");
		}

	}/*Fin if(feof(entra))*/

ungetc(c, entra);



/*Si se leyo algo, lo guardo en sale*/
if( strlen(token)>0 )
	{
	//Si no es el primer token, pongo una ',' adelante..
	if(primTok!=1)
		fprintf(sale, ",");
	primTok=0;

	if( esRsv() )
		fprintf(sale, "< rsv: %s >", token);
	else
		if(tipotoken_aux==ID)
			fprintf(sale, "< id: %s >", token);
		else
			fprintf(sale, "< %s >", token);

	}


return(tipotoken_aux);
}








		     /******Rutinas semanticas******/


/***************************** Manejo de id ***********************************/

void Inic_id(void)	/*Inicializa el token con el ultimo caracter leido */
{
char c_aux[2];

tipotoken_aux=ERROR;

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);

return;
}


void Cont_id(void)	/*Agrega el ultimo caracter leido a token */
{
char c_aux[2];

/*if( strlen(token) >= (LARGO_TOK-1) )
	{
	printf("Error! Longitud de token mayor a lo permitido (%s)", LARGO_TOK);
	getch();
	exit(-10);
	}*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);

return;
}



void Fin_id(void)
{
	


if(strlen(token) >= (LARGO_TOK-1) )
	{
	  printf("Error! Longitud de token mayor a lo permitido, limite maximo 31");
	  getch();
	  exit(-10);
	}


/*Veo si el id es una palabra reservada*/

if( (tipotoken_aux=esRsv()) ==0 )
	{
	tipotoken_aux=ID;
	if( buscar_en_tabla(token)==1 )
		{
		/*printf("Ya estaba en TS:\n");*/
		}
	else
		{
		agrega_en_tabla(token);
		}
	}


ungetc(c, entra);
return;
}
/*verifica si es reservada
Si es Palabra Reservada ? retorna (tipotoken = RSV)
sino (es identificador)
si no esta en Tabla de Simbolos ? agrega Token en tabla de simbolos
si esta en Tabla de Simbolos ? yylval := posicion en TS
retorna (tipotoken = ID)*/


/***************************** Manejo de cte **********************************/

void Inic_cte(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);

return;}
/*agrega digito a Token
cte = cte* 10 + digito
verificar maximo*/

void Cont_cte(void)
{
char c_aux[2];

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);

return;}
/*agrega digito a Token
cte = cte* 10 + digito
verificar maximo*/


void Fin_cte_int(void)
{
float lim;
tipotoken_aux=CTE_INT;
//printf("Se reconocio una cte ..\n");

lim= atof(token);
if( lim>LIM_CTE )
	{
	printf("Error! Longitud de token (cte) mayor a lo permitido (%f)", LIM_CTE);
	getch();
	exit(-10);
	}


if(buscar_en_tabla(token))
	{
	/*printf("Ya estaba en TS:\n");*/
	}
else
	agrega_en_tabla(token);

ungetc(c, entra);
return;
}


void Fin_cte_real(void)
{
float lim;
tipotoken_aux=CTE_REAL;
//printf("Se reconocio una cte ..\n");

lim= atof(token);
if( lim>LIM_CTE )
	{
	printf("Error! Longitud de token (cte) mayor a lo permitido (%f)", LIM_CTE);
	getch();
	exit(-10);
	}


if(buscar_en_tabla(token))
	{
	/*printf("Ya estaba en TS:\n");*/
	}
else
	agrega_en_tabla(token);

ungetc(c, entra);
return;
}
/*si no esta en Tabla de Simbolos  agregar Token en tabla de simbolos
si esta en Tabla de Simbolos  yylval := posicion en TS
retorna (tipotoken = CTE)*/


void Sep_decimal(void) //Ver si el '.' va por separado..
{
char c_aux[2];

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);

/*token[0]=c;
token[1]='\0';
tipotoken_aux=SEP_DECIMAL;*/

//printf("Se reconocio un sep_decimal..\n");

return;
}
/******************************************************************************/

/******************************************************************************/

void Inic_com(void)	/*Pone una / en token.*/
{
char c_aux[2];

tipotoken_aux=ERROR;

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
return;
}

void Op_div(void)	/*token = / */
{
tipotoken_aux= OP_DIV;
ungetc(c, entra);

//printf("Se reconocio un op_div..\n");

return;
}

void Cont_com(void)
{
return;
}

void Fin_com(void)
{
//printf("Se reconocio un comentario..\n");

tipotoken_aux= COM;
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
return;
}

/******************************************************************************/

/****************************Manejo de asignacion******************************/

void Inic_asig(void)	 /*Pone : en token*/
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=':';
token[1]='\0';

return;
}

void Dos_ptos(void)
{
//printf("Se reconocio un dos_ptos..\n");

ungetc(c, entra);
tipotoken_aux= DOS_PTOS;
return;
}

void Op_asig(void)	/*Agrega caracter = a token*/
{
char c_aux[2];

c_aux[0]='=';
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux= OP_ASIGN;

//printf("Se reconocio un op_asig..\n");

return;
}


/******************************************************************************/

/***************************Operadores aritmeticos*****************************/

void Op_suma(void)	/*token = + */
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=c;
token[1]='\0';

tipotoken_aux = OP_MAS;

//printf("Se reconocio un op_suma..\n");

return;
}

void Op_resta(void)	/*token = - */
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=c;
token[1]='\0';

tipotoken_aux = OP_MENOS;

//printf("Se reconocio un op_resta..\n");

return;
}

void Op_mul(void)	/*Token = * */
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=c;
token[1]='\0';

tipotoken_aux = OP_MULT;

//printf("Se reconocio un op_mult..\n");

return;
}

void Op_concatena(void)    /* concatena sring con @*/
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=c;
token[1]='\0';

tipotoken_aux = OP_CONCATENA;

//printf("Se reconocio un op_mult..\n");

return;
}



/******************************************************************************/

/*********************Manejo del operador de comparacion***********************/
void Inic_comp(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

token[0]=c;
token[1]='\0';
return;
}


void Op_comp(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux = OP_COMP;
/*ungetc(c, entra);*/

//printf("Se reconocio un op_comp..\n");

return;
}

/******************************************************************************/

/*******************Manejo de operadores de desigualdad************************/

void Inic_dist(void)	/*Pongo un ! en token*/
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
return;
}


void Op_dist(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux=OP_DIST;

//printf("Se reconocio un op_dist..\n");

return;
}


void Inic_menor(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
return;
}


void Op_menor(void)
{
tipotoken_aux=OP_MENOR;
ungetc(c, entra);

//printf("Se reconocio un op_menor..\n");

return;
}


void Op_men_ig(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux=OP_MEN_IG;

//printf("Se reconocio un op_men_ig..\n");

return;
}


void Inic_mayor(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
return;
}


void Op_mayor(void)
{
tipotoken_aux=OP_MAYOR;
ungetc(c, entra);

//printf("Se reconocio un op_mayor..\n");

return;
}

void Op_may_ig(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux=OP_MAY_IG;

//printf("Se reconocio un op_may_ig..\n");

return;
}

/******************************************************************************/

/**********************Manejo de operadores logicos****************************/

void Inic_or(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
return;
}

void Op_or(void)
{char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux,1);
tipotoken_aux=OP_OR;

//printf("Se reconocio un op_or..\n");

return;
}


void Inic_and(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
return;
}


void Op_and(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strcpy(token, "&&");
tipotoken_aux=OP_AND;

//printf("Se reconocio un op_and..\n");

return;
}


void Op_not(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=OP_NOT;

//printf("Se reconocio un op_not..\n");

return;
}



/******************************************************************************/

/******************************************************************************/

void Corch_a(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=CORCH_A;

//printf("Se reconocio un corch_a..\n");

return;
}


void Corch_c(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=CORCH_C;

//printf("Se reconocio un corch_c..\n");

return;
}


void Par_a(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=PAR_A;

//printf("Se reconocio un par_a..\n");

return;
}


void Par_c(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=PAR_C;

//printf("Se reconocio un par_c..\n");

return;
}


void Lla_a(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=LLA_A;

//printf("Se reconocio una llar_a..\n");

return;
}


void Lla_c(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=LLA_C;

//printf("Se reconocio una llar_c..\n");

return;
}

/******************************************************************************/

/************************Manejo de constante string****************************/

void Inic_cte_str(void)
{
char c_aux[2];

strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux, 1);
return;
}


void Cont_cte_str(void)
{
char c_aux[2];

if( strlen(token) >= (LARGO_TOK-1) )
	{
	printf("Error! Longitud de token mayor a lo permitido (%s)", LARGO_TOK);
	getch();
	exit(-10);
	}

c_aux[0]=c;
c_aux[1]='\0';

strncat(token, c_aux, 1);
return;
}


void Fin_cte_str(void)
{
tipotoken_aux=CTE_STR;
if(buscar_en_tabla(token))
	{
	/*printf("Ya estaba en TS:\n");*/
	}
else
	agrega_en_tabla(token);

//printf("Se reconocio una cte_str..\n");

return;
}

/******************************************************************************/

/******************************************************************************/

void Pto_coma(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=PTO_Y_COMA;

//printf("Se reconocio un pto_coma..\n");

return;
}


void Coma(void)
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=COMA;

//printf("Se reconocio una coma..\n");

return;
}


void Comilla_s(void)		/*Ver si agregamos comilla simple...*/
{
strncpy(token, "", LARGO_TOK);	/*"limpio" la variable*/
token[0]=c;
token[1]='\0';
tipotoken_aux=COMILLA_S;
return;
}






void Error(void)
{
printf("Adios mundo cruel! (E19)\n");		/*Mensaje de prueba*/
getch();
exit(-8);
/*tipotoken_aux=ERROR;*/
return;
}

void Nada(void)	/*NOP*/
{
return;
}





void llenar_matriz(void)
{
/*Tabla del automata finito*/

int MT2[FILAS][COL]= {
/* [+,-,*,/,alpha,digito,.,:,=,!,<,>,|,&,[,],(,),{,},",;,,,#,_,@,%,espacio,\n,\t] */
{20,20,20,4,1,2,3,10,11,15,12,16,14,13,20,20,20,20,20,20,17,20,20,19,19,20,19,0,0,0},
{20,20,20,20,1,1,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,1,1,20,20,20,20,20},
{20,20,20,20,20,2,3,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{20,20,20,20,20,3,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{20,20,20,20,20,20,20,20,20,5,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{5,5,5,6,5,5,5,5,5,9,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5},
{5,5,5,6,5,5,5,5,5,7,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5},
{7,7,7,7,7,7,7,7,7,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7},
{7,7,7,5,7,7,7,7,7,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7},
{5,5,5,0,5,5,5,5,5,9,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5},
{20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{19,19,19,19,19,19,19,19,20,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
{20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{19,19,19,19,19,19,19,19,19,19,19,19,19,20,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
{19,19,19,19,19,19,19,19,19,19,19,19,20,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
{20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20},
{19,19,19,19,18,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,18,18,18,18,19,19,19},
{19,19,19,19,18,18,19,19,19,19,19,19,19,19,19,19,19,19,19,19,20,19,19,18,18,18,18,18,19,19},
{19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19},
{19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19}};

int it, it2;
for(it=0; it<FILAS; it++)
	for(it2=0; it2<COL; it2++)
		MatrTrans[it][it2]= MT2[it][it2];
}	/*fin llenar_matriz()*/


/******************************************************************************/
/******************************************************************************/

int esRsv()	/*Esta funcion devuelve un numero si es reservada, sino devuelve un 0.*/
{
int i;
//Si es reservada:

for(i=0; i<CANTPALRSV; i++)
	if( strcmp(token, palabrasRsv[i]) == 0 )
		return iPalabraRsv[i];

return 0;
}


/******************************************************************************/
/******************************************************************************/

	/*Funcion que busca un token en la Tabla de Simbolos*/
int buscar_en_tabla(char nom_aux[LARGO_TOK])
{
int it;
char cad_aux[LARGO_TOK+1];

strncpy(cad_aux, "", (LARGO_TOK+1));	/*"limpio" la variable*/

if( tipotoken_aux==CTE_STR || tipotoken_aux==CTE_REAL || tipotoken_aux==CTE_INT)
	strncpy(cad_aux, "_\0", LARGO_TOK+1);	/*Pongo un '_' en el nombre de la variable*/


strcat(cad_aux, nom_aux);


for(it=0; it<tam_tabla; it++ )
	{
	if( strcmp(cad_aux, Tabla_Sim[it].alias)==0 )
		{
		yylval=it;
		return 1;
		}
	if( strcmp(cad_aux, Tabla_Sim[it].nombre)==0 )
		if( strcmp(Tabla_Sim[it].alias, "")==0 )
			{
			yylval=it;
			return 1;
			}
		else
			{
			printf("\n Error de validacion - La Variable %s ya no existe\n",Tabla_Sim[it].nombre);
			printf("\n En su lugar utilizar la variable %s\n",Tabla_Sim[it].alias);
			getch();
			exit(1);
			}
	}

yylval=-1;

return 0;
}


/******************************************************************************/

	/*Funcion que agrega una entrada en la tabla de simbolos, y devuelve
		su posicion en la misma.*/
int agrega_en_tabla(char nom_aux[LARGO_TOK])
{
char cad_aux[LARGO_TOK+1];

/*FILE *yylvalue;
yylvalue=fopen("yylvalue.txt", "a+");*/

if(tam_tabla==(CANTVAR-1))	/*Si se llega al tamaño maximo de posiciones de la tabla:*/
	{
	printf("\nSe lleno la tabla de simbolos!!\n");
	printf("\nPresione una tecla para terminar...");
	getch();
	exit(-6);
	}

strncpy(cad_aux, "", (LARGO_TOK+1));	/*"limpio" la variable*/
/*Lleno el resto con nada para no mostrar basura luego.*/
strcpy(Tabla_Sim[tam_tabla].valor, "");
strcpy(Tabla_Sim[tam_tabla].longitud, "");
strcpy(Tabla_Sim[tam_tabla].alias, "");


if( tipotoken_aux==CTE_STR)
	{
	strncpy(cad_aux, "_", LARGO_TOK+1);	/*Pongo un '_' en el nombre de la variable*/
	strcpy (Tabla_Sim[tam_tabla].tipo,"CteString");/*Copio el tipo en la TS*/
	itoa(strlen(token), Tabla_Sim[tam_tabla].longitud, 10); /*Completo la longitud para las cadenas en TS*/
	}


if( tipotoken_aux==CTE_REAL)
	{
	strncpy(cad_aux, "_", LARGO_TOK+1);	/*Pongo un '_' en el nombre de la variable*/
	strcpy (Tabla_Sim[tam_tabla].tipo,"CteReal");	/*Copio el tipo en la TS*/
	}

if( tipotoken_aux==CTE_INT)
	{
	strncpy(cad_aux, "_", LARGO_TOK+1);	/*Pongo un '_' en el nombre de la variable*/
	strcpy (Tabla_Sim[tam_tabla].tipo,"Cteint");	/*Copio el tipo en la TS*/
	}

if( tipotoken_aux==ID)
	{
	strcpy (Tabla_Sim[tam_tabla].tipo,"ND");	/*Copio el tipo en la TS*/
	}

/* if(tipotoken_aux==RENAME) //  Validar si ya existe en TS el nombre original y el alias.
	{
	strcpy (Tabla_Sim[tam_tabla].Rename,Alias_aux); //aca va el nombre del alias.
        }
*/

strcat(cad_aux, nom_aux);
strcpy(Tabla_Sim[tam_tabla].nombre, cad_aux); 	/*Copio el nombre en la TS*/


switch( tipotoken_aux )
	{
	case CTE_STR:
		strcpy(Tabla_Sim[tam_tabla].valor, nom_aux);
		break;
	case CTE_REAL:
	case CTE_INT:

		strcpy(Tabla_Sim[tam_tabla].valor, nom_aux);
		break;
	}


yylval=tam_tabla;
/*fprintf(yylvalue, "%d\n", yylval);
fclose(yylvalue);*/

tam_tabla++;

/*printf("Se agrego a la TS: %s\n",Tabla_Sim[tam_tabla-1].nombre);*/

return (tam_tabla-1);
}



void mostrar_TS(void)
{
int i, j;	// Iteradores.

	/*Creacion archivo de salida para la TS.*/
TS=fopen("TS.txt", "w");
if( !TS )
	{
	printf("Error al crear el archivo de salida!\n");
	getch();
	exit(-22);
	}

clrscr();
fflush(stdin);
printf("\tTabla de Simbolos:");
fprintf(TS, "\tTABLA DE SIMBOLOS:\n\n");
fprintf(TS, "NOMBRE       |     TIPO      |      VALOR      |   LONGITUD    |    ALIAS   \t \t \t \n\n");
    

for(i=0; i<tam_tabla; i++)
	{
	
	gotoxy(1, 3+i);
	printf("%s",Tabla_Sim[i].nombre);
	
	gotoxy(LARGO_TOK, 3+i);
	printf("%s",Tabla_Sim[i].tipo);
	
	gotoxy(LARGO_TOK+10, 3+i);
	printf("%s",Tabla_Sim[i].valor);
	
	gotoxy(LARGO_TOK*2, 3+i);
	printf("%s",Tabla_Sim[i].longitud);
        
	gotoxy(LARGO_TOK*3, 3+i);
	printf("%s",Tabla_Sim[i].alias);



	fprintf(TS, "%s", Tabla_Sim[i].nombre);
	for(j=strlen(Tabla_Sim[i].nombre); j<=20; j++)
		{
		fprintf(TS, " ");
		}
	
	
	fprintf(TS, "%s", Tabla_Sim[i].tipo);
	for(j=strlen(Tabla_Sim[i].tipo); j<=15; j++)
		{
		fprintf(TS, " ");
		}
	
	fprintf(TS, "%s", Tabla_Sim[i].valor);
	for(j=strlen(Tabla_Sim[i].valor); j<=15; j++)
		{
		fprintf(TS, " ");
		}
	
	fprintf(TS, "%s", Tabla_Sim[i].longitud);
        for(j=strlen(Tabla_Sim[i].longitud); j<=15; j++)
		{
		fprintf(TS, " ");
		}
	
        fprintf(TS, "%s\n", Tabla_Sim[i].alias);
	}

printf("\n\n");

fclose(TS);
return;
}



int yyerror(char *a)
{
 fprintf(stderr, "yyerror: %s\n",a);
 return 0;
}




/******************************************************************************/
/******************************************************************************/
/*******************************************************************************
		       Codigos de ERRORES ( en exit() )


-1:	Error al abrir el archivo de entrada.
-2:	Error al crear el archivo de salida.
-22:	Error al crear el archivo de salida de la TS.
-6:	Se lleno la Tabla de Simbolos.
-8:	Combinacion de caracteres no validos.
-9:	Caracter no reconocido por el automata.
-10:	Maxima longitud de token superada.
ERROR:	Error no especificado (hasta el momentode debe a un fin de archivo inesperado).
-34	[REVISAR!](fin de archivo)
******************************************************************************/
/******************************************************************************/

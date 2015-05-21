#include <stdio.h>

 
typedef struct
{
    int v[200];
    int top;
} Stack;

void push(Stack *S, int val);
int pop(Stack *S);
void init(Stack *S);
int full(Stack *S);
void stack_print(Stack *S);

void push(Stack *S, int val)
{
    S->v[ S->top ] = val; 
   (S->top)++;    
/*  Equivalent to: S->v[ (S->top)++ ] = val;   */
}

int pop(Stack *S)
{
    (S->top)--;
    return (S->v[S->top]);
/*  Equivalent to: return (S->v[--(S->top)]);  */
}

void init(Stack *S)
{
    S->top = 0;
}

int full(Stack *S)
{
    return (S->top >= 20);
}

void stack_print(Stack *S)
{
    int i;
    if (S->top == 0)
       printf("Stack is empty.\n");
    else
    {
       printf("Stack contents: ");
       for (i=0;i<S->top;i++)
       {
          printf("%d  ",S->v[i]); 
       }
       printf("\n");
    }
}



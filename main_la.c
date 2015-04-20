#include "la/la.h"

/* -------------------------------------------------------------------------- */
/*                                      MAIN                                  */
/* -------------------------------------------------------------------------- */

void main(int argc, char* argv[])
{
    if (argc > 1)
    {
       analizeToFile(argv[1]);
    }
    else
    {
        analizeToFile("pruebagral.txt");
    }
}


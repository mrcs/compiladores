%{
	#ifdef WIN32 
	#include "y_tab.h"
	#else
	#include "y.tab.h"
	#endif
	#define MAXCLUBE 20
	
	int yylval;
	
	char *clube[MAXCLUBE] = {	"Corinthians-SP", "Gr�mio-RS", "Santos-SP", "Vit�ria-BA",
								"Santo Andr�-SP", "Fluminense-RJ", "Coritiba-PR", "Barueri-SP",
								"Internacional-RS", "Atl�tico-PR", "Flamengo-RJ", "S�o Paulo-SP",
								"Goi�s-GO", "Sport-PE", "N�utico-PE", "Palmeiras-SP", "Atl�tico-MG",
								"Cruzeiro-MG", "Botafogo-RJ", "Ava�-SC"};
%}
palavra [^\t\n]+
time {palavra}"-"[A-Z][A-Z]


%%
[0-9]+	{
			//printf("inteiro\n");
				yylval = atoi(yytext);
				return INTEIRO;
			
		}
RODADA	{	
		//printf("rodada\n");
		return RODADA;
		}

[:/"x"]	{
				//printf("louco\n");
				
					return *yytext;
			}
{time}		{	
				int i;
				for(i=0;i<20;i++)
					if(strcmp(yytext,clube[i])==0){
						yylval = i;
						break;
					}
				return TIME;
			}
.			;

%%

int yywrap(){
	return 1;
}

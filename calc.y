%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include <time.h>
	#define MAXJOGOS 380
	#define MAXCLUBE 20
	#define COLTABELAO 9
	#define random() xor128()
	
	#ifdef WIN32 
	#define CLEAR system("cls")
	#else
	#define CLEAR system("clear")
	#endif
	
	#define MAXCLUBE 20
	extern FILE *yyin;
	int tabelao[MAXJOGOS][COLTABELAO];
	int indiceRodada=0,indiceJogo=0,rodadaAtual=0;
	char *clubes[MAXCLUBE] = {	"Corinthians-SP", "Grêmio-RS", "Santos-SP", "Vitória-BA",
								"Santo André-SP", "Fluminense-RJ", "Coritiba-PR", "Barueri-SP",
								"Internacional-RS", "Atlético-PR", "Flamengo-RJ", "São Paulo-SP",
								"Goiás-GO", "Sport-PE", "Náutico-PE", "Palmeiras-SP", "Atlético-MG",
								"Cruzeiro-MG", "Botafogo-RJ", "Avaí-SC"};
%}
%token INTEIRO TIME RODADA
%%
rodada:
	jogo rodada
	|INTEIRO RODADA rodada				
	|fim
	|
	; 

fim: INTEIRO INTEIRO
	
jogo:
	data hora time placar time	{	tabelao[indiceJogo][0]=(indiceJogo/10)+1;
									tabelao[indiceJogo][5]=$3;
									tabelao[indiceJogo][6]=$5;
									indiceJogo++;	}
	;

data:
	INTEIRO'/'INTEIRO		{	tabelao[indiceJogo][1]=$1;
								tabelao[indiceJogo][2]=$3;	}
	;

hora:
	INTEIRO':'INTEIRO		{	tabelao[indiceJogo][3]=$1;
								tabelao[indiceJogo][4]=$3;	}
	;
	
time:
	TIME					{$$=$1;}
	;

placar:
	INTEIRO'x'INTEIRO		{	tabelao[indiceJogo][7]=$1;
								tabelao[indiceJogo][8]=$3;
								if(++indiceRodada==10){
									rodadaAtual++;
									indiceRodada=0;
								}
							}
	|'x'					{	tabelao[indiceJogo][7]=-1;
								tabelao[indiceJogo][8]=-1;	}
	;
%%

int yyerror(char *s){
	fprintf(stderr,"%s\n",s);
	return 0;
}



static unsigned x, y, z, w;
__inline unsigned xor128(void) {
        unsigned t = x ^ (x << 11);
        x = y;
        y = z;
        z = w;
        return w = (w ^ (w >> 19)) ^ (t ^ (t >> 8));
}

void print(){
	int i,j;
	FILE *txt;
	txt = fopen("Arquivo.txt", "w");
	for(i=0;i<MAXJOGOS;i++){
		for(j=0;j<COLTABELAO;j++){
			fprintf(txt, "%d ",tabelao[i][j] );
		}
		fprintf(txt, "\n");
	}
	fclose(txt);
}

int compare(int v[][6], int i, int j) {
			// pontos						n de vitórias							saldo de gols
	if ((v[i][1] > v[j][1]) || ((v[i][1] == v[j][1]) && (v[i][2] > v[j][2])) || ((v[i][1] == v[j][1]) && (v[i][3] > v[j][3])))
		return 1; // i eh maior que j
	if ((v[i][1] < v[j][1]) || ((v[j][1] == v[i][1]) && (v[j][2] > v[i][2])) || ((v[j][1] == v[i][1]) && (v[j][3] > v[i][3])))
		return 0; // j eh maior que i
	return rand()%2; // sorteio
}

int *sort( int v[][6] ) {
	int *id = malloc(sizeof(int) * 20);
	int i,j;
	for (i = 0; i < 20; i++)
		id[i] = i;

	for (i = 0; i < 20; i++)
		for (j = 0; j < 20; j++)
			if (compare(v, id[i], id[j])) { 
				int swap = id[i];
				id[i] = id[j];
				id[j] = swap;
			} 	
	return id;
}

int compareClassificacao(int* v, int i, int j) {
	int a;
	for (a = 0; a < 20; a++)
		if (v[i + a*20] > v[j + a*20])
			return 1;
		else if (v[i + a*20] < v[j + a*20])
			return 0;
	return 1;
}

int *sortClassificacao(int* v) {
	int *times = malloc(sizeof(int) * 20);
	int i,j;
	for (i = 0; i < 20; i++) 
		times[i] = i;
	
	for (i = 0; i < 20; i++)
		for (j = 0; j < 20; j++)
			if (compareClassificacao(v, times[i], times[j])) { //se i for maior que j
				int swap = times[i];
				times[i] = times[j];
				times[j] = swap;
			} 	
	return times;
}

void setPlacar(int jogo, int golsMandante, int golsVisitante) {
	tabelao[jogo][7] = golsMandante; 
	tabelao[jogo][8] = golsVisitante; 
}

void geraClassificacao(int tabela[20][6], int atual){
	int i,j,codMandante,codVisitante;
	for(i=0;i<20;i++){
		for(j=0;j<6;j++)
			tabela[i][j]=0;
	}
	for(i=0;i<atual*10;i++){		
		codMandante = tabelao[i][5];
		codVisitante = tabelao[i][6];
		tabela[codMandante][4]+=tabelao[i][7]; // gols pro do mandante
		tabela[codVisitante][4]+=tabelao[i][8]; // gols pro do visitante
		tabela[codMandante][3]+=tabelao[i][7]; // saldo gols do mandante
		tabela[codVisitante][3]+=tabelao[i][8]; // saldo gols do visitante
		tabela[codMandante][3]-=tabelao[i][8]; // saldo de gols do mandante
		tabela[codVisitante][3]-=tabelao[i][7]; // saldo de gols do visitante
		
		if(tabelao[i][7]>tabelao[i][8]){
			tabela[codMandante][1]+=3;
			tabela[codMandante][2]+=1;
		}else if(tabelao[i][7]==tabelao[i][8]){
			tabela[codMandante][1]+=1;
			tabela[codVisitante][1]+=1;
		}else{
			tabela[codVisitante][1]+=3;
			tabela[codVisitante][2]+=1;
		}
	}
}

int compareMelhorCaso(int v[][6], int i, int j) {
	if ((v[i][1] > v[j][1]))
		return 1; // i eh maior que j
	if ((v[i][1] < v[j][1]))
		return 0;
	return -1;	
}

void geraMelhorPlacar(int time) {
	int rodada,i;
	for (rodada = rodadaAtual; rodada < 38; rodada++) {
		//printf("Rodada %d\n",rodada);
		int tabela[20][6];
		geraClassificacao(tabela, rodada);	
		for(i = rodada*10;i<rodada*10 + 10;i++)	{ 
			if (tabelao[i][5] == time)
				setPlacar(i,2,0);
			else if (tabelao[i][6] == time)	
				setPlacar(i,0,2);
			else {
				
				int anfitriao = compareMelhorCaso(tabela,tabelao[i][5],time);	// 1: anfitriao > time, 0: anfitriao < time, c.c: -1
				int visitante = compareMelhorCaso(tabela,tabelao[i][6],time);	// 1: visitante > time, 0: visitante < time, c.c: -1

				if (((anfitriao - visitante) == 0)||(anfitriao < 0)||(visitante < 0))	// se os dois são do mesmo 'tipo' ou algum é negativo
					setPlacar(i,0,0);
				else if (anfitriao)			// se é o anfitriao o maior, ele perde
					setPlacar(i,0,1);
				else
					setPlacar(i,1,0);		// cc, ele ganha.
			}
			//printf("placar %d x %d\n",tabelao[i][7],tabelao[i][8]);
		}
	}

}

void geraPlacar (int jogo) {
/*	TIMEA = 0;
	TIMEB = 1;
	EMPATE = 2;*/        
	int placar = random()%3;
	if (placar != 2) { // placar != EMPATE
		int golsdovencedor = random()%4 + 1; 		// no máximo 4
		int golsdoperdedor = random()%(golsdovencedor);	// no máximo (golsdovencedor - 1)
		tabelao[jogo][7 + placar] = golsdovencedor;
		tabelao[jogo][8 - placar] = golsdoperdedor;
	} else {
		int empate = random()%5;
		tabelao[jogo][7] = empate;
		tabelao[jogo][8] = empate;
	}
}

void randomize(int rodadaInicial) {
	int i;
	for(i = rodadaInicial*10; i < MAXJOGOS; i++)
		geraPlacar(i);
}

void classificacaoAtual(int rodada, char* msg){
	int j,k;
	int tabela[20][6];
	geraClassificacao(tabela, rodada);	
	int* id = sort(tabela);
	printf("Classificacao %s (ate rodada %d):\n",msg,rodada);
	printf("PS\tClube\t\t\tPG\tVI\tSG\tGP\tAP\n");
	for(k=0;k<20;k++){
		int i = id[k];
		tabela[i][5]=((tabela[i][1]*100)/(rodada*3));
		if(i==8)
			printf("%d\t%s\t",k+1,clubes[i]);
		else
			printf("%d\t%s\t\t",k+1,clubes[i]);
		for(j=1;j<6;j++) 
				printf("%d\t", tabela[i][j]);
		printf("\n");	
	}
	printf("\n");
}

void  melhorCaso() {
	int j;
	printf("TIMES: \n");
	for (j = 0; j < 20; j++)
		printf("%d -\t%s\n", j, clubes[j]);
	printf("\nEscolha: ");
	scanf("%d", &j);	
	geraMelhorPlacar(j);
	classificacaoAtual(38,clubes[j]);
}

void printer(int* times,int a, int b,int* classificacoes){
	int i, j;
	if (a!=0)
		printf("\t\t\t");
	for (j = a; j < b; j++)
		printf("\t%d", j+1);
	printf("\n");
	for (i = 0; i < 20; i++) {
		if(times[i]==8)
			printf("%d\t%s\t",i+1, clubes[times[i]]);	
		else
			printf("%d\t%s\t\t",i+1, clubes[times[i]]);
		for (j = a; j < b; j++)
			printf("%d\t", classificacoes[times[i] + 20*j]);
		printf("\n");	
	}
}

void imprimirSimulacao(int *classificacoes) {
	int *timesordenados = (int *) sortClassificacao(classificacoes);
	int i;
	printf("Frequencias na classificacao (absoluto)\n\nPS\tClube\t\t");
	printer(timesordenados,0,5,classificacoes);
	for(i = 5;i<16;i+=5){
		printf("\n(continuacao, posicoes %d a %d)\n",i+1,i+5);
		printer(timesordenados,i,i+5,classificacoes);
	}
	
	free(timesordenados);
}

int* simulacao (int n) {
	int j,i = 0;
	int *classificacoes = calloc(400, sizeof(int)); // 20 x 20, inicalizados.
	for (i = 0; i < n; i++) {
		randomize(rodadaAtual);
		int tabela[20][6];
		geraClassificacao(tabela, 38);
		int* id = sort(tabela);	
		for (j = 0; j < 20; j++)
			classificacoes[id[j] + j*20]++; // aka classificacoes[TIME][POSICAO]++;
	}
	return classificacoes;
}

void geraSemente(){
	srand (time(NULL) );
	x = rand();
	y = rand(); 
	z = rand();
	w = rand();
}

int main(int argc, char **argv){
	if(argc>1){
		FILE *file;
		file = fopen(argv[1],"r");
		if (file==NULL){
		   fprintf(stderr,"nao abriu %s \n", argv[1]);	
		   exit(1);
		}
	    yyin=file;
	} else {
        	return 0;
	}
	yyparse();
	geraSemente();
	int opcao;
	while(1){
		printf("\n\nOpcoes:\n1 - Classificacao Atual\n2 - Simulacao\n3 - Melhor caso\n\nEscolha: ");	
		scanf("%d",&opcao);
		CLEAR;
		switch(opcao){
			case 1:{
			//	CLEAR;
				classificacaoAtual(rodadaAtual,"");
			//	PAUSE;
				break;
			}
			case 2:{
			//	PAUSE;
				int* classificacoes = simulacao(1000000); // simulando 100000 vezes
				imprimirSimulacao(classificacoes);
			//	CLEAR;
				free(classificacoes);
				break;
			}
			case 3:{
			//	CLEAR;
				melhorCaso();
			//	PAUSE;
				break;
			}
			default:{
				return 0;
			}
		}
	}
}

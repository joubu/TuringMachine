%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "turing.h"

/* Utilisé pour le décalage */
#define GAUCHE 0
#define DROITE 1

/* TAMPON correspond au nombre de caractères qui seront affichés avant et après le caractère courant */
#define TAMPON 20

/* Macro déterminant l'indice du tableau en fonction de sa position sur la bande*/
#define ZN(k) ((k<0)?(-2*k-1):(2*k))

/* Détermine le nombre de caractères qui seront alloués/réalloués à la bande */
#define PASALLOC 128

extern int errno; 

/* Structure instruction composé d'un état initial, d'un symbole, une action et un état final */
typedef struct {
	char etat1[3];
	char symbole;
	char action;
	char etat2[3];
}instruction;

/* Variables globales pour le traitement lexical*/
int nbParcours = 1; // Nombre de fois que l'on parcourt les instructions
int nbInstr = 0; // Nombre d'instructions totales
int nb = 0; // Variable pour le second parcours

/* Tableau des instructions */
instruction *tabInstr;

/* Tableau de caractères simulant la bande */
char *bande;

/* Position courante */
int position = 0;

/* allocFin correspond au nombre de caractères alloués à la bande */
int allocFin = PASALLOC;

/* Booleen qui gère l'affichage pas à pas ou non */
int detail= 0;

/*************************************************/
/* Réallocation du tableau en cas de répassement */
/*************************************************/
void Realloc(){
	// On réalloue la bande de PASALLOC + 1 caractères suplémentaires
	bande = (char*)realloc(bande, (allocFin + PASALLOC + 1) * sizeof(char));

	// On initialise les cases crées à ' ' (=blancs)
	memset(&bande[allocFin], ' ', PASALLOC + 1);

	// On met à jour le nombre de caractères que peut contenir la bande
	allocFin = allocFin + PASALLOC;
}


/************************************************/
/* Initialisation de la bande avec des 'blancs' */
/************************************************/
void Init(char* chaine){
	int i;
	// Si le PASALLOC est trop petit, on réalloue de la plce
	while(2 * strlen(chaine) > allocFin){
		Realloc();
	}

	// Initialisation à ' '
	memset(bande, ' ', allocFin);

	// On initialise les cases (positives) de la bande avec la chaine passée en argument
	for (i = 0 ; i < strlen(chaine) ; i++){
		bande[ZN(i)]=chaine[i];
	}

	#ifdef _DEBUG
	for(i=0;i<allocFin;i++)printf("Ibande[%d]=%d\n",i,bande[i]);
	#endif
}


/***********************************************/
/* Liste les instructions qui seront exécutées */
/***********************************************/
void ListeInstr(){
	int i = 0;
	printf("***%d instructions vont être exécutées***\n",nbInstr);
	for (i = 0 ; i < nbInstr ; i++){
		printf("n°%d\t%s , %c , %c , %s\n", i, tabInstr[i].etat1, tabInstr[i].symbole, tabInstr[i].action, tabInstr[i].etat2);
	}
	printf("\n\n");
}


/**********************************************************************************/
/*       Test de la bande, vérifie si la chaine passée en paramètre :             */
/*    	$ est bien conforme à l'alphabet utilisé dans le fichier des instructions */
/*    	$ ne contient pas de caractères spéciaux '<' ou '>' 			  */
/**********************************************************************************/
int TestBande(char* chaine){

	int i = 0, j = 0; //indice de boucle

	//Booléen vérifiant l'existence des caractères dans l'alphabet
	unsigned short pasAlpha = 0;

	// On parcourt la chaine
	while (chaine[i]){
		pasAlpha = 1;

		// On vérifie que le caractère apparait au moins une fois dans une instruction
		for (j=0; j<nbInstr; j++){
			// Si le caractère est une caractère de déplacement, on retourne une erreur
			if ((chaine[i] == '<') || (chaine[i] == '>')){
				printf("Un symbole '<' ou '>' à été trouvé dans la chaine passée en paramètres\n");
				return 0;
			}

			if ((chaine[i] == tabInstr[j].symbole) || (chaine[i] == tabInstr[j].action)){
				pasAlpha = 0;
			}
		}

		// Si un caractère ne fait pas partie de l'alphabet, on retourne une erreur
		if (pasAlpha){
			printf("\tLe symbole '%c' passé en paramètre ne fait pas partie de l'alphabet !\n", chaine[i]);
			return 0;
		}
		i++;
	}

	// Si tout c'est bien déroulé, on initialise la chaine
	Init(chaine);
	return 1;
}


/*******************************************************************************/
/* Affichage de la bande en centrant par rapport à l'indice passé en paramètre */
/*******************************************************************************/
void AfficherBande(int indice){
	int i = 0;
	int debut = indice - TAMPON;
	int fin = indice + TAMPON;
	for (i = debut ; i <= fin ; i++){
		if (i == indice){
			printf("\033[1;32m\033[41m%c\033[0m", bande[ZN(i)]);
		}else{
			printf("\033[1;32m\033[44m%c\033[0m", bande[ZN(i)]);
		}
	}
	printf("\t\tposition =  **%d**  ",position);
	if (detail){
		printf("\033[1A");
	}
}


/********************************************************************************************************/
/* Mise à jour de la bande 										*/
/*	$ On réaffiche la bande par rapport à la position courante 					*/
/*	$ On attend le prochain appuis sur la touche 'Entrée' pour passer à l'instruction suivante 	*/
/********************************************************************************************************/
void MajBande(int indice){
	if (detail){
		AfficherBande(position);
	}
	char bidon;
	if (detail && scanf("%c",&bidon)){
			TraiterInstr(tabInstr[indice].etat2, bande[ZN(position)]);
	}else{
		TraiterInstr(tabInstr[indice].etat2, bande[ZN(position)]);
	}
}


/********************************************************************************/
/* Décalage de la tête de lecture vers la gauche (0) ou vers la droite (1)	*/
/********************************************************************************/
void Decalage(int indice, int sens){
	if (sens == 0){
		position --; // Décalage vers la gauche, on décrémente la position courante
	}else{
		position ++; // Décalage vers la droite, on incrémente la position courante
	}

	/* Si le nombre de caractères alloués à la bande ne suffit pas, on réalloue de PASALLOC caractères */
	if(ZN(position) + 2 * TAMPON >= allocFin){
		Realloc();
	}
	/* et on remet à jour la bande par rapport à l'indice */
	MajBande(indice);
}


/************************************************************************************************/
/* Recherche Dichotomique de la prochaine instruction en fonction de l'état et du symbole	*/
/************************************************************************************************/
int RechercheDicho(char* etat, char symbole, int debut, int fin){
	int milieu = 0, i = 0, trouve = 0;
	if (debut <= fin){
		milieu = (debut + fin) / 2;
		i = milieu;

		/* Si l'état et le symbole sont identiques, on a trouvé l'instruction correspondante */
		if ((strcmp(tabInstr[milieu].etat1, etat) == 0) && (tabInstr[milieu].symbole==symbole)){
			return milieu;
		} else {
			/* Si l'état recherché est > à l'état courant on relance la recherche sur la deuxième moitié */
			if (strcmp(tabInstr[milieu].etat1, etat) > 0){
				return RechercheDicho(etat, symbole, debut, milieu);
			/* S'il est <, on relance la recherche sur la première moitié */
			} else if (strcmp(tabInstr[milieu].etat1, etat) < 0){
				return RechercheDicho(etat, symbole, milieu + 1, fin);
			} else{ /* Sinon, si l'état correspond, on recherche le symbole correspondant */
				/* Si on est pas à la fin, que les états sont identiques et qu'on a pas trouvé le symbole correspondant, on passe au symbole suivant*/
				while((i <= fin) && (strcmp(tabInstr[i].etat1, etat) == 0) && (trouve == 0)){
					if (tabInstr[i].symbole==symbole){
						return trouve;
					} else {
						i++;
					}
				}
				/* Si on a pas trouvé le symbole après, il était avant, on relance donc la recherche sur la première partie */
				if (!trouve) {
					return RechercheDicho(etat, symbole, debut, milieu);
				} else {
					return -1;
				}
			}
		}
	}
	return (-1);
}


/***************************************************************************************/
/* Traitement de l'instruction en fonction de l'état et du symbole passés en paramètre */
/***************************************************************************************/
void TraiterInstr(char *etat, char symbole){
	int i = 0;

	// On recherche l'instruction qui correspond à l'état et au symbole
	//i = RechercheDicho(etat, symbole, 0, nbInstr);
	for (i = 0 ; i < nbInstr ; i++){
		if ((strcmp(tabInstr[i].etat1, etat) == 0) && (tabInstr[i].symbole == symbole)){

			// On décale à droite ou à gauche s'il s'agit d'un caractère de déplacement
			if (tabInstr[i].action == '<'){
				Decalage(i, GAUCHE);
				break;
			}else if (tabInstr[i].action == '>'){
				Decalage(i, DROITE);
				break;

			// Sinon il s'agit du remplacement d'une case de la bande, on met à jour la bande
			}else{

				bande[ZN(position)] = tabInstr[i].action;
				MajBande(i);
				break;
			}
		}
	}
}



%}

CHIFFRE		[0-9]
LETTRE		[a-zA-Z]
ETAT		{LETTRE}|{CHIFFRE}|{LETTRE}{LETTRE}|{LETTRE}{CHIFFRE}|{CHIFFRE}{LETTRE}|{CHIFFRE}{CHIFFRE}
DIRECTION	[<>]
BLANC		" "
ALPHABET 	[0-9a-zA-Z]
SEPARATEUR 	[,]
SYMBOLE 	{ALPHABET}|{BLANC}
ACTION 		{ALPHABET}|{BLANC}|{DIRECTION}
INSTRUCTION 	({ETAT}{SEPARATEUR}{SYMBOLE}{SEPARATEUR}{ACTION}{SEPARATEUR}{ETAT})

%%


{INSTRUCTION} {
	if (nbParcours == 1){
		nbInstr++;
	}else{
		sscanf(yytext,"%[^,],%[^,],%[^,],%[^,]", tabInstr[nb].etat1, &tabInstr[nb].symbole, &tabInstr[nb].action, tabInstr[nb].etat2);
		nb++;
	}
};

%%

int main(int argc, char* argv[]){
	if ((argc < 3) || (argc > 4))
		printf("Utilisation : ./turing nomFichier.tur \"alphabet\" [-p]\n");
	else{
		char* nomFic;
		nomFic = argv[1];
		if ((yyin = fopen(nomFic, "r")) != NULL){
			// Premier passage pour compter le nombre totale d'instructions
			yylex();
			nbParcours++;

			// Modification du curseur de position au debut de yyin
			if (fseek(yyin, 0, SEEK_SET) == 0){

				// Allocation dynamique du tableau qui contiendra les instructions
				tabInstr = (instruction*)malloc(nbInstr*sizeof(instruction));

				// Allocation dynamique du tableau de caractères représentant la bande
				bande = (char*)malloc(PASALLOC*sizeof(char));

				//Second passage pour initialiser le tableau d'instructions
				yylex();

				// Vidage du buffer yyin
				fclose(yyin);

				// Sauvegarde de l'état initial
				//strcpy(&(initInstr).etat1, tabInstr[0].etat1);
				// Tri rapide des instructions grâce à la fonction de comparaison strcmp
				//qsort(tabInstr, nbInstr, sizeof(instruction), strcmp);

				//Liste des instructions
				ListeInstr();

				// Test de la bande correspondant aux caractère passés en paramètre
				if (TestBande(argv[2])){
					if ((argc==4) && (strcmp(argv[3], "-p") == 0)){
						detail = 1;
					}
					// Affichage de la bande initiale
					printf("Bande initiale :\n");
					AfficherBande(0);
					printf("\n\n\n");
					if (detail){
						printf("Veuillez apppuyer sur la touche 'Entrée'\npour exécuter les instructions pas à pas\n\n");
					}
					char bidon;
					if (detail && scanf("%c",&bidon)){
						AfficherBande(0);
						printf("\n");
					}
					// On commence à traiter les instructions
					TraiterInstr(tabInstr[0].etat1, bande[0]);
					if (!detail){
						printf("Bande finale : \n");
						AfficherBande(position);
					}
					printf("\n\nFIN du traitement\n\n");
				}else{
					return 3;
				}
				free(tabInstr);
			}else{
				printf("Erreur, le flux yyin n'a pas été bien positionné !\nCode errno : %d\n", errno);
				perror("errno");
				return 2;
			}
		}else{
			printf("Erreur lors de l'ouverture du fichier %s !\nCode errno : %d\n",nomFic, errno);
			perror("errno");
			return 1;
		}
	}
		return 0;
}


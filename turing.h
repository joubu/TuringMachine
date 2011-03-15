/*  
    Copyright (C) Jonathan Druart
 
    This Program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; version 2
    of the License.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.
 
    You should have received a copy of the GNU Library General Public License
    along with this library; see the file licence.txt.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/ 
#ifndef _TURING
#define _TURING

// Initialisation de la bande avec des 'blancs'
void Init(char*);

// Test de la bande, vérifie si la chaine passée en paramètre 
//	$ est bien conforme à l'alphabet utilisé dans le fichier des instructions
//	$ ne contient pas de caractères spéciaux '<' ou '>'
int TestBande(char* chaine);

// Affichage de la bande en centrant par rapport à l'indice passé en paramètre
void AfficherBande(int);

// Mise à jour de la bande
//	$ On réaffiche la bande par rapport à la position courante
//	$ On attend le prochain appuis sur la touche 'Entrée' pour passer à l'instruction suivante
void MajBande(int);

// Décalage de la tête de lecture vers la gauche (0) ou vers la droite (1)
void Decalage(int, int);

// Traitement de l'instruction en fonction de l'état et du symbole passés en paramètre
void TraiterInstr(char*, char);

#endif

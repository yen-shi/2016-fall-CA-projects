####################################
# Author  		: Danny Wang 			 	 #
# Date 	  		: 2016 / 7 / 10 	 	 #
# Version 		: 1.0 						 	 #
# Description : Makefile for Latex #
####################################
# set ~/.latexmkrc with						 #
# 						 following two lines.#
# $pdf_mode=1; 										 #
# $pdf_previewer='evince %S &';    #
####################################

MAINFILE=template
OUTPUT=project1_team14

SRCPATH=./

VIEWER=evince

TEX=latexmk
TEXFLAG=-xelatex -pvc -pdf -synctex=0 -interaction=nonstopmode -use-make

TEXFILES=$(shell find ${SRCPATH} -name "*.tex")

all: ${OUTPUT}.pdf

${OUTPUT}.pdf: ${TEXFILES}
	${TEX} ${TEXFLAG} -jobname=${OUTPUT} ${MAINFILE}.tex

.PHONY: clean restart production restart rmpdf
.PRECIOUS: ${OUTPUT}.pdf

clean:
	latexmk -C ${OUTPUT}.fdb_latexmk

production:	
	latexmk -c ${OUTPUT}.fdb_latexmk

restart: rmpdf all

rmpdf:
		rm -f ${OUTPUT}.pdf

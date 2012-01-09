
# Makefile for project report generation

all: doc

doc: report_1 report_2 AI_brainstorming

AI_brainstorming: AI_brainstorming.tex
	latex AI_brainstorming.tex

report_1: report_1.tex
	latex report_1.tex

report_2: report_2_draft.tex
	latex report_2_draft.tex 

clean: 
	rm *.aux *.dvi *.log

# Final report

report_4: clean_r4 report4.tex report4.bib
	pdflatex report4 ; bibtex report4 ; pdflatex report4 ; pdflatex report4

clean_r4: 
	rm -f report4.pdf report4.aux report4.log report4.bbl report4.toc report4.dvi report4.blg

reportgui:
	pdflatex reportgui


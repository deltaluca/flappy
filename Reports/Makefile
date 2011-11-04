
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


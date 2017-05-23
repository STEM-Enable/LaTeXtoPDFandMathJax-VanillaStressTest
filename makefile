.PHONY: clean standard clear word web
#Change the name to the main tex file without the file extension.
NAME=LaTeXtoPDFandMathJax-VanillaStressTest
LATEX=pdflatex

#Note that we make clean as a prerequisite in each case as the toggles cause different setups. 
#Leaving the job output in the directory can cause issues in some cases. 
standard: clean
#Setting the LaTeX toggles to control how the document is created. 
	[ ! -f toggle.tex ] || rm -f toggle.tex
#In this example we have a SVG but need a PDF for the LaTeX to work with.
#	cd figures; ./svgtopdf.sh; cd ..
	echo "\\\\togglefalse{clearprint}\\\\togglefalse{web}" > toggle.tex
	$(LATEX) $(NAME).tex
	$(LATEX) $(NAME).tex
	$(LATEX) $(NAME).tex
#We can't change the jobname to get different filenames that way as this does not work with some packages
#we will need to use for graphics in this set up. 
	mv $(NAME).pdf built/$(NAME)-standard.pdf

#This will be the same except for the toggles and name.
clear: clean
	[ ! -f toggle.tex ] || rm -f toggle.tex
#	cd figures; ./svgtopdf.sh; cd ..
	echo "\\\\toggletrue{clearprint}\\\\togglefalse{web}" > toggle.tex
	$(LATEX) $(NAME).tex 
	$(LATEX) $(NAME).tex
	$(LATEX) $(NAME).tex
	mv $(NAME).pdf built/$(NAME)-clear.pdf

#We require some additional files for everything to work. 
web: clean mathml.4ht unicode.4hf groupmn.4xt mathjaxMMLWord.cfg additional.css
	[ ! -f toggle.tex ] || rm -f toggle.tex
	echo "\\\\togglefalse{clearprint}\\\\toggletrue{web}" > toggle.tex
#htlatex needs to run twice to prevent disruption to the sectioning tree caused by e.g. footnotes
#Note, yes this does run latex 6 times! It is a reported bug: https://puszcza.gnu.org.ua/bugs/index.php?197
	htlatex $(NAME).tex "mathjaxMMLWord.cfg,2,sections+,fonts-,early_,early^,charset=utf-8" " -cunihtf -utf8"
	htlatex $(NAME).tex "mathjaxMMLWord.cfg,2,sections+,fonts-,early_,early^,charset=utf-8" " -cunihtf -utf8"
#The postprocess is slow, required to produce numbers rather than digits when spoken aloud but requires correct
#html output. Such things as unmatched brackets can cause problems. If you can't locate the error and can put
#up with digits instead of numbers then comment out the next line as the web browser and mathjax are less fussy.
	./postprocess.sh
#Creating a zip for ease of upload or sending
	[ ! -d built/$(NAME)-web/ ] || rm -r built/$(NAME)-web/
	mkdir built/$(NAME)-web/
	mkdir built/$(NAME)-web/figures/
	cp *.html built/$(NAME)-web/
	cp *.css built/$(NAME)-web/
#	cp ./figures/*.svg built/$(NAME)-web/figures/
#We are testing the picture environment this time
	cp *.png built/$(NAME)-web/
	cd built; [ ! -f $(NAME)-web.zip ] || rm -f $(NAME)-web.zip; zip -r $(NAME)-web.zip $(NAME)-web; cd ..
#Create a pseudo home page for the github pages site
	cp built/$(NAME)-web/$(NAME).html built/$(NAME)-web/index.html
#Put copies of the PDFs and docx in the web space so they can be accessed
	cp built/$(NAME)-*.pdf built/$(NAME)-web/
	cp built/$(NAME).docx built/$(NAME)-web/

#To transform to Word we need to use the web transform but without breaking into sections and then use Pandoc 19+
word: clean mathml.4ht unicode.4hf groupmn.4xt mathjaxMMLWord.cfg additional.css
	[ ! -f toggle.tex ] || rm -f toggle.tex
	echo "\\\\togglefalse{clearprint}\\\\toggletrue{web}" > toggle.tex
#htlatex needs to run twice to prevent disruption to the sectioning tree caused by e.g. footnotes
#Note, yes this does run latex 6 times! It is a reported bug: https://puszcza.gnu.org.ua/bugs/index.php?197
#Note that we are not breaking into sections for the Word transform
#fn-in stops us from losing the footnotes in the Word format: https://tex.stackexchange.com/questions/195551/how-to-add-footnotes-in-htlatex-via-fn-in
	htlatex $(NAME).tex "mathjaxMMLWord.cfg,sections+,fonts-,fn-in,early_,early^,charset=utf-8" " -cunihtf -utf8"
	htlatex $(NAME).tex "mathjaxMMLWord.cfg,sections+,fonts-,fn-in,early_,early^,charset=utf-8" " -cunihtf -utf8"
#The postprocess is slow, required to produce numbers rather than digits when spoken aloud but requires correct
#html output. Such things as unmatched brackets can cause problems. If you can't locate the error and can put
#up with digits instead of numbers then comment out the next line as the web browser and mathjax are less fussy.
#We don't seem to need to postprocess to get correct reading in the docx. 
#However, this hasn't been tested extensively yet. 
#	./postprocess.sh
#To get styled theorems we are going to need to do something like http://pandoc.org/MANUAL.html#custom-styles-in-docx-output but this will require us to do some nasty poking.
	pandoc -s -f html -t docx $(NAME).html -o $(NAME).docx --reference-docx=reference.docx
	mv $(NAME).docx built/

clean:
	rm -f *.aux *.log *.toc *~ *.out *.html *.4ct *.4tc *.dvi *.idv *.tmp *.xref *.lg *.lof *.lot $(NAME).css $(NAME)*x.png $(NAME)-standard.pdf $(NAME)-clear.pdf

#cleanfigures: 
#	rm -f ./figures/*.pdf

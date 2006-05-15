# vim:ts=8 sw=4 noet:
#

TOP			:= .
include			$(TOP)/config.mk

PATH			:= $(PATH):$(TOP)/tools

INCLUDES		:= -I . 
OCAMLC_FLAGS		:= -g -dtypes $(INCLUDES)
OCAMLOPT_FLAGS		:= -p -dtypes $(INCLUDES)
OCAMLOPT_FLAGS		:=    -dtypes $(INCLUDES)

BINDIR 			:= $(PREFIX)/bin
MAN1DIR 		:= $(PREFIX)/man/man1

# -- high-level targets
.PHONY:	    all doc clean pdf test install clobber

all:	    load.ml $(NAME).$(BINEXT)
	    
clean:
	    rm -f *.cmx *.cmo *.cmi *.o *.ml *.mli quest.opt quest.byte
	    rm -f *.log *.pdf *.aux *.inc *.tex *.out
	    rm -f *.mll *.mly
	    rm -f DEPEND
	    rm -f load.ml *.annot
	    
clobber:    clean
	    rm -f $(NAME).byte $(NAME).opt
	    rm -f $(NAME).1
	    rm -f config.mk

install:    $(NAME).$(BINEXT) $(NAME).1 $(BINDIR) $(MAN1DIR)
	    cp $(NAME).$(BINEXT) $(BINDIR)/$(NAME)
	    cp $(NAME).1 	 $(MAN1DIR)

$(BINBDIR):
	    mkdir -p $@

$(MAN1DIR):
	    mkdir -p $@

	    
# -- important files

ML :=       \
	    intervalmap.ml 	\
	    annot.ml 		\
	    parser.ml	    	\
	    scanner.ml	    	\
	    main.ml 		\
	    

MLI :=      $(patsubst %.ml, %.mli, $(ML))
CMO :=      $(patsubst %.ml, %.cmo, $(ML))
CMX :=      $(patsubst %.ml, %.cmx, $(ML))
OBJ :=      $(patsubst %.ml, %.o  , $(ML))

TEX :=      $(patsubst %.ml, %.tex, $(ML))
INC :=      $(patsubst %.ml, %.inc, $(ML))
PDF :=      $(patsubst %.ml, %.pdf, $(ML))

# -- 

cmo:	$(CMO)
cmi:	$(CMI)
obj:	$(OBJ)

# --

LIBCMO :=	
LIBCMX :=	

# -- binaries

$(NAME).byte:	$(CMO) $(LIBCMO)
		$(OCAMLC) $(OCAMLC_FLAGS) -o $@ $(LIBCMO) $(CMO) 

$(NAME).opt:	$(CMX) $(LIBCMX)
		$(OCAMLOPT) $(OCAMLOPT_FLAGS) -o $@ $(LIBCMX) $(CMX) 

# -- debugging support

load.ml:    $(CMO)
	    echo $(CMO) | tr ' ' \\012 | sed 's/^.*$$/#load "&";;/' > $@

# -- rules

%.ml:       %.nw
	    $(NOTANGLE) '-L# %L "%F"%N' -R$@ $< > $@

%.mli:      %.nw
	    $(NOTANGLE) '-L# %L "%F"%N' -R$@ $< > $@

%.sig:	    %.ml
	    $(OCAMLC) $(OCAMLC_FLAGS) -c -i $< > $@

%.cmo:      %.ml
	    $(OCAMLC) $(OCAMLC_FLAGS) -c $<

%.cmx:      %.ml
	    $(OCAMLOPT) $(OCAMLOPT_FLAGS) -c $<

%.cmi:      %.mli
	    $(OCAMLC) $(OCAMLC_FLAGS) -c $<

%.mli %.ml: %.mly
	    $(OCAMLYACC) $<

%.ml:	    %.mll
	    $(OCAMLLEX) $<

# -- manual page

%.1: 	    %.pod
	    $(POD2MAN) $< > $@


# -- special rules

scanner.mli: syntax.nw
	    $(NOTANGLE) '-L# %L "%F"%N' -R$@ $< > $@

scanner.mll: syntax.nw
	    $(NOTANGLE) '-L# %L "%F"%N' -R$@ $< > $@

parser.mly: syntax.nw
	    $(NOTANGLE) '-L# %L "%F"%N' -R$@ $< > $@

# -- documentation

RERUN =     Rerun (LaTeX|to get cross-references right)

pdf:	    $(PDF)

%.pdf:	%.tex 
	    $(LATEX) $<
	    if egrep -s '$(RERUN)' $*.log ;then $(PDFLATEX) $<; fi
	    if egrep -s '$(RERUN)' $*.log ;then $(PDFLATEX) $<; fi

%.inc:      %.nw
	    $(NOWEAVE) -delay $< > $@

%.tex:	%.inc
	    echo "    \documentclass[11pt]{article}	"  > $@
	    echo "    \usepackage{a4wide}		" >> $@
	    echo "    \usepackage{hyperref}		" >> $@
	    echo "    \usepackage{noweb}		" >> $@
	    echo "    \noweboptions{breakcode}		" >> $@
	    echo "    \begin{document}			" >> $@
	    echo "    \input{$<}			" >> $@
	    echo "    \end{document}			" >> $@

# -- configure

$(TOP)/config.mk:
	    echo "Have you run ./configure?"
	    exit 1

# -- dependencies

DEPEND:	    $(ML) $(MLI)
	    $(OCAMLDEP) $(INCLUDES) $(ML) $(MLI) > DEPEND	

include	    DEPEND   		

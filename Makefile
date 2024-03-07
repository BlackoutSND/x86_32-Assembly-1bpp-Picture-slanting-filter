EXEFILE = res
OBJECTS = code.o slantbmp1.o
CCFMT = -m32 -g
NASMFMT = -f elf32 -g
CCOPT = 
NASMOPT = -w+all

.c.o:
	cc $(CCFMT) $(CCOPT) -c $<

.s.o:
	nasm $(NASMFMT) $(NASMOPT) -l $*.lst $<

$(EXEFILE): $(OBJECTS)
	cc $(CCFMT) -o $@ $^
	
.PHONY:clean
clean:
	rm -f *.o *.lst $(EXEFILE)


 
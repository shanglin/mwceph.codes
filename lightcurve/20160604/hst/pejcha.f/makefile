# fort=/Users/wenlong/Programs/gcc-4.9.1/bin/gfortran-4.9.1
#fort = ~/Programs/gcc-6.1.0/bin/gfortran
fort = gfortran

main: cepheidtemplate.o main.o
	$(fort) -ffixed-line-length-190 -o main main.o cepheidtemplate.o

period: cepheidtemplate.o period.o
	$(fort) -ffixed-line-length-190 -o period period.o cepheidtemplate.o

period.o: period
	$(fort) -ffixed-line-length-190 -O -c period.f

cepheidtemplate.o: cepheidtemplate.f
	$(fort) -ffixed-line-length-190 -O -c cepheidtemplate.f

main.o: main.f
	$(fort) -ffixed-line-length-190 -O -c main.f

clean:
	rm -f period_it? *.o

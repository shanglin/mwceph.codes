# fort=/Users/wenlong/Programs/gcc-4.9.1/bin/gfortran-4.9.1
fort = gfortran

period: cepheidtemplate.o period.o
	$(fort) -ffixed-line-length-190 -o period period.o cepheidtemplate.o

period_it1: cepheidtemplate.o period_it1.o
	$(fort) -ffixed-line-length-190 -o period_it1 period_it1.o cepheidtemplate.o

period_it2: cepheidtemplate.o period_it2.o
	$(fort) -ffixed-line-length-190 -o period_it2 period_it2.o cepheidtemplate.o

period_it3: cepheidtemplate.o period_it3.o
	$(fort) -ffixed-line-length-190 -o period_it3 period_it3.o cepheidtemplate.o

period.o: period
	$(fort) -ffixed-line-length-190 -O -c period.f

period_it1.o: period_it1.f
	$(fort) -ffixed-line-length-190 -O -c period_it1.f

period_it2.o: period_it2.f
	$(fort) -ffixed-line-length-190 -O -c period_it2.f

period_it3.o: period_it3.f
	$(fort) -ffixed-line-length-190 -O -c period_it3.f

cepheidtemplate.o: cepheidtemplate.f
	$(fort) -ffixed-line-length-190 -O -c cepheidtemplate.f

clean:
	rm -f period_it? *.o

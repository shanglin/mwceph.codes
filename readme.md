#*H* LIGHT CURVES OF 34 GALACTIC CEPHEIDS
---------------

####This page contains the codes used for the project of *H* - band observations of 34 Galactic Cepheids. The codes can be messy at some directories. They are put here only for reference purpose.

- `IDLbin` contains some frequently used IDL functions in this work.
   - `statusline.pro` was written by Craig B. Markwardt.
   - Others are self-defined simple functions. 
   - One may need to include this directory to IDL PATH in order to run most scripts in this work.

   
- `IDLpphot` contains the IDL scripts for aperture photometry. It is an interactive pipeline to reduce the data.
- `dark`, `flat` contain scripts to prepare the dark images and flat images.
- `lightcurve` contains R scripts for generating light curves and fitting them to templates from Inno+ (2015). 
- `period_all` is for the first trial of estimating periods using literature data.
- `pdot` contains the code for final determination of periods.
  - pejcha.f is a directory that contains some modified fortran codes from [Ondrej & Christopher (2012)] (http://www.astro.princeton.edu/~pejcha/cepheids/)
- `draft` contains R scripts for making figures and tables in the draft paper.
















 
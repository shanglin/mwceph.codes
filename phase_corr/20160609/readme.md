#(step 0: retrieve data)

# [http://archive.stsci.edu/hst/search.php](http://archive.stsci.edu/hst/search.php)

## Proposal IDs:
```12679,12879,13101,13334,13335,13344,13678,13686,13928,14062,14206```

## Filters/Gratings:
```F160W*```

## Got 248 entries returned. 
*query_result.csv*

--------------
--------------

## (1) Select the Cepheids in our sample and convert the calendar dates to Julian dates.

## (2) If the same object was observed several times within two hours, take them as only one epoch. Derive the phase of each epoch.

## (3) Calculate three types of sigma:

- (3.1.1) Uncertainty from the model:

The model reads
$$
  m_t = M + L \cdot [A_0 + \sum_{i=1}^7 A_i \mathrm{cos}(2\pi i(\phi_t+\psi) + \Phi_i)] + \sigma_t\epsilon
$$
which yields
$$
  \sigma_1 = 0 + 
  \frac{\partial m}{\partial L}\cdot \sigma_L +
  \frac{\partial m}{\partial \psi}\cdot \sigma_\psi \\
  = \sigma_L\cdot |[A_0 + \sum_{i=1}^7 A_i \mathrm{cos}(2\pi i(\phi_t+\psi) + \Phi_i)]| + L\cdot\sigma_\psi\cdot |\sum_{i=1}^7 A_i \mathrm{sin}(2\pi i(\phi_t+\psi) + \Phi_i)\cdot 2\pi i|
$$

- (3.1.2) Uncertainty from model fit residuals (since template is not the true light curve)
  
$ \sigma_2 = \sigma $ where $\sigma$ is the model-measurement scatter from [Table 4 of Inno+ (2015)](http://www.aanda.org/articles/aa/full_html/2015/04/aa24396-14/T7.html), or maybe better, take $\sigma$ as the standard deviation of our model fit residuals, since we fit the model for individual Cepheids and have some freedom in the template to reduce $\sigma$.

- (3.1.3) Uncertainty from the uncertainty of the period
$$
\sigma_3 = \frac{\partial m}{\partial \phi} \cdot \frac{\partial \phi}{\partial P}\cdot \sigma_P \\
= L\cdot|\sum_{i=1}^7 A_i \mathrm{sin}(2\pi i(\phi_t+\psi) + \Phi_i)\cdot 2\pi i\cdot \frac{N_{cyc}}{P}|\cdot \sigma_P
$$
Where $N_{cyc}$ is the number of cycles between HST and ground-based observatiosn, and it can be negative if the HST observation is prior to the ground-based observation.

### (3.2.1) If there is only one HST observation, then $\sigma = \mathrm{Max}(\sqrt{\sigma_1^2 + \sigma_3^2}, \sigma_2)$.
### (3.2.2) If there are multiple HST observations:
$$
  \sigma_{1,total} = \frac{\sigma_L}{N}\cdot|\sum_{j=1}^N\{A_0 + \sum_{i=1}^7 A_i \mathrm{cos}(2\pi i(\phi_{t,j}+\psi) + \Phi_i)\}| + \frac{L\cdot\sigma_\psi}{N}\cdot |\sum_{j=1}^N\{\sum_{i=1}^7 A_i \mathrm{sin}(2\pi i(\phi_{t,j}+\psi) + \Phi_i)\cdot 2\pi i\}|
$$
The $\sigma_{1,total}$ denotes the total model uncertainty. It does not go down with the square root of number of observations $N$, but the differences in phase might beat the last two terms down.

$$
	\sigma_{2,total} = \frac{\sigma_2}{\sqrt{N}}
$$
This assumes that the model residuals of ground-based measurements are the same as that of HST-based measurements. This is true if the residuals of the model fit of true light curves are relatively large. If not, $\sigma_{2,total}$ would over estimate the residual uncertainty.

$$
	\sigma_{3,total} = \frac{L}{N}\cdot|\sum_{j=1}^N\sum_{i=1}^7 \{A_i \mathrm{sin}(2\pi i(\phi_{t,j}+\psi) + \Phi_i)\cdot 2\pi i\cdot \frac{N_{cyc}}{P}\}|\cdot \sigma_P
$$
Similar to $\sigma_{1,total}$, $\sigma_{3,total}$ does not go down with $N$ substantially. It decrease only when the HST observations distribute both before and after the ground-based observations.

Finally, the total phase correction uncertainty of multiple HST observations should be
$$
	\sigma = \mathrm{Max}(\sqrt{\sigma_{1,total}^2 + \sigma_{3,total}^2}, \sigma_{2,total})
$$

### Results
```
#     id     sigma.1   sigma.2   sigma.3  sigma.13  max(13,2)   mag.corr
     adpup   0.02184   0.02413   0.00035   0.02184   0.02413    -0.14656
     aqcar   0.00305   0.00782   0.00000   0.00305   0.00782    -0.03681
     aqpup   0.00320   0.01294   0.00022   0.00320   0.01294     0.00957
     betad   0.02126   0.03251   0.00000   0.02126   0.03251    -0.13521
     bnpup   0.04782   0.04923   0.00007   0.04782   0.04923    -0.05277
     crcar   0.00557   0.01672   0.00000   0.00557   0.01672     0.03029
     drvel   0.01570   0.02501   0.00017   0.01570   0.02501     0.03932
     hwcar   0.00226   0.00580   0.00000   0.00226   0.00580    -0.00794
     kkcen   0.00538   0.01874   0.00006   0.00538   0.01874    -0.13490
     kncen   0.00441   0.01356   0.00012   0.00442   0.01356    -0.04146
     lcarl   0.02683   0.03513   0.00035   0.02683   0.03513    -0.10137
     rysco   0.00299   0.00966   0.00000   0.00299   0.00966    -0.03411
     ryvel   0.00918   0.01742   0.00009   0.00918   0.01742    -0.01858
     s-nor   0.01293   0.03157   0.00000   0.01293   0.03157     0.03132
     sscma   0.00757   0.01313   0.00056   0.00759   0.01313    -0.00256
     svvel   0.00989   0.01125   0.00000   0.00989   0.01125     0.11542
     synor   0.01000   0.01638   0.00000   0.01000   0.01638     0.02580
     t-mon   0.02441   0.02592   0.00000   0.02441   0.02592     0.14277
     u-car   0.01006   0.01493   0.00035   0.01007   0.01493     0.18328
     uumus   0.00568   0.00575   0.00041   0.00570   0.00575    -0.07461
     vjara   0.00504   0.01437   0.00000   0.00504   0.01437     0.09615
     vjcen   0.01504   0.02908   0.00004   0.01504   0.02908     0.08094
     vwcen   0.00601   0.01248   0.00002   0.00601   0.01248    -0.18063
     vycar   0.00497   0.00936   0.00082   0.00503   0.00936     0.04012
     vzpup   0.02588   0.02650   0.00110   0.02590   0.02650    -0.26534
     w-sgr   0.01074   0.03140   0.00000   0.01074   0.03140    -0.00706
     wxpup   0.00951   0.01205   0.00025   0.00952   0.01205     0.08612
     wzsgr   0.00113   0.00362   0.00024   0.00116   0.00362    -0.01021
     x-pup   0.01246   0.01564   0.00119   0.01252   0.01564    -0.03171
     xxcar   0.01243   0.02645   0.00019   0.01243   0.02645     0.00050
     xycar   0.00268   0.00667   0.00000   0.00268   0.00667    -0.03409
     xzcar   0.00396   0.00880   0.00012   0.00396   0.00880     0.04828
     yzcar   0.01345   0.01639   0.00005   0.01345   0.01639    -0.07605
     yzsgr   0.00384   0.02115   0.00001   0.00384   0.02115     0.04179

```

# (4) Update the table in the draft paper
```
\begin{deluxetable*}{lrrrrrrrrrc}
\tabletypesize{\scriptsize}
\tablecaption{Light Curve Parameters \label{tbl:par}}
\tablewidth{0pt}
\tablehead{
\multicolumn{1}{c}{Object} & \multicolumn{1}{c}{$P$} & \multicolumn{1}{c}{$\sigma_P$} & \multicolumn{1}{c}{$t_0$} & \multicolumn{1}{c}{$M$} & \multicolumn{1}{c}{$\sigma_M$} & \multicolumn{1}{c}{$L$} & \multicolumn{1}{c}{$\sigma_L$}  & \multicolumn{1}{c}{$\psi$} & \multicolumn{1}{c}{$\sigma_{\it \psi}$} & \multicolumn{1}{c}{$\sigma_\mathrm{corr}$} \\
\multicolumn{1}{c}{} & \multicolumn{1}{c}{(d)} & \multicolumn{1}{c}{([1])} & \multicolumn{1}{c}{(d)} & \multicolumn{1}{c}{(mag)} & \multicolumn{3}{c}{($10^{-4}$mag)} & \multicolumn{2}{c}{([2])} & \multicolumn{1}{c}{($10^{-4}$mag)}}
\startdata
\input{tables/pars.tex}
\enddata
\tablecomments{[1]: units of $10^{-6}$~d; [2]: units of $10^{-4}{\rm rad}/2\pi$.}
\end{deluxetable*}

```
---------------------
```
W~Sgr       &   7.585536 &      1768 &  7187 &   2.886 &      97 &    2902 &     365 &    6775 &     153 &     314 \\
WX~Pup      &   8.935991 &       422 &  6967 &   6.690 &      48 &    2571 &     224 &    3308 &      83 &     120 \\
HW~Car      &   9.199488 &        39 &  6759 &   6.753 &      35 &    1501 &     234 &    6597 &     113 &      58 \\
V339~Cen    &   9.466540 &        76 &  6961 &   5.809 &     108 &    2649 &     329 &    6820 &     194 &     291 \\
YZ~Sgr      &   9.553551 &       290 &  6900 &   4.941 &      44 &    2558 &     116 &    5977 &      71 &     212 \\
S~Nor       &   9.754615 &       122 &  7416 &   4.384 &     170 &    2292 &     446 &    4825 &     243 &     316 \\
CR~Car      &   9.758552 &       119 &  7179 &   8.211 &      43 &    2079 &     121 &    9051 &      95 &     167 \\
AQ~Car      &   9.769427 &       119 &  6762 &   6.704 &      44 &    2023 &     138 &     234 &     169 &      78 \\
$\beta$~Dor &   9.842865 &      3365 &  6910 &   1.974 &     116 &    2661 &     337 &    1029 &     194 &     325 \\
DR~Vel      &  11.199240 &        86 &  6996 &   5.983 &      94 &    2759 &     258 &    2904 &     147 &     250 \\
UU~Mus      &  11.636093 &       156 &  7038 &   6.959 &      27 &    3109 &      91 &    1124 &      31 &      58 \\
KK~Cen      &  12.182794 &       135 &  7042 &   8.106 &      30 &    2714 &      80 &    4510 &      58 &     187 \\
SS~CMa      &  12.353912 &       571 &  6958 &   6.836 &     106 &    2463 &     374 &    8127 &     150 &     131 \\
XY~Car      &  12.436119 &        23 &  6735 &   6.425 &      60 &    3104 &     174 &    1221 &      74 &      67 \\
SY~Nor      &  12.645111 &        94 &  7181 &   6.009 &      76 &    3163 &     265 &    3789 &      79 &     164 \\
AD~Pup      &  13.597026 &       414 &  6957 &   7.320 &      96 &    3258 &     281 &    2902 &     150 &     241 \\
BN~Pup      &  13.672693 &        42 &  6971 &   7.080 &     196 &    3654 &     481 &    2288 &     231 &     492 \\
SV~Vel      &  14.098082 &        70 &  7291 &   5.906 &      93 &    2648 &     211 &    5122 &     188 &     112 \\
VW~Cen      &  15.036782 &        77 &  7053 &   7.017 &      39 &    3569 &     100 &    4315 &      48 &     125 \\
XX~Car      &  15.706947 &       203 &  7026 &   6.720 &     123 &    3860 &     408 &    3106 &     112 &     264 \\
XZ~Car      &  16.652874 &       231 &  6739 &   5.677 &      61 &    3490 &     178 &     945 &      90 &      88 \\
YZ~Car      &  18.167873 &       756 &  6758 &   5.935 &     137 &    2700 &     360 &    7818 &     188 &     164 \\
VY~Car      &  18.915370 &      3365 &  6833 &   4.940 &      92 &    3851 &     267 &    5749 &     121 &      94 \\
RY~Sco      &  20.322525 &       232 &  6819 &   4.273 &      66 &    2954 &     200 &    7182 &     103 &      97 \\
V340~Ara    &  20.814195 &       247 &  7198 &   6.659 &      36 &    3637 &      91 &    8277 &      49 &     144 \\
WZ~Sgr      &  21.854459 &      1889 &  7023 &   4.730 &      40 &    3614 &     139 &    6784 &      47 &      36 \\
VZ~Pup      &  23.174827 &      2625 &  6965 &   6.820 &     114 &    4584 &     299 &    5957 &     108 &     265 \\
X~Pup       &  25.972688 &      3747 &  6752 &   5.580 &     124 &    4926 &     483 &    3514 &      94 &     156 \\
T~Mon       &  27.025264 &      9933 &  7072 &   3.647 &     138 &    4283 &     488 &    5325 &     179 &     259 \\
RY~Vel      &  28.134148 &       447 &  7015 &   5.116 &      48 &    3525 &     142 &    9906 &      68 &     174 \\
AQ~Pup      &  30.157334 &     13866 &  6764 &   5.445 &      79 &    4648 &     239 &     838 &      72 &     129 \\
KN~Cen      &  34.022040 &      1595 &  6748 &   5.725 &     143 &    4823 &     474 &    6084 &     127 &     136 \\
{\it l}~Car &  35.549700 &     22779 &  6833 &   1.124 &     124 &    3010 &     341 &    7454 &     173 &     351 \\
U~Car       &  38.809220 &     12287 &  7085 &   3.639 &      65 &    4703 &     243 &     937 &      53 &     149
```
 
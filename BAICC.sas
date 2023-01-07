data diffhsum;
 set datafroma2assays;
 diff = a1-a2; *diference between assays;
 hsum = 0.5*(a1+a2); *half-sum of assays;
 if a1 ne . and a2 ne .; *excluding missing data;
 keep hsum diff;
run;

proc sql noprint;
 *calculating stats from diffhsum data that are needed for ICC calculation;
 *then calculating ICC and limits of agreement;
 select 
 	mean(diff), std(diff), sum(diff*diff), avg(hsum), count(*)*2/(2*count(*)-1)
 	into :bias, :std_diff, :sq_diff, :mean_hsum, :Nsfactor
 from diffhsum;
 select 
 	1-&Nsfactor*&sq_diff/sum((&mean_hsum-hsum)*(&mean_hsum-hsum)),
 	&bias-1.96*&std_diff, &bias+1.96*&std_diff
	into :ICC, :lla, :ula
 from diffhsum;
quit;

title height=20pt italic 'Bland-Altman Plot' color=blue;
proc sgplot data=diffhsum;
 scatter x=hsum y=diff / markerattrs=(color=black size=9pt);
 refline &lla/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline &bias/ axis=y lineattrs=(color=red thickness=2pt);
 refline &ula/ axis=y lineattrs=(color=red pattern=4
 thickness=2pt);
 refline 0 / axis=y lineattrs=(color=blue thickness=2pt);
 yaxis label='DIFFERENCE' valueattrs=(size=15pt style=italic) labelattrs=(size=19pt);
 xaxis label='HALFSUM' valueattrs=(size=14pt style=italic) labelattrs=(size=18pt);
run;
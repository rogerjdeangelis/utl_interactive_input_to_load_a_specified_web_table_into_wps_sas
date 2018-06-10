
Interactive input to load a specified web table into WPS SAS

  SAS/Window command and IML/R or WPS/PROC R

  https://communities.sas.com/t5/SAS-Enterprise-Guide/Import-a-CSV-file-from-a-URL-with-varying-date-value/m-p/468544



 WPS does not support interactive windows, however you can use Python tkinter for interactive input
 with classic SAS.


INPUT
=====
   You have to enter test 'failed', I don't have access to a url with a data

   A window pops up asking user for text to specify a web html table to load into SAS/WPS

   Enter text (failed), or (stop) " response $8. attr=underline  ___________

   https://www.fdic.gov/bank/individual/&response/banklist.html

   User text is substituted for &response


PROCESS (SAS/ Window and WPS Proc R)   (Note how the fist window can stop the datastep)
=======================================================================================

 %symdel failed /nowarn;

 data _null_;

   window chose irow=5 rows=25
     #5 @12 "Enter text (failed), or (stop) " response $8. attr=underline;
   display chose;
   if response='stop' then do;
       put "stopping";
       stop;
   end;
   else call symputx('mmddyyyy',response);

   rc=dosubl(%str(
    %utl_submit_wps64("
      libname sd1 'd:/sd1';
      options set=R_HOME 'C:/Program Files/R/R-3.3.2';
      libname wrk sas7bdat '%sysfunc(pathname(work))';
      proc r;
      submit;
      library(rvest);
      library(dplyr);
      source('C:/Program Files/R/R-3.3.2/etc/Rprofile.site', echo=T);
      URL <- 'https://www.fdic.gov/bank/individual/&mmddyyyy./banklist.html';
      want <- URL %>%
        read_html() %>%
        html_table() %>%
        as.data.frame();
      endsubmit;
      import r=want  data=wrk.want;
      run;quit;"
    )));
    stop;

 run;quit;

* LOG;

> library(rvest)
Loading required package: xml2
Warning messages:
1: package 'rvest' was built under R version 3.3.3
2: package 'xml2' was built under R version 3.3.3
> library(dplyr)
Attaching package: 'dplyr'
The following objects are masked from 'package:stats':
    filter, lag
The following objects are masked from 'package:base':
    intersect, setdiff, setequal, union
Warning message:
package 'dplyr' was built under R version 3.3.3
> source('C:/Program Files/R/R-3.3.2/etc/Rprofile.site', echo=T)
> .libPaths(c(.libPaths(), "d:/3.3.2", "d:/3.3.2_usr"))
> options(help_type = "html")
> URL <- 'https://www.fdic.gov/bank/individual/failed/banklist.html'
> want <- URL %>%     read_html() %>%     html_table() %>%     as.data.frame()

NOTE: Processing of R statements complete

12        import r=want  data=wrk.want;
NOTE: Creating data set 'WRK.want' from R data frame 'want'
NOTE: Column names modified during import of 'want'
NOTE: Data set "WRK.want" has 555 observation(s) and 7 variable(s)

13        run;
NOTE: Procedure r step took :
      real time : 3.360
      cpu time  : 0.062

OUTPUT
======

Up to 40 obs from want total obs=555

Obs  BANK_NAME                             CITY                ST   CERT  ACQUIRING_INSTITUTION       CLOSING_DATE        UPDATED_DATE

  1  Washington Federal Bank for Savings   Chicago             IL  30570  Royal Savings Bank          December 15, 2017   February 21, 2018
  2  Fayette County Bank                   Saint Elmo          IL   1802  United Fidelity Bank, fsb   May 26, 2017        July 26, 2017
  3  First NBC Bank                        New Orleans         LA  58302  Whitney Bank                April 28, 2017      December 5, 2017
  4  Proficio Bank                         Cottonwood Heights  UT  35495  Cache Valley Bank           March 3, 2017       March 7, 2018
....

550    Sinclair National Bank              Gravette            AR  34248  Delta Trust & Bank          September 7, 2001   October 6, 2017
551    Superior Bank, FSB                  Hinsdale            IL  32646  Superior Federal, FSB       July 27, 2001       August 19, 2014
552    Malta National Bank                 Malta               OH   6629  North Valley Bank           May 3, 2001         November 18, 2002
554    National State Bank of Metropolis   Metropolis          IL   3815  Banterra Bank of Marion     December 14, 2000   March 17, 2005
555    Bank of Honolulu                    Honolulu            HI  21029  Bank of the Orient          October 13, 2000    March 17, 2005

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

  https://communities.sas.com/t5/SAS-Enterprise-Guide/Import-a-CSV-file-from-a-URL-with-varying-date-value/m-p/468544

  and interactively entered text


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process


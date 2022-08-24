*** Downloading data from Fred Econ 895 ************
*
* Name: Carlos D. Ramirez
*
* Spring 2022
*
* Analysis of GDP data from FRED 				*
*************************************************

clear 									/*command to clear current memory in STATA.*/
capture log close 						/*command to ensure your log file will open and close multiple times.*/

cd "$BENNETT"
log using gdp_analysis_fred_spring2021.log, replace

import fred GDPC1
format daten %td
gen date = qofd(daten)
format date %tq
sort date
tsset date, quarterly

ren GDPC1 y

gen ly = log(y)
gen yg = d.ly
gen covid = date>tq(2019q4) /*Dummy to test if COVID period is different.*/

** Evaluating Real GDP ***

* Step 1: plot the data. See if there is a clear trend.*
tsline ly

* Step 2: Use dfuller test to see if there is a stochastic trend or deterministic trend.*
dfuller ly, trend

* Step 3: Conduct Augmented DF test for robustness purposes *
dfuller ly, trend lag(4) regress

* Step 3a: check appropriate lag length*
varsoc ly, maxlag(10)

* Step 4: Make conclusion on whether or not there is a stochastic trend.*

* Step 5: Evaluate AR and/or MA parts *
ac yg
pac yg
corrgram yg

* Step 6: Check for structural break: suspect is COVID*
gen inter = covid*l.yg
reg yg covid inter l.yg

*Alternative specification*
reg yg covid##c.l.yg
** We have some evidence of a COVID induced structural break.*
* We investigate the model under "normal" circumstances.*

* Step 7: Estimate ARIMA pre-covid model *
drop if covid==1
ac yg
pac yg

arima ly, arima(1,1,0)
predict ly110_hat
arima ly, arima(1,1,1)
predict ly111_hat

* Step 8: Do dmariano see which model is "better"*
dmariano ly ly110_hat ly111_hat

* Step 9: Winner is ARIMA(1,1,0)
* Estimate OLS model *

reg yg l.yg

* Check with book, page 194.*

* Filtering *
tsfilter hp ly_hp = ly



log close
exit


*! version 1.0.1 March 9, 1999  Rick Thompson
*! revside 12 Feb 00 for Biostat 623 class  JT

*! crossvalidates roc curves
*! crossvalidates goodness-of-fit tests
capture program drop crossval
program define crossval
version 12.1

	local varlist "req fv ex min(2)"
	local options "Numgrps(int 5)"

	parse "`*'"
	if `numgrps'<2 {
		display in red "Numgrps must be at least 2!"
		exit 198
		}

	//display"pt1"

	tempvar random cat phat pdummy

	gen `random' = uniform()
	sort `random'
	xtile `cat' = `random', n(`numgrps')
	quietly gen `phat' = .

	local cnt 1
	while `cnt' <= `numgrps' {
		capture drop `pdummy'
		quietly {
			logistic `varlist' if `cat'!=`cnt' & `cat'!=.
			predict `pdummy' if `cat' == `cnt'
			replace `phat' = `pdummy' if `cat' == `cnt'
			}
		local cnt = `cnt' +1
		}

	quietly replace `phat' =  log(`phat'/(1-`phat'))

	tempname mat

	matrix define `mat' = (1)
	matrix colnames `mat' = `phat'

	local yvar : word 1 of `varlist'


	display" "
	display" "
	display in green "CROSS-VALIDATED ROC CURVE DELETING 1/`numgrps' OBS.:"
	lroc `yvar', beta(`mat') t1(Cross-validated ROC deleting 1/`numgrps' obs.') l1(" ") l2("Sensitivity")

	display" "
	display" "
	display in green "CROSS-VALIDATED GOODNESS-OF-FIT DELETING 1/`numgrps' OBS.:"
	lfit `yvar', beta(`mat')
	display " "


	display" "
	display" "
	display in green "CROSS-VALIDATED HOSMER-LEMESHOW GOODNESS-OF-FIT DELETING 1/`numgrps' OBS.:"
	lfit `yvar', beta(`mat') group(10)
	display " "


end

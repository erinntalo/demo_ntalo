********************************************************************************
** Date created: 08 June 2022
**
** Author: Erin Ntalo
**
** Purpose: Summary stats for Wave 2 consent survey data
**
** Date Last Modified: 08 June 2022
********************************************************************************

version 17.0
clear all 
set more off

// 1. Working directory & globals
	
	* working directory
	cd "G:\My Drive\GPRL\Debt Payoff"
	
	* raw data
	global raw_data "~\Data\01 raw"
	
	* deidentified data
	global nopii_data "~\Data\02 no PII"
	
	* working data
	global working "~\Data\03 working"
	
	
// 2. Import and save data
	import delimited "X:\Dropbox\NU-UpTogether Materials\03 Data\01 Pilot Wave 1\01 Consent Survey Data\01 Raw\Debt+Payoff+Pilot+Consent_June+6,+2022_09.38.csv", varnames(1) numericcols(5 6 14 15)
	
	save "X:\Dropbox\NU-UpTogether Materials\03 Data\01 Pilot Wave 1\01 Consent Survey Data\02 Summary Stats (PII)\Debt Payoff Pilot Consent 20220606.dta", replace 
	
	
// 3. Drop 2 observations that are unused .CSV headers
	drop if consent_email == "Email Address"
	drop if progress == . // this may not work if future raw data has "." in progress
	

// 4. Summary stats
	preserve
	drop status ipaddress finished recordeddate responseid recipientlastname recipientfirstname recipientemail externalreference locationlatitude locationlongitude distributionchannel

	// a. Number of complete submissions
		tab progress, m
		drop if progress < 100
		
		*52 completed surveys (out of 71 total submissions)
	
	// b. Number of (a) + consenting submissions
		gen consent = consent_status, after(consent_status)
		replace consent = "1" if consent == "Yes, I consent to participate in this study."
		replace consent = "0" if consent == ""
		destring consent, replace
		drop consent_status
		
		tab consent, m
		
		*49 complete, consenting submissions
	
	// c. Number of (b) + legitimate (not test) submissions
		br if progress == 100 & consent == 1
		gen legit = 1
		replace legit = 0 if consent_name_5 == "DROP ME" | consent_name_4 == "Test"
		br if progress == 100 & consent == 1 & legit == 1
		drop if legit == 0
		
		tab consent, m
		
		*46 complete, consenting, legitimate submissions
		
	// d. Remove duplicates (more than one instance of a first and last name or email)
		sort consent_email
		duplicates tag consent_email, gen(dup_email)
		sort consent_name_6
		foreach name in consent_name_4 consent_name_5 consent_name_6 {
			replace `name' = strtrim(`name')
		}
		duplicates tag consent_name_4 consent_name_6, gen(dup_flname)
	
		bysort consent_email: gen keep = (_n == 1)
		
	
	restore
	
	

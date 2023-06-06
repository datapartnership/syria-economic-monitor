********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Master do file
* Author: Alejandra Quevedo (al.quevedo0420@gmail.com)(acardona@worldbank.org)
* Created: 05/06/2023
********************************************************************

///////////////	INTRODUCTION //////////////////////////////////////////////

*Data: HSOS contains information at community level on indicators related to the humanitarian situation in Northwestern (NWS) and Norteastern (NES) regions of Syria. 

*Time frame: the months use were selected based on the availability of information for both NWS and NES. For example, January has info only on NWS while December has information on both months. 

*Files: raw data is contained in excel files downloaded from the website of REACH Initiative. Along, with data on earthquake intensity. For processing the excel data the command iecodebook was used, codebooks used to run the code are all available. 

clear all
set more off

////////////// PACKAGES////////////////////////////////////////////////////

local packages 0

if (`packages' ==1) { //Change the local above to run or not to run this file
	ssc install schemepack, replace
	ssc install iefieldkit, replace
	ssc install ietoolkit, replace
}

/////////////// DIRECTORY ////////////////////////////////////////////////

global github 	"C:\Users\wb357411\OneDrive - WBG\Documents\GitHub\"
global syria 	"${github}\syria-economic-monitor\notebooks\"
global hsos 	"${syria}/hsos-survey/"


////////////// PROJECT FOLDER GLOBALS ///////////////////////////////////

global original "$hsos\Original"
global output "$hsos\Clean data\Intermediate"
global codebooks "$hsos\Codebooks"
global clean "$hsos\Clean data"
global figures "$hsos\Figures"
global line "${figures}\Line Trends"
global maps "$hsos\Shapefiles"
global dofile "$hsos\Do Files"

//////////////DO FILES /////////////////////////////////////////////////

*Import of data, renaming, append of regions and months, and merge with intensity data.
local importDo 0

*Cleaning of variables, recodification (string to numeric), and definition of indicators.
local cleaningDo 0

*Line trends for indicators of interest by earthquake intensity.
local linetrendsDo 1

*Bar graphs of interest indicators.
local graphsDo 1

*Map of IDPs displaced because earthquake.
local mapsDo 1

*Selection of outputs of interest - Line trends 
local outputsDo 1


if (`importDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\1_Import.do"   
}

if (`cleaningDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\2_Cleaning.do"   
}

if (`linetrendsDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\2_Cleaning.do"   
}

if (`linetrendsDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\3_Line Trends.do"   
}

if (`graphsDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\4_Bar graphs.do"   
}

if (`mapsDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\5_Map.do"   
}

if (`outputsDo' ==1) { //Change the local above to run or not to run this file
 do "${dofile}\6_Outputs.do"   
}


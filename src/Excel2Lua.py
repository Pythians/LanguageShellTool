# -*- coding: UTF-8 -*- 

import xlrd
import sys
import os

reload(sys) 
sys.setdefaultencoding( "utf-8" )

excelFile=sys.argv[1]
tempFile=sys.argv[2]

column = 1
if sys.argv[3] == '1' :
	column = 2

if not os.path.exists(excelFile):
	print("Error! "+ excelFile + " not exist!!!")
	sys.exit(1)

excel=xlrd.open_workbook(excelFile)

data="local languageFromExcel = { \n"
sheet1=excel.sheet_by_index(0)
rowNum=sheet1.nrows
for r in range(2,rowNum,1):
	if sheet1.cell(r,0).value != "" :
		data=data+'\t'+ str(sheet1.cell(r,0).value) +'' + ' = ' + '[[' + sheet1.cell(r,column).value + ' ]],\n'
data=data+"}\nreturn languageFromExcel"

fileOutput=open(tempFile,'w')
fileOutput.write(data)
fileOutput.close()

print(tempFile + " has CreateDone!")


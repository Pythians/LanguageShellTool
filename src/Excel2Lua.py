# -*- coding: UTF-8 -*- 

import xlrd
import sys
import os

reload(sys) 
sys.setdefaultencoding( "utf-8" )

excelFile=sys.argv[1]
tempFile=sys.argv[2]
colNum = 0

if len(sys.argv) > 3:
	colNum = int(sys.argv[3])

if not os.path.exists(excelFile):
	print("Error! "+ excelFile + " not exist!!!")
	sys.exit(1)

excel=xlrd.open_workbook(excelFile)

data="local languageFromExcel = { \n"
sheet1=excel.sheet_by_index(0)
rowNum=sheet1.nrows
for r in range(1,rowNum):
	if sheet1.cell(r,0).value != "" :
		data=data+'\t'+ str(sheet1.cell(r,0).value) +'' + ' = ' + '[[' + str(sheet1.cell(r,colNum+1).value) + ' ]],\n'
data=data+"}\nreturn languageFromExcel"

fileOutput=open(tempFile,'w')
fileOutput.write(data)
fileOutput.close()

print(tempFile + " has CreateDone!")


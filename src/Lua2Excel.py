# -*- coding: UTF-8 -*- 

from xlwt import *
import sys
import os


reload(sys) 
sys.setdefaultencoding( "utf-8" )

luaFile=sys.argv[1]

if not os.path.exists(luaFile):
	print("Error! " + luaFile + " not exist!!!")
	sys.exit(1)



w=Workbook(encoding='utf-8')
sheet1=w.add_sheet('Sheet1')

sheet1.write(0,0,"文本ID")
sheet1.write(0,1,"文本内容")


lineNum=0

f=open(luaFile,"r")
for line in f:
	if lineNum > 1 :
		str=line
		str_list=str.split(' = ')
		if len(str_list) >1 :
			leftStr=str_list[0].strip()
			rightStr=str_list[1].strip()
			leftLen=len(leftStr)
			rightLen=len(rightStr)
			sheet1.write(lineNum,0,leftStr[2:leftLen-2])
			sheet1.write(lineNum,1,rightStr[1:rightLen-2])
	lineNum=lineNum+1
f.close()

w.save(sys.argv[2])
print(sys.argv[2] + " CreateDone!")

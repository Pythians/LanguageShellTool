
local AcademyScienceConfig = require("app.components.language.AcademyScienceConfig")
local BagPackItemConfig = require('app.components.language.BagPackItemConfig')
local BuildMoreInfoConfig = require("app.components.language.BuildMoreInfoConfig")
local BuildUpgradeConfig = require("app.components.language.BuildUpgradeConfig")
local HeroEquipConfig = require("app.components.language.HeroEquipConfig")
local HeroSkillConfig = require("app.components.language.HeroSkillConfig")
local SoliderSkill = require("app.components.language.SoliderSkillConfig")
local MoreInfoConfig = require("app.components.language.MoreInfoConfig")
local language_cn = require("app.components.language.language")
local languageMode = require("app.components.language.languageMode")



----------------------------------------------------------------------------------------------------
--@@@@@ 除了 lanugage_cn.lua 文件， 不要在配置的键中使用下划线
--@@@@@ 匹配规则
--匹配从源配置表的键开始
--字符串只能在前面
-- ‘*’ 匹配所有子项
-- ‘-’ 匹配子项中的 number 类型键
-- ‘=’ 匹配子项中的 string 类型键
-- {} 中指定匹配的子键
-- 
-- local languageMode={                         匹配：                           解释：                              
--    ['Building'] = {                          {'Building'}                    匹配'Building'一个
--        [1] = {                               {'Building', '-'}               匹配'Building'下数字键
--                                                                              下面两个基于前面的匹配
--            ['ID'] = '市政厅',                 {'Building','-',{'ID'}}         匹配 ID 一个
--                                              前面有‘*’‘-’‘=’和 {} 出现,指定的键不论几个都要用在括号括起来
--            ['Explain'] = '市政厅提。。。',      {'Building',‘-’,{'ID',''Explain'}} 
--        },                                                                  匹配'ID',''Explain'两个
--}
--local string = {                              {'='}                         匹配所有 string 类型键
--        ['CorpPower'] = "部队战力：",
--        ['OnceBuild'] = "立即建造",
--}
--local  number = {                             {'-'}                         匹配所有 number 类型的键
--        ['57'] = "部队战力：",
--        ['23'] = "立即建造",
--}
--local all = {                                 {'*'}                         匹配所有的键
--        [1] = "放弃",
--        [19] = "加速时间：%s",
--        ['accelUseTip'] = "请选择加速道具数量",
--        ['accelerrate'] = "加速",
--}
----------------------------------------------------------------------------------------------------

local tool = {}

---------------------------------------------------------------------------------------
--@function 从给的源配置中按照给的键顺序取出对应值
--@param src table 源配置表
--@param key table 键顺序，从第一级键开始
--@return #string 返回找到的配置字符
local function _find(src,key)
    local t = src
    for k,v in pairs(key) do
        if k > 1 then
            t = t[v]
        end
    end
    return t
end

---------------------------------------------------------------------------------------
--@function [parent=#src.app.tools.tool] _t2a 根据规则找到所有值并生成对应的键
--@param src table 源配置表
--@param tab table 匹配规则--从源表第一级键开始
--@param arr table 存放找到的键值对
--@param key table 生成键头一个单词，区分不同配置表
local function _t2a(src, tab, arr, key)

    if #tab == 0 then
        local str = _find(src,key)
        if str then
            arr[table.concat(key,'_',1)] = string.gsub(str,'\n(%s*)','\\n')         	
        -- else
        --     print(table.concat(key,'-',1) .. " no value")
        end
        table.remove(key,#key)       
    else
        local stab = clone(tab)
        if type(stab[1]) == 'table' then
            local n = #key +1
            local t = clone(stab[1])
            table.remove(stab,1)   
            for k,v in pairs(t) do
                key[n] = v
                _t2a(src,stab,arr,key)
            end
            table.remove(key,#key)       
        elseif string.byte(stab[1],1) == string.byte('*',1 ) then
            table.remove(stab,1)   
            local n = #key +1
            local t = _find(src,key)
            for k,v in pairs(t) do
                key[n] = k
                _t2a(src,stab,arr,key)
            end
            table.remove(key,#key)       
        elseif string.byte(stab[1],1) == string.byte('-',1 ) then
            table.remove(stab,1)   
            local n = #key +1
            local t = _find(src,key)
            for k,v in pairs(t) do
                if type(k) == 'number' then
                    key[n] = k
                    _t2a(src,stab,arr,key)                      
                end
            end    
            table.remove(key,#key) 
        elseif string.byte(stab[1],1) == string.byte('=',1 ) then
            table.remove(stab,1)   
            local n = #key +1
            local t = _find(src,key)
            for k,v in pairs(t) do
                if type(k) == 'string' then
                    key[n] = k
                    _t2a(src,stab,arr,key)                      
                end
            end    
            table.remove(key,#key)       
        else
            key[#key+1] = stab[1]
            table.remove(stab,1)   
            _t2a(src,stab,arr,key)
        end        
    end
end

-- 转换当前配置到文件
function tool.Lua2E(fileName)

---------------------------------------------------------------------------------------
--@@@@@ 匹配规则
--匹配从源配置表的键开始
--字符串只能在前面
-- ‘*’ 匹配所有子项
-- ‘-’ 匹配子项中的 number 类型键
-- ‘=’ 匹配子项中的 string 类型键
-- {} 中指定匹配的子键
    local r_mode_FieldMap = {"FieldMap","*","*",{"Explain","ID"}}
    local r_mode_FieldMap2 = {"FieldMap","-","-",'-'}
    local r_mode_FieldMap3 = {"FieldMap",{2,6,8,9,10,11,12,17,18,19},"-",'moreInfo','*','*'}
    local r_mode_Building = {"Building","*",{"ID","Explain"}}
    local r_mode_HeroUI_HeroIntroduce = {"HeroUI","HeroIntroduce", '*'}
    local r_mode_HeroUI_HeroBoss = {"HeroUI","HeroBoss", {"newOpen","firstHero"}}
    local r_mode_HeroUI_HeroBoss_normal = {"HeroUI","HeroBoss", "normal","*"}
    local r_mode_HeroUI_HeroBoss_moreSay = {"HeroUI","HeroBoss", "moreSay","*",'*'}
    local r_mode_HeroSpeciality_level = {"HeroUI","HeroSpeciality", 'level', '*'}
    local r_mode_HeroSpeciality_n = {"HeroUI","HeroSpeciality", '-', {"name","effect"}}
    local r_SoliderSkill = {'*', {"Name","Introduce"}}
    local r_MoreInfo = {'*', '-', '-', {"text"}}
    local r_HerosName = {'*', '-',{"Name"}}
    local r_HeroSkill = {'*', {"Name","Introduce","Introduce4Fight"}}
    local r_HeroEquip_n = {'-', {"Name","tipInfo"}}
    local r_HeroEquip_Effect = {'Effect', '-', '*', {1}}
    local r_BagPackItem = {'*', '*'}
    local r_AcademyScience = {'*', {"name","explain"}}
    local r_language = {'*'}
    local r_BuildUpgrade_effect = {'*','*',{'effect'}}
    local r_BuildUpgrade_item = {'*','*','-',{'item','text'}}
    local r_BuildMoreInfo = {'-',{'description','tabHeader'}}
    local r_BuildMoreInfo_sub = {'-','-',{'tabTitle'}}
    
    local arr = {}
    _t2a(languageMode, r_mode_FieldMap3, arr,{"languageMode"})
    _t2a(languageMode, r_mode_FieldMap2, arr,{"languageMode"})
    _t2a(languageMode, r_mode_FieldMap, arr,{"languageMode"})
    _t2a(languageMode, r_mode_Building, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroUI_HeroIntroduce, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroUI_HeroBoss, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroUI_HeroBoss_normal, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroUI_HeroBoss_moreSay, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroSpeciality_level, arr,{"languageMode"})
    _t2a(languageMode, r_mode_HeroSpeciality_n, arr,{"languageMode"})
    _t2a(SoliderSkill, r_SoliderSkill, arr,{"SoliderSkill"})
    _t2a(MoreInfoConfig, r_MoreInfo, arr, {"MoreInfo"})
    _t2a(HeroSkillConfig, r_HeroSkill, arr,{"HeroSkill"})
    _t2a(HeroEquipConfig, r_HeroEquip_n, arr,{"HeroEquip"})
    _t2a(HeroEquipConfig, r_HeroEquip_Effect, arr,{"HeroEquip"})
    _t2a(BagPackItemConfig, r_BagPackItem, arr,{"BagPackItem"})
    _t2a(AcademyScienceConfig, r_AcademyScience, arr,{"AcademyScience"})
    _t2a(language_cn, r_language, arr,{"language"})
    _t2a(BuildUpgradeConfig, r_BuildUpgrade_effect, arr,{"BuildUpgrade"})
    _t2a(BuildUpgradeConfig, r_BuildUpgrade_item, arr,{"BuildUpgrade"})
    _t2a(BuildMoreInfoConfig, r_BuildMoreInfo, arr,{"BuildMoreInfo"})
    _t2a(BuildMoreInfoConfig, r_BuildMoreInfo_sub, arr,{"BuildMoreInfo"})

    return tool.tableSaveToFile(arr,1,'language', fileName)
end

----------------------------------------------------------------------
-- 以分割符为界，分割字符串，不保存分割符
--@function [parent=#src.app.tools.tool] str_split
--@param str string 需要分割的字符串
--@param char string 侵害字符串的分割符
--@return #table 分割后的子串
local function str_split(str, char)
    local tab = {}
    
    while true do
        local pos = string.find(str,char)
        if pos then
            local sub = string.sub(str,1,pos-1)
            tab[#tab + 1] = sub
            str = string.sub(str,pos+1,#str)
        else
            tab[#tab + 1] = str
            break
        end
    end 
    return tab
end

----------------------------------------------------------------------
--- 按键顺序找到修改配置表
--@function [parent=#src.app.tools.tool] setTable
--@param desciption string 保存到文件中的配置表名
--@param tab table 键顺序表
--@param config table 原配置表
--@param file string 保存的文件名
local function setTable(desciption, tab, config, file)
--    print("desciption",desciption)
--    if desciption == "BuildMoreInfo" then
--    	print("break point")
--    end

    local savefile = file .. '.lua'
    
    local function setItem(item, key,value)
        if not item then
        	return
        end
        if #key == 1 then
            key = tonumber(key[1]) or key[1]
        	item[key] = value
        else
            local k = tonumber(key[1]) or key[1]
            table.remove(key,1)
            setItem(item[k],key,value)
        end	
    end
        
    for k,v in pairs(tab) do
        setItem(config,v[1],v[2])
    end
    
    return tool.tableSaveToFile(config,10,desciption, savefile)
end

----------------------------------------------------------------------
--- 针对 languageMode 的修改
--@function [parent=#src.app.tools.tool] setTable
--@param desciption string 保存到文件中的配置表名
--@param tab table 键顺序表
--@param config table 原配置表
--@param file string 保存的文件名
local function setTableLM(desciption, tab, config, file)
    
    local targetValue={}
    
    local function update(item, key,value)
        if #key == 1 then
            key = tonumber(key[1]) or key[1]
            item[key] = value
            targetValue[#targetValue+1] = value
        else
            local k = tonumber(key[1]) or key[1]
            table.remove(key,1)
            update(item[k],key,value)
        end 
    end
    
----------------------------------------------------------------------------------------------------
--@@@@@@@@@ 引用表修正
--第一个参数照搬
--指定引用键的顺序表
--引用的表名， 既 require("") 的模块名
-- local languageMode = require("app.components.language.languageMode_cn")

    update(config,{'BagPackItem'},'BagPackItemConfig')
    update(config,{'Science'},'AcademyScienceConfig')
    update(config,{'SoliderSkill'},'SoliderSkillConfig')
    update(config,{'MoreInfo'}, 'MoreInfoConfig')
    update(config,{'HeroUI','Equip'},'HeroEquipConfig')
    update(config,{'HeroUI','Skill'},'HeroSkillConfig')
    

    for k,v in pairs(config['Building']) do
        local bu = {[1] = 'Building', [3] = 'LevelEffect'}
        local bm = {[1] = 'Building', [3] = 'MoreInfoCfg'} 
       	bu[2] = k
    	bm[2] = k
        update(config,bu,'BuildUpgradeConfig[' .. k .. ']')
        update(config,bm,'BuildMoreInfoCfg[' .. k .. ']')
    end

    local sf = setTable(desciption,tab,config, file)
    
    local content = {}
    
    local fp = io.open('app/components/language/languageMode.lua','r')
    if not fp then
        print("can't open file: app/components/language/languageMode.lua")
        os.exit(1)
    end
    for li in fp:lines() do
    	if string.find(li,'{') then
    		break
    	end
        if string.byte(li,1) ~= string.byte('',1) then
            content[#content +1] = li    		
    	end
    end
    fp:close()

    fp = io.open(sf,'r')
    if not fp then
        print("can't open file: " .. sf)
        os.exit(1)
    end
    for l in fp:lines() do
        if string.byte(l,1) ~= string.byte('',1) then
            local x = true 
            for k,v in pairs(targetValue)  do
                local b,e = string.find(l,v,1,true)
                if b then
                    content[#content+1] = string.sub(l,1,b-2) .. v ..','
                    table.remove(targetValue,k)
                    x = false
                    break
                end
            end
            if x then
                content[#content+1] = l
            end
        end
    end
    fp:close()
    
    fp = io.open(sf,'w')
    for k, v in pairs(content) do
        fp:write(v .. '\n')
    end
    fp:close()
end

local function setTableLc(desciption, config, tab, file)
    for _k, _v in pairs(config) do
        tab[string.gsub(_k, 'language_','')] = string.gsub(_v,'\n','\\n')
    end
    
    local keys = {}
    for k, v in pairs(tab) do
    	keys[#keys + 1] = k
        tab[k] = string.gsub(v,'\n','\\n')
    end
    table.sort(keys,function(x,y)
        x = string.gsub(x,'_+','')
        y = string.gsub(y,'_+','')
        x = string.upper(x)
        y = string.upper(y)
        return x < y
    end)
    
    local fp = io.open(tool.saveDir .. file .. '.lua','w')
    fp:write('local language = {')
    
    for k,v in pairs(keys) do
    	fp:write('\n\t'.. v .. ' = "' .. tab[v] .. '",')
    end
    
    fp:write('\n}\nreturn language')
    fp:close()

    print("save file " .. tool.saveDir .. file .. '.lua success !!')        
end


-------------------------------------------------------------------
--- 从文件更新当前配置到新文件
--@function [parent=#src.app.tools.tool] upDateTable
--@param arr table 源文件
--@param targetDir string 保存文件夹
--@param language string 翻译语言，不同文件区分后缀 
function tool.upDateTable(arr, targetDir, language)
    -- local arr = equire(originFile)
    tool.saveDir = targetDir .. '/'
    if language then
    	language = '_'..language
    else
        language = ''
    end
    local tab = {}
 
------------------------------------------------------------------
-- 将文件的内容转化为table
-- {
--      配置表 = {
--          [N] = {
--              [1] = {
--                  '*',
--              },
--              [2] = '翻译后的内容',
--          },
--      },
-- }
    for k, v in pairs(arr) do
        v = string.gsub( v, '%s+$', '\\n' )
    	local t = str_split(k,'_')
    	local key = t[1]
    	table.remove(t,1)
    	
    	tab[key] = tab[key] or {}
        if key == 'language' then
            tab[key][k]= v
        else
            tab[key][#tab[key] + 1]= {t,v}            
        end
    end

    for k,v in pairs(tab) do
        if k == 'languageMode' then
            setTableLM(k,v,languageMode,'languageMode')
        elseif k == 'SoliderSkill' then
            setTable(k, v, SoliderSkill,'SoliderSkillConfig')
        elseif k == 'MoreInfo' then
            setTable(k, v, MoreInfoConfig, 'MoreInfoConfig')
        elseif k == 'HeroSkill' then
            setTable(k,v, HeroSkillConfig,'HeroSkillConfig')
        elseif k == 'HeroEquip' then
            setTable(k,v, HeroEquipConfig,'HeroEquipConfig')
        elseif k == 'BagPackItem' then
            setTable(k,v, BagPackItemConfig,'BagPackItemConfig')
        elseif k == 'AcademyScience' then
            setTable(k,v, AcademyScienceConfig,'AcademyScienceConfig')
        elseif k == 'BuildUpgrade' then
            setTable(k,v, BuildUpgradeConfig,'BuildUpgradeConfig')
        elseif k == 'BuildMoreInfo' then
            setTable(k,v, BuildMoreInfoConfig,'BuildMoreInfoConfig')
        elseif k == 'language' then
            setTableLc(k,v, language_cn,'language')
        end
    end
end


function tool.tableSaveToFile(value, nesting, desciption, fileName)
    desciption = desciption or "var"
    if tool.saveDir then
        fileName = tool.saveDir .. fileName
    end
    
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            if v:byte(1) == string.byte('-',1) then
            	v = v:sub(2)
            elseif v:byte(1) == string.byte('+',1) then
                v = '[[' .. v:sub(2) .. ']]'
            else
                v = '"' .. v .. '"'            
            end
        elseif type(v) == 'function' then
            v = '""'
        end
        return tostring(v) .. ','
    end
    local function _k(v)
        if v == desciption then
        	return 'local ' .. v
        elseif type(v) == "string" then
            v = "['" .. v .. "']"
        elseif type(v) == "number" then
            v = '[' .. tostring(v) .. ']'
        end
        return tostring(v)
    end

    local function _dump(value, desciption, indent, nest, keylen)
              
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s = %s", indent, _k(desciption), _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s = *REF*", indent, desciption)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _k(desciption))
                local indent2 = indent.."\t"
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _k(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s},", indent)
            end
        end
    end
    _dump(value, desciption, "", 1)

    result[#result] = '}'
    result[#result + 1] = "return " .. desciption
    
    local fp = io.open(fileName,"w")
    if fp then
        for i, line in ipairs(result) do
            fp:write('\n' .. line)
        end
        fp:close()
    
        print("save file " .. fileName .. ' success !!')        
    end
    return fileName
end

function tool.compare(originFile,targetDir)
    local ftab = str_split(originFile, '|')
    local fromExcle, fromProject = ftab[1], ftab[2]
    fromExcle = require2(fromExcle)
    fromProject = require2(fromProject)
    for k,v in pairs(fromExcle) do
        fromExcle[k] = string.gsub( v, '%s+$', '\\n' )
    end
    local tab = {}
    for kp,vp in pairs(fromProject) do
        local b = true
        for ke,ve in pairs(fromExcle) do
            if ve and kp == ke and vp == ve then
                b = false
                fromExcle[ke] = nil
                break
            end
        end
        if b then
            tab[kp] = string.gsub(vp,'\n','\\n')
        end
    end
    tool.tableSaveToFile(tab,1,"language",targetDir)
end

return tool

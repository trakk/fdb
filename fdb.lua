-- fdb: streamlined cli budget management
-- Copyright (C) 2014 - 2015  David Ulrich
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
-- 
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "config"
require "fns"
require "types"

local driver = require "luasql.mysql"
local mysql = driver.mysql()
local conn = mysql:connect(config.database,config.user,config.pass,config.host)


local TT = types
local TS = subtypes


local S = {
	MENU = 0,
	VIEW = 1,
	CREATE = 2,
	MODIFY = 3,
	DELETE = 4,
	REPORT = 5
}
local state = S.MENU


local options = {}
options[S.VIEW] = { title = "View", action = "view" }
options[S.CREATE] = { title = "Create", action = "create"}
options[S.MODIFY] = { title = "Edit", action = "edit" }
options[S.DELETE] = { title = "Delete", action = "delete" }
options[S.REPORT] = { title = "Reporting", action = "report" }


local reports = require "reports"


function print_titles(tagline,table,xmsg)
	print(tagline)
	
	for i,t in ipairs(table) do
		print(i .. ": " .. t.title)
	end
		
	print(xmsg)
end


function print_options()
	print_titles("=== what would you like to do? ===",options,"x: exit\n")
end


function print_reports()
	print_titles(
		"=== which report would you like to view? ===",
		reports,
		"x: exit\n")
end


function print_types()
	print_titles(
		"=== what would you like to " .. options[state].action .. "? ===",
		TT,
		"x: back to options menu\n")
end


function type_view(t)
	local cur = conn:execute(select_fields(t))
	local res,out
	
	res = cur:fetch({})
	
	while res ~= nil do
		out = ""
		
		for i,v in ipairs(res) do
			out = out .. v .. " "
		end
		
		print(out)
		
		res = cur:fetch({})
	end
end


function delete_by_id(t,id)
	local query
	
	query = "DELETE FROM " .. TT[t].table .. where_id(t,id)
	
	conn:execute(query)
end


function get_field_values(t,type_t,title,id)
	local cur,res
	local query
	local out = {}
	
	print("=== " .. title .. " " .. type_t[t].title .. ": ===")
	
	if id then
		query = select_fields(t) .. where_id(t,id)
		cur = conn:execute(query)
		pre = cur:fetch({},"a")
	end
	
	for i,v in ipairs(type_t[t].names) do
		if v.type_t then
			type_view(v.type_t)
			print("n: Create New\n")
		end
		
		if id then
			io.write(v.title .. "(" .. pre[v.field] .. "): ")
		else
			io.write(v.title .. ": ")
		end
		
		out[v.field]= io.read()
		
		if out[v.field] == "" then
			out[v.field] = pre[v.field]
		end
		
		if v.type_t and new(out[v.field])  then
			out[v.field] = type_create(v.type_t)
		end
	end
	
	return out
end


function set_field_values(t,type_t,fv)
	local query
	local vhead = {}
	local vtail = {}
	
	for i,v in ipairs(type_t[t].names) do
		table.insert(vhead,v.field)
		table.insert(vtail,conn:escape(fv[v.field]))
	end
	
	if type_t[t].parent_id_field then
		table.insert(vhead,type_t[t].parent_id_field)
		table.insert(vtail,conn:escape(fv[type_t[t].parent_id_field]))
	end
	
	query = "INSERT INTO " .. type_t[t].table .. [[
		(`]] .. table.concat(vhead,"`,`") .. [[`)
		VALUES (']] .. table.concat(vtail,"','") .. "')"
	
	conn:execute(query);
	
	return conn:getlastautoid()
end


function update_field_values(t,type_t,fv,id)
	local query
	local vs = {}
	
	for i,v in ipairs(type_t[t].names) do
		table.insert(vs,"`" .. v.field .. "` = '" .. conn:escape(fv[v.field]) .. "'")
	end
	
	query = "UPDATE " .. type_t[t].table .. [[
		SET ]] .. table.concat(vs,",") .. where_id(t,id)
	
	conn:execute(query);
end


function type_create(t)
	local v,out
	
	print("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	print()
	
	v = get_field_values(t,TT,"New")
	
	out = set_field_values(t,TT,v)
	
	if TT[t].subtype then
		subtype_create(TT[t].subtype,out,v[TT[t].sum_field])
	end
	
	return out
end


function subtype_create(s,pid,sum)
	local v,s_field,sub_sum
	
	sum = number(sum)
	sub_sum = 0
	
	while sub_sum ~= sum do
		v = get_field_values(s,TS,"new")
		
		v[TS[s].parent_id_field] = pid;
		
		if all(v[TS[s].sum_field]) then
			v[TS[s].sum_field] = (sum - sub_sum)
		end
		
		sub_sum = sub_sum + v[TS[s].sum_field]
		
		set_field_values(s,TS,v)
	end
end


function type_edit(t)
	local i,n,v
	
	print("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	print()
	
	io.write("edit: ")
	
	i = io.read()
	
	n = number(i)
	
	v = get_field_values(t,TT,"Edit",n)
	
	update_field_values(t,TT,v,n)
end


function type_delete(t)
	local i,n
	
	print("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	print()
	
	io.write("delete: ")
	
	i = io.read()
	
	n = number(i)
	
	delete_by_id(t,n)
end


function state_view(t) -- type_view was useful in other places
	print("=== " .. TT[t].title .. " ===")
	type_view(t)
	print()
end


function report(r)
	local cur = conn:execute(reports[r].query)
	local res,out
	
	res = cur:fetch({})
	
	while res ~= nil do
		out = ""
		
		for i,v in ipairs(res) do
			out = out .. v .. " "
		end
		
		print(out)
		
		res = cur:fetch({})
	end
end


local input,ninput

print "fdb: streamlined cli budget management (v1.0.1)"
print_options()

while true do
	io.write("option: ")
	input = io.read()
	ninput = number(input)
	print()
	
	if state == S.MENU then -- options menu
		if quit(input) then
			break
		elseif between(ninput,1,#options) then
			state = ninput
		end
	elseif state == S.REPORT then -- reporting
		if quit(input) then
			state = S.MENU;
		elseif between(ninput,1,#reports) then
			report(ninput)
			print()
		end
	else
		if quit(input) then
			state = S.MENU
		elseif between(ninput,1,#types) then
			if state == S.VIEW then state_view(ninput)
			elseif state == S.CREATE then type_create(ninput)
			elseif state == S.MODIFY then type_edit(ninput)
			elseif state == S.DELETE then type_delete(ninput)
			end
		end
	end
	
	if state == S.MENU then print_options()
	elseif state == S.REPORT then print_reports()
	else print_types()
	end
end


conn:close()
mysql:close()


print "done"

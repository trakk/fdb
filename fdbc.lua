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

local title = "fdb: streamlined cli budget management (v1.1.2)"
local sep_s = "==============================================="

require "config"
require "fns"
require "types"

local curses = require "curses"
local scr = curses.initscr()

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


local Y,X
Y = 0
X = 0

function cprint(str)
	str = str or ""
	
	scr:clrtoeol()
	scr:addstr(str)
end

function cnprint(str)
	cprint(str)
	
	scr:move(Y + 1,0)
	
	Y,X = scr:getyx()
end

function mprint(str)
	local y,x,t
	
	y,x = scr:getmaxyx()
	
	scr:move(y - 1,0)
	
	cprint(str)
end

local function rcnprint(str)
	scr:move(Y,X)
	
	cnprint(str)
end

local function redraw()
	scr:clear()
	cnprint(title)
	
	Y = 2
	X = 0
	
	scr:move(Y,X)
end


function print_titles(tagline,table,xmsg)
	cnprint(tagline)
	
	for i,t in ipairs(table) do
		cnprint(i .. ": " .. t.title)
	end
		
	cnprint(xmsg)
end


function print_options()
	print_titles("=== what would you like to do? ===",options,"x: exit")
end


function print_reports()
	print_titles(
		"=== which report would you like to view? ===",
		reports,
		"x: exit")
end


function print_types()
	print_titles(
		"=== what would you like to " .. options[state].action .. "? ===",
		TT,
		"x: back to options menu")
end


function type_view(t)
	local query,fields,titles
	query,fields,titles = select_fields(t)
	
	local cur = conn:execute(query)
	local res,out,sep
	
	res = cur:fetch({})
	
	out = ""
	sep = ""
	
	for i,v in ipairs(fields) do
		out = out .. format_field(v,titles[i]) .. " "
		sep = sep .. format_field(v,sep_s) .. " "
	end
	
	cnprint(out)
	cnprint(sep)
	
	while res ~= nil do
		out = ""
		
		for i,v in pairs(res) do
			out = out .. format_field(fields[i],v) .. " "
		end
		
		cnprint(out)
		
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
	local pre = {}
	local query
	local out = {}
	
	cnprint("=== " .. title .. " " .. type_t[t].title .. ": ===")
	
	if id then
		query = select_fields(t) .. where_id(t,id)
		cur = conn:execute(query)
		pre = cur:fetch({},"a")
	end
	
	for i,v in ipairs(type_t[t].names) do
		if v.type_t then
			type_view(v.type_t)
			cnprint("n: Create New")
		end
		
		if id then
			mprint(v.title .. "(" .. pre[v.field] .. "): ")
		elseif v.default then
			mprint(v.title .. "(" .. v.default .. "): ")
		else
			mprint(v.title .. ": ")
		end
		
		out[v.field]= scr:getstr()
		
		if out[v.field] == "" and id then
			out[v.field] = pre[v.field]
		elseif out[v.field] == "" and v.default then
			out[v.field] = v.default
		end
		
		rcnprint(v.title .. ": " .. out[v.field])
		
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
	
	cnprint("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	cnprint()
	
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
	
	cnprint("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	
	mprint("edit: ")
	
	i = scr:getstr()
	
	n = number(i)
	
	v = get_field_values(t,TT,"Edit",n)
	
	update_field_values(t,TT,v,n)
end


function type_delete(t)
	local i,n
	
	cnprint("=== existing " .. TT[t].title .. " ===")
	type_view(t)
	
	mprint("delete: ")
	
	i = scr:getstr()
	
	n = number(i)
	
	delete_by_id(t,n)
end


function state_view(t) -- type_view was useful in other places
	cnprint("=== " .. TT[t].title .. " ===")
	cnprint()
	
	type_view(t)
end


function report(r)
	local fields = reports[r].fields
	local titles = reports[r].titles
	local cur = conn:execute(reports[r].query)
	local res,out,sep
	
	res = cur:fetch({})
	
	cnprint("=== " .. reports[r].title .. " Report ===")
	cnprint()
	
	out = ""
	sep = ""
	
	for i,v in ipairs(fields) do
		out = out .. format_field(v,titles[i]) .. " "
		sep = sep .. format_field(v,sep_s) .. " "
	end
	
	cnprint(out)
	cnprint(sep)
	
	while res ~= nil do
		out = ""
		
		for i,v in ipairs(res) do
			out = out .. format_field(fields[i],v) .. " "
		end
		
		cnprint(out)
		
		res = cur:fetch({})
	end
end


local function main()
	local catch
	local input,ninput

	curses.cbreak()
	curses.echo(0)
	curses.nl(0)

	redraw()
	print_options()

	while true do
		catch = false
		
		mprint("option: ")
		
		input = scr:getch()
		if input < 256 then input = string.char(input) end
		ninput = number(input)
		
		redraw()
		
		if state == S.MENU then -- options menu
			if quit(input) then
				curses.endwin()
				break
			elseif between(ninput,1,#options) then
				state = ninput
			end
		elseif state == S.REPORT then -- reporting
			if quit(input) then
				state = S.MENU;
			elseif between(ninput,1,#reports) then
				catch = true
				report(ninput)
			end
		else
			if quit(input) then
				state = S.MENU
			elseif between(ninput,1,#types) then
				catch = true
				
				if state == S.VIEW then state_view(ninput)
				elseif state == S.CREATE then type_create(ninput)
				elseif state == S.MODIFY then type_edit(ninput)
				elseif state == S.DELETE then type_delete(ninput)
				end
			end
		end
		
		if catch then
			mprint("continue...")
			scr:getch()
		end
		
		redraw()
		
		if state == S.MENU then print_options()
		elseif state == S.REPORT then print_reports()
		else print_types()
		end
	end


	conn:close()
	mysql:close()
end


local function err (err)
  curses.endwin ()
  print "Caught an error:"
  print (debug.traceback (err, 2))
  os.exit (2)
end

xpcall(main,err)

cnprint "done"

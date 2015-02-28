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

local driver = require "luasql.mysql"
local mysql = driver.mysql()
local conn = mysql:connect(config.database,config.user,config.pass,config.host)


local state = 0

local options = {
	{ title = "View", action = "view" },
	{ title = "Create New", action = "create"},
	{ title = "Edit / Delete", action = "edit or delete" },
	{ title = "Reporting", action = "report" }
}

local types = {
	{ title = "Accounts", table = "accounts" },
	{ title = "Allocations", table = "allocations" },
	{ title = "Categories", table = "categories" },
	{ title = "Transactions", table = "transactions" },
	{ title = "Vendors", table = "vendors" }
}

local reports = {
	{
		title = "Balances",
		query = [[
			SELECT SUM(T.TransactionAmount) AS Balance,A.AccountName
			FROM transactions T
			LEFT JOIN accounts A ON T.AccountID = A.AccountID
			GROUP BY T.AccountID
		]]
	}
}


function print_titles(tagline,table,xmsg)
	print(tagline)
	
	for i,t in ipairs(table) do
		print(i .. ": " .. t.title)
	end
		
	print(xmsg)
end


function print_options()
	print_titles("=== what would you like to do? ===",options,"x: exit")
end


function print_reports()
	print_titles("=== which report would you like to view? ===",reports,"x: exit")
end


function print_types()
	print_titles(
		"=== what would you like to " .. options[state].action .. "? ===",
		types,
		"x: back to options menu")
end


function type_view(t)
	local cur = conn:execute("SELECT * FROM " .. types[t].table)
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


function type_create(t)
	print "STUB: type_create"
end


function type_edit(t)
	print "STUB: type_edit"
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

print "fdb: streamlined cli budget management"
print_options()

while true do
	input = io.read()
	ninput = tonumber(input,10) or 0
	
	if state == 0 then -- options menu
		if quit(input) then
			break
		elseif between(ninput,1,#options) then
			state = ninput
		end
	elseif state == 4 then -- reporting
		if quit(input) then
			state = 0;
		elseif between(ninput,1,#reports) then
			report(ninput)
		end
	else
		if quit(input) then
			state = 0
		elseif between(ninput,1,#types) then
			if state == 1 then type_view(ninput)
			elseif state == 2 then type_create(ninput)
			elseif state == 3 then type_edit(ninput)
			end
		end
	end
	
	if state == 0 then
		print_options()
	elseif state == 4 then
		print_reports()
	else
		print_types()
	end
end


conn:close()
mysql:close()


print "done"

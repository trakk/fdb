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

local driver = require "luasql.mysql"
local mysql = driver.mysql()
local conn = mysql:connect(config.database,config.user,config.pass,config.host)


local state = 0

local options = {
	{ title = "Report / View", action = "view" },
	{ title = "Create New", action = "create"},
	{ title = "Edit / Delete", action = "edit or delete" }
}

local types = {
	{ title = "Accounts", table = "accounts" },
	{ title = "Allocations", table = "allocations" },
	{ title = "Categories", table = "categories" },
	{ title = "Transactions", table = "transactions" },
	{ title = "Vendors", table = "vendors" }
}


function print_options()
	print "=== what would you like to do? ==="
	
	for i,option in ipairs(options) do
		print(i .. ": " .. option.title)
	end
	
	print "x: exit"
end


function print_types()
	print("=== what would you like to " .. options[state].action .. "? ===")
	
	for i,t in ipairs(types) do
		print(i .. ": " .. t.title)
	end
	
	print "x: back to options menu"
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
	print "STUB"
end


function type_edit(t)
	print "STUB"
end


local input,ninput

print "fdb: streamlined cli budget management"
print_options()

while true do
	input = io.read()
	ninput = tonumber(input,10) or 0
	
	if state == 0 then
		if input == "x" or input == "X" then
			break
		elseif ninput >= 1 and ninput <= #options then
			state = ninput
		end
	else
		if input == "x" or input == "X" then
			state = 0
		elseif ninput >= 1 and ninput <= #types then
			if state == 1 then type_view(ninput)
			elseif state == 2 then type_create(ninput)
			elseif state == 3 then type_edit(ninput)
			end
		end
	end
	
	if state == 0 then
		print_options()
	else
		print_types()
	end
end


conn:close()
mysql:close()


print "done"

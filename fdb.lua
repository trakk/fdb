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


local T = {
	NONE = 0,
	ACCOUNTS = 1,
	ALLOCATIONS = 2,
	CATEGORIES = 3,
	TRANSACTIONS = 4,
	VENDORS = 5,
	ALLOCATION_ITEMS = 6,
	LINE_ITEMS = 7
}

local types = {}
types[T.ACCOUNTS] = {
	title = "Accounts",
	table = "accounts",
	id_field = "AccountID",
	names = {
		{ title = "Name", field = "AccountName" }
	}
}
types[T.ALLOCATIONS] = {
	title = "Allocations",
	table = "allocations",
	id_field = "AllocationID",
	names = {
		{ title = "Name", field = "AllocationName" }
	}
}
types[T.CATEGORIES] = {
	title = "Categories",
	table = "categories",
	id_field = "CategoryID",
	names = {
		{ title = "Name", field = "CategoryName" }
	}
}
types[T.TRANSACTIONS] = {
	title = "Transactions",
	table = "transactions",
	id_field = "TransactionID",
	names = {
		{ title = "Name", field = "TransactionName" },
		{ title = "Date", field = "TransactionDate" },
		{ title = "Amount", field = "TransactionAmount" },
		{
			title = "Account",
			field = "AccountID",
			table = "accounts",
			type_t = T.ACCOUNTS
		},
		{
			title = "Vendor",
			field = "VendorID",
			table = "vendors",
			type_t = T.VENDORS
		}
	}
}
types[T.VENDORS] = {
	title = "Vendors",
	table = "vendors",
	id_field = "VendorID",
	names = {
		{ title = "Name", field = "VendorName" }
	}
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
		types,
		"x: back to options menu\n")
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


function delete_by_id(t,id)
	local query
	
	query = "DELETE FROM " .. types[t].table .. [[
		WHERE ]] .. types[t].id_field .. " = " .. id
	
	conn:execute(query)
end


function get_field_values(t)
	local out = {}
	
	print("=== New " .. types[t].title .. ": ===")
	
	for i,v in ipairs(types[t].names) do
		if v.type_t then type_view(v.type_t) end
		
		io.write(v.title .. ": ")
		
		out[v.field]= io.read()
	end
	
	return out
end


function set_field_values(t,fv)
	local query
	local vhead = {}
	local vtail = {}
	
	for i,v in ipairs(types[t].names) do
		table.insert(vhead,v.field)
		table.insert(vtail,conn:escape(fv[v.field]))
	end
	
	query = "INSERT INTO " .. types[t].table .. [[
		(`]] .. table.concat(vhead,"`,`") .. [[`)
		VALUES (']] .. table.concat(vtail,"','") .. "')"
	
	conn:execute(query);
end


function type_create(t)
	local v
	
	print("=== existing " .. types[t].title .. " ===")
	type_view(t)
	print()
	
	v = get_field_values(t)
	
	set_field_values(t,v)
end


function type_edit(t)
	print "STUB: type_edit"
end


function type_delete(t)
	local i,n
	
	print("=== existing " .. types[t].title .. " ===")
	type_view(t)
	print()
	
	io.write("delete: ")
	
	i = io.read()
	
	n = number(i)
	
	delete_by_id(t,n)
end


function state_view(t) -- type_view was useful in other places
	print("=== " .. types[t].title .. " ===")
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

print "fdb: streamlined cli budget management"
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

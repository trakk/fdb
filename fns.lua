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

function between(n,a,b)
	n = number(n)
	a = number(a)
	b = number(b)
	
	return (n >= a and n <= b)
end


function number(n)
	return tonumber(n,10) or 0
end


function all(input)
	return (input == "a" or input == "A")
end


function new(input)
	return (input == "n" or input == "N")
end


function quit(input)
	return (input == "x" or input == "X")
end


function format_field(k,v)
	local disp = display[k]
	local ds = ""
	
	if not disp then return v end
	
	if disp.align == A.LEFT then
		ds = "%-" .. disp.right .. "." .. disp.right .. "s"
	elseif disp.align == A.RIGHT then
		ds = "%" .. disp.left .. "." .. disp.left .. "s"
	else
		ds = "%s"
	end
		
	return string.format(ds,v)
end


-- SQL Helpers
function select_fields(t)
	local fields = {}
	local raw_fields = {}
	local joins = {}
	local query = ""
	
	table.insert(raw_fields,types[t].id_field)
	table.insert(fields,sql_field(types[t].id_field,types[t].sql_id))
	
	for i,v in ipairs(types[t].names) do
		if v.type_t then
			table.insert(raw_fields,types[v.type_t].names[1].field)
			table.insert(fields,sql_field(
				types[v.type_t].names[1].field,
				types[v.type_t].sql_id
			))
			table.insert(joins,sql_join(
				types[v.type_t].table,
				types[v.type_t].sql_id,
				types[t].sql_id,
				v.field
			))
		else
			table.insert(raw_fields,v.field)
			table.insert(fields,sql_field(v.field,types[t].sql_id))
		end
	end
	
	query = "SELECT " .. table.concat(fields,",") .. [[
		FROM ]] .. types[t].table .. " " .. types[t].sql_id .. [[
		]] .. table.concat(joins,"\n") .. " ORDER BY " .. types[t].id_field
	
	return query, raw_fields
end


function sql_field(name,letter)
	return letter .. ".`" .. name .. "`"
end


function sql_join(table,l1,l2,field)
	return " LEFT JOIN `" .. table .. "` " .. l1 .. " ON " .. l1 .. ".`" .. field .. "` = " .. l2 .. ".`" .. field .. "` "
end


function where_id(t,id)
	return " WHERE `" .. types[t].id_field .. "` = " .. number(id)
end

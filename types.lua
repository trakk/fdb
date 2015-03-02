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

T = {
	NONE = 0,
	ACCOUNTS = 1,
	ALLOCATIONS = 2,
	CATEGORIES = 3,
	TRANSACTIONS = 4,
	VENDORS = 5,
	ALLOCATION_ITEMS = 6,
	LINE_ITEMS = 7
}

types = {}
types[T.ACCOUNTS] = {
	title = "Accounts",
	table = "accounts",
	sql_id = "A",
	id_field = "AccountID",
	names = {
		{ title = "Name", field = "AccountName" }
	}
}
types[T.ALLOCATIONS] = {
	title = "Allocations",
	table = "allocations",
	sql_id = "L",
	id_field = "AllocationID",
	names = {
		{ title = "Name", field = "AllocationName" }
	}
}
types[T.CATEGORIES] = {
	title = "Categories",
	table = "categories",
	sql_id = "C",
	id_field = "CategoryID",
	names = {
		{ title = "Name", field = "CategoryName" }
	}
}
types[T.TRANSACTIONS] = {
	title = "Transactions",
	table = "transactions",
	sql_id = "T",
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
	sql_id = "V",
	id_field = "VendorID",
	names = {
		{ title = "Name", field = "VendorName" }
	}
}

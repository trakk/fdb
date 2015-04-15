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

A = {
	LEFT = 1,
	RIGHT = 2,
	CENTER = 3
}

display = {
	AccountID = {
		align = A.RIGHT,
		left = 2,
		right = 0
	},
	AccountName = {
		align = A.LEFT,
		left = 0,
		right = 16
	},
	AllocationItemAmount = {
		align = A.RIGHT,
		left = 10,
		right = 0
	},
	AllocationItemRemainder = {
		align = A.RIGHT,
		left = 2,
		right = 0
	},
	AllocationName = {
		align = A.LEFT,
		left = 0,
		right = 32
	},
	Balance = {
		align = A.RIGHT,
		left = 10,
		right = 0
	},
	CategoryID = {
		align = A.RIGHT,
		left = 2,
		right = 0
	},
	CategoryName = {
		align = A.LEFT,
		left = 0,
		right = 16
	},
	LineItemAmount = {
		align = A.RIGHT,
		left = 10,
		right = 0
	},
	TransactionAmount = {
		align = A.RIGHT,
		left = 10,
		right = 0
	},
	TransactionID = {
		align = A.RIGHT,
		left = 3,
		right = 0
	},
	TransactionDate = {
		align = A.RIGHT,
		left = 10,
		right = 0
	},
	TransactionName = {
		align = A.LEFT,
		left = 0,
		right = 32
	},
	VendorID = {
		align = A.RIGHT,
		left = 2,
		right = 0
	},
	VendorName = {
		align = A.LEFT,
		left = 0,
		right = 24
	}
}

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
		{
			title = "Name",
			field = "AccountName"
		}
	}
}
types[T.ALLOCATIONS] = {
	title = "Allocations",
	table = "allocations",
	sql_id = "L",
	subtype = T.ALLOCATION_ITEMS,
	sum_field = "Unlimited",
	id_field = "AllocationID",
	names = {
		{
			title = "Name",
			field = "AllocationName"
		}
	}
}
types[T.CATEGORIES] = {
	title = "Categories",
	table = "categories",
	sql_id = "C",
	id_field = "CategoryID",
	names = {
		{
			title = "Name",
			field = "CategoryName"
		}
	}
}
types[T.TRANSACTIONS] = {
	title = "Transactions",
	table = "transactions",
	sql_id = "T",
	subtype = T.LINE_ITEMS,
	sum_field = "TransactionAmount",
	id_field = "TransactionID",
	names = {
		{
			title = "Date",
			field = "TransactionDate",
			default = os.date("%Y-%m-%d")
		},
		{
			title = "Amount",
			field = "TransactionAmount"
		},
		{
			title = "Name",
			field = "TransactionName"
		},
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
		{
			title = "Name",
			field = "VendorName"
		}
	}
}

subtypes = {}
subtypes[T.LINE_ITEMS] = {
	title = "Line Items",
	table = "line_items",
	sql_id = "I",
	id_field = "LineItemID",
	parent_id_field = "TransactionID",
	sum_field = "LineItemAmount",
	names = {
		{
			title = "Category",
			field = "CategoryID",
			table = "categories",
			type_t = T.CATEGORIES
		},
		{
			title = "Amount",
			field = "LineItemAmount"
		}
	}
}
subtypes[T.ALLOCATION_ITEMS] = {
	title = "Allocation Items",
	table = "allocation_items",
	sql_id = "O",
	id_field = "AllocationItemID",
	parent_id_field = "AllocationID",
	sum_field = "AllocationItemAmount",
	names = {
		{
			title = "Category",
			field = "CategoryID",
			table = "categories",
			type_t = T.CATEGORIES
		},
		{
			title = "Amount",
			field = "AllocationItemAmount"
		},
		{
			title = "Remainder?",
			field = "AllocationItemRemainder"
		}
	}
}

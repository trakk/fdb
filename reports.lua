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

local reports = {
	{
		title = "Balances",
		query = [[
			SELECT SUM(T.TransactionAmount) AS Balance,A.AccountName
			FROM transactions T
			LEFT JOIN accounts A ON T.AccountID = A.AccountID
			GROUP BY T.AccountID
		]]
	},
	{
		title = "Categories",
		query = [[
			SELECT SUM(TI.LineItemAmount) AS Balance,C.CategoryName
			FROM line_items TI
			LEFT JOIN categories C ON TI.CategoryID = C.CategoryID
			GROUP BY TI.CategoryID
		]]
	},
	{
		title = "Last Transactions",
		query = [[
			SELECT
				T.TransactionID,
				T.TransactionName,
				T.TransactionDate,
				T.TransactionAmount,
				A.AccountName,
				V.VendorName
			FROM transactions T
			LEFT JOIN accounts A ON T.AccountID = A.AccountID
			LEFT JOIN vendors V ON T.VendorID = V.VendorID
			WHERE T.TransactionID IN (
				SELECT MAX(R.TransactionID) AS TransactionID
				FROM transactions R
				GROUP BY R.AccountID
			)
		]]
	}
}

return reports
-- fdb: streamlined cli budget management
-- Copyright (C) 2014 - 2015  David Ulrich
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published
-- by the Free Software Foundation, version 3 of the License.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
-- 
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

CREATE DATABASE IF NOT EXISTS fdb;
USE fdb;


-- 'real' accounts
CREATE TABLE IF NOT EXISTS accounts (
	AccountID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AccountName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT IGNORE INTO accounts (`AccountID`,`AccountName`) VALUES
	(1,'Bank'),
	(2,'VISA'),
	(3,'AMEX'),
	(4,'Retirement');


-- a single entry in an actual account
CREATE TABLE IF NOT EXISTS transactions (
	TransactionID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	TransactionName VARCHAR(128) NOT NULL DEFAULT '',
	TransactionDate DATE NOT NULL DEFAULT 0,
	TransactionAmount DECIMAL(9,2) NOT NULL DEFAULT 0.00,
	AccountID INT NOT NULL,
	VendorID INT NOT NULL
) ENGINE=InnoDB;


-- budgeting categories, with a tracked balance
CREATE TABLE IF NOT EXISTS categories (
	CategoryID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	CategoryName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT IGNORE INTO categories (`CategoryID`,`CategoryName`) VALUES
	(1,'Savings'),
	(2,'MTI'),
	(3,'Utilities'),
	(4,'Household'),
	(5,'Transportation'),
	(6,'Textiles'),
	(7,'Discretionary');


-- vendors 
CREATE TABLE IF NOT EXISTS vendors (
	VendorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	VendorName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT IGNORE INTO vendors (`VendorID`,`VendorName`) VALUES
	(1,'Kroger'),
	(2,'Amazon'),
	(3,'Costco'),
	(4,'Home Depot'),
	(5,'NES'),
	(6,'Metro Water');


-- part or all of a transaction, sent to a category
CREATE TABLE IF NOT EXISTS line_items (
	LineItemID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	LineItemAmount DECIMAL(9,2) NOT NULL DEFAULT 0,
	TransactionID INT NOT NULL,
	CategoryID INT NOT NULL
) ENGINE=InnoDB;


-- description of how to split a transaction across categories,
-- as a shortcut for repeating entries (paycheck, mortgage, Utilities, etc)
CREATE TABLE IF NOT EXISTS allocations (
	AllocationID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AllocationName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS allocation_items (
	AllocationItemID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AllocationItemAmount DECIMAL(9,2) NOT NULL DEFAULT 0,
	AllocationRemainder BOOLEAN NOT NULL DEFAULT FALSE,
	AllocationID INT NOT NULL,
	CategoryID INT NOT NULL
) ENGINE=InnoDB;

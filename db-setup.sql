DROP DATABASE IF EXISTS fdb;
CREATE DATABASE fdb;
USE fdb;


-- 'real' accounts
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
	AccountID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AccountName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT INTO accounts (`AccountID`,`AccountName`) VALUES
	(1,'Bank'),
	(2,'VISA'),
	(3,'AMEX'),
	(4,'Retirement');


-- a single entry in an actual account
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
	TransactionID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	TransactionName VARCHAR(128) NOT NULL DEFAULT '',
	TransactionDate DATE NOT NULL DEFAULT 0,
	TransactionAmount DECIMAL(9,2) NOT NULL DEFAULT 0.00,
	AccountID INT NOT NULL,
	VendorID INT NOT NULL
) ENGINE=InnoDB;


-- budgeting categories, with a tracked balance
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
	CategoryID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	CategoryName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT INTO categories (`CategoryID`,`CategoryName`) VALUES
	(1,'Savings'),
	(2,'MTI'),
	(3,'Utilities'),
	(4,'Household'),
	(5,'Transportation'),
	(6,'Textiles'),
	(7,'Discretionary');


-- vendors 
DROP TABLE IF EXISTS vendors;
CREATE TABLE vendors (
	VendorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	VendorName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

INSERT INTO vendors (`VendorID`,`VendorName`) VALUES
	(1,'Kroger'),
	(2,'Amazon'),
	(3,'Costco'),
	(1,'Home Depot'),
	(2,'NES'),
	(3,'Metro Water');


-- part or all of a transaction, sent to a category
DROP TABLE IF EXISTS line_items;
CREATE TABLE line_items (
	LineItemID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	LineItemAmount DECIMAL(9,2) NOT NULL DEFAULT 0,
	TransactionID INT NOT NULL,
	CategoryID INT NOT NULL
) ENGINE=InnoDB;


-- description of how to split a transaction across categories,
-- as a shortcut for repeating entries (paycheck, mortgage, Utilities, etc)
DROP TABLE IF EXISTS allocations;
CREATE TABLE allocations (
	AllocationID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AllocationName VARCHAR(128) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

DROP TABLE IF EXISTS allocation_items;
CREATE TABLE allocation_items (
	AllocationItemID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	AllocationItemAmount DECIMAL(9,2) NOT NULL DEFAULT 0,
	AllocationRemainder BOOLEAN NOT NULL DEFAULT FALSE,
	AllocationID INT NOT NULL,
	CategoryID INT NOT NULL
) ENGINE=InnoDB;

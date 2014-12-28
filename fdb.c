// fdb: streamlined cli budget management
// Copyright (C) 2014 David Ulrich
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// 
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <my_global.h>
#include <mysql.h>

#include <readline/readline.h>
#include <readline/history.h>


#include "config.h" // make sure your config contains the correct values


#define FDB_MENU_MAIN     0
#define FDB_MENU_REPORT   1
#define FDB_MENU_CATEGORY 2


/* ===== MYSQL HELPER FNS ===== */
int fdb_mysql_close();
int fdb_mysql_error();
int fdb_mysql_query(char* query);
MYSQL_RES* fdb_mysql_query_res(char* query);

MYSQL* fdb_conn;

int fdb_mysql_close() {
	mysql_close(fdb_conn);
	fdb_conn = NULL;
	return 0;
}

int fdb_mysql_error() {
	if (fdb_conn == NULL) return 1;
	
	fprintf(stderr, "%s\n", mysql_error(fdb_conn));
	return 1;
}

int fdb_mysql_query(char* query) {
	MYSQL_RES* result = fdb_mysql_query_res(query);
	
	if (result != NULL) mysql_free_result(result);
	
	return 0;
}

MYSQL_RES* fdb_mysql_query_res(char* query) {
	if (fdb_conn == NULL) {
		fdb_conn = mysql_init(NULL);
	
		if (fdb_conn == NULL) {
			fprintf(stderr, "%s\n", mysql_error(fdb_conn));
			return NULL;
		}
		
		if (mysql_real_connect(fdb_conn,FDB_DB_HOST,FDB_DB_USER,FDB_DB_PASS,FDB_DB_NAME,0,NULL,0) == NULL) {
			fdb_mysql_error(fdb_conn);
			return NULL;
		}
	}
	
	if (mysql_query(fdb_conn, query)) {
		fdb_mysql_error(fdb_conn);
		return NULL;
	}
	
	MYSQL_RES* result = mysql_store_result(fdb_conn);
	
	if (result == NULL) {
		fdb_mysql_error(fdb_conn);
	}
	
	return result;
}




/* ===== REGULAR HELPER FNS ===== */
void print_option_list(const char** list, int length);
void print_options();
void print_report_options();
void print_types();


/*
 * 1) report / view options
 *  c: view type data (types)
 *  r: category report
 *  s: summary report
 * 2) create options
 *  (types)
 * 3) edit / delete options
 *  (types)
 * 
 * types:
 *  1: accounts
 *  2: transactions
 *  3: categories
 *  4: vendors
 *  5: allocations
 */


int FDB_MENU_STATE = FDB_MENU_MAIN;

const char* NAME_OPTION[] = {
	"Report / View",
	"Create New",
	"Edit / Delete"
};

const char* NAME_TYPE[] = {
	"Accounts",
	"Allocations",
	"Categories",
	"Transactions",
	"Vendors"
};


int do_input() {
	char input = getchar();
	
	switch(input) {
		case 'x':
			printf("got x\n");
			return 0;
			break;
			
		case '1':
			printf("report / view\n");
			print_report_options();
			// noop
			
			break;
		
		case '2':
			printf("create new\n");
			print_types();
			// noop
			
			break;
		
		case '3':
			printf("edit / delete\n");
			print_types();
			// noop
			
			break;
		
		case 10:
			// newline
			break;
		
		default:
			print_options();
	}
	
	return 1;
}

void print_option_list(const char ** list, int length) {
	int i;
	
	for(i=0;i<length;i++) printf("%d: %s, ",i+1,list[i]);
	
	printf("x: exit\n");
}

void print_options() {
	print_option_list(NAME_OPTION,3);
}

void print_report_options() {
	printf("c: view type data, r: category report, s: summary report, x: exit\n");
}

void print_types() {
	print_option_list(NAME_TYPE,5);
}




/* ===== MAIN ===== */
int main(/*int argc,char* argv[]*/) {
// 	printf("MySQL client version: %s\n", mysql_get_client_info());
	
	print_options();
	while(do_input()) {}
	
// 	fdb_mysql_close();
	
	return 0;
}

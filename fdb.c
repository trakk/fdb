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
void print_options();

int do_input() {
	char input = getchar();
	
	switch(input) {
		case 'x':
			printf("got x\n");
			return 0;
			break;
			
		case '1':
			printf("showing balance\n");
			// noop
			
			break;
		
		case '2':
			printf("adding debit or credit\n");
			// noop
			
			break;
		
		case '3':
			printf("creating budget\n");
			// noop
			
			break;
			
		default:
			print_options();
	}
	
	return 1;
}

void print_options() {
	printf("1: view balance, 2: add debit or credit, 3: create budget, x: exit\n");
}




/* ===== MAIN ===== */
int main(/*int argc,char* argv[]*/) {
// 	printf("MySQL client version: %s\n", mysql_get_client_info());
	
	print_options();
	while(do_input()) {}
	
// 	fdb_mysql_close();
	
	return 0;
}

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


#include <stdio.h>


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

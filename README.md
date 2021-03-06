# fdb

fdb: streamlined cli budget management


# setup

* `db-setup.sql` has schema and some sample db values.
* copy `config.example.lua` to `config.lua` and set credentials.
* install `lua-sql-mysql` package or equivalent [LuaSQL](http://keplerproject.github.io/luasql/doc/us/index.html)
* install `lua-curses` package, or equivalent [LuaCurses](http://luaposix.github.io/luaposix/modules/posix.curses.html)
* run the script via `./run` or `lua fdb.lua` or `luajit fdb.lua`

NB: the `lua-*` packages are available on trusty but not earlier versions

# reports

Current reports:
* Balances -- summary of current balance, by Account
* Categories -- summary of current balance, by Category
* Last Transactions -- most recent transaction for each Account
* Monthly Net -- compare allocation and spend by Category, by Month

Planned reports:
* Savings Rate -- previous 1, 3, 6, 12 months
* Projections


# license

fdb (C) 2014 - 2016  David Ulrich (http://github.com/dulrich)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

function t = tables(c)
%TABLES Table names from Kx Systems kdb+.
%   T = TABLES(K) returns the list of tables for the Kx kdb+ connection.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt, the table information for a Kx kdb+ database can be
%   found with the commands
%
%   K = KX('localhost',5001);
%   T = TABLES(K)
%
%   which returns
%
%   T = 
%
%     'seclist'
%     'trade'
%
%   See also EXEC, FETCH, INSERT, KX.

%   Copyright 1999-2008 The MathWorks, Inc.

%Connection handle
kHandle = c.handle;

%Get tables in database
t = cellstr(char(kHandle.k('tables`.')));

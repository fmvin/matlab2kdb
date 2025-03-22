function x = insert(c,tablename,writedata,sync)
%INSERT Write data to Kx Systems kdb+.
%   INSERT(K,TABLENAME,DATA) writes the data, DATA, to the Kx kdb+ table,
%   TABLENAME, asynchronously.
%
%   X = INSERT(K,TABLENAME,DATA,SYNC) writes the data, DATA, to the Kx kdb+ table,
%   TABLENAME, synchronously.   For asynchronous calls, enter SYNC as 0
%   (default), and for synchronous calls, enter SYNC as 1.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt, the command
%
%   K = KX('localhost',5001);
%   INSERT(K,'trade',{'`ACME',100.45,400,.0453,'2005.04.28'})
%
%   write the given data to the table TRADE.
%
%   See also FETCH, KX.

%   Copyright 1999-2015 The MathWorks, Inc.

%writedata must be a cell array, do conversion if possible
if isnumeric(writedata)
  writedata = num2cell(writedata);
elseif ischar(writedata) || isstring(writedata)
  writedata = cellstr(writedata);
end

%Build Kx kdb+ command and execute 
for i = 1:size(writedata,1)

  %Tablename and insert call
  kdbcommand = ['`' char(tablename) ' insert ('];

  for j = 1:size(writedata,2)
    
    switch class(writedata{i,j})
      
      case {'char','string'}
    
        kdbcommand = [char(kdbcommand) char(sprintf('%s',writedata{i,j})) ';'];
      
      otherwise

        if (mod(writedata{i,j},1) == 0)
          kdbcommand = [char(kdbcommand) char(sprintf('%d',writedata{i,j})) ';'];
        else
          kdbcommand = [char(kdbcommand) char(sprintf('%f',writedata{i,j})) ';']; 
        end
    end
    
  end
  
  %Execute command, asynchronously or synchronously
  kdbcommand(end) = ')';
  
  %parse sync flag, default is run commands asynchronously
  if exist('sync','var') && any(sync)
    x = c.handle.k(kdbcommand);
  else
    c.handle.ks(kdbcommand);
    if nargout > 0
      x = [];
    end
  end
  
end

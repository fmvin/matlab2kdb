function x = exec(c,varargin)
%EXEC Execute Kx Systems kdb+ command.
%   EXEC(K,COMMAND) executes the given COMMAND in Kx kdb+ without waiting for
%   a response.
%
%   EXEC(K,COMMAND,P1) execute the given COMMAND with one input parameter
%   without waiting for a response.
%
%   EXEC(K,COMMAND,P1,P2) execute the given COMMAND with two input
%   parameters without waiting for a response.
%
%   EXEC(K,COMMAND,P1,P2,P3) execute the given COMMAND with three input
%   parameters without waiting for a response.
%
%   EXEC(K,COMMAND,P1,P2,P3,SYNC) execute the given COMMAND with three input
%   parameters synchronously and waits for a response from the database.
%   Unused parameters, should be entered as empty.   SYNC can be entered as
%   0 (default) for asynchronous commands and as 1 for synchronous
%   commands.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt, the commands
%
%   K = KX('localhost',5001);
%   EXEC(K,'`date xasc `trade');
%
%   sort the data in the table TRADE in ascending order.  Data
%   subsequently fetched from the table will be ordered in this manner.
%
%   See also FETCH, INSERT, KX.

%   Copyright 1999-2015 The MathWorks, Inc.

%Parse sync flag
if nargin == 6
  if any(varargin{5})
    syncflag = true;
  else
    syncflag = false;
  end
  varargin(5) = [];
  
  %Remove empty inputs needed for input of sync parameter
  if isempty(varargin{4})
    varargin(4) = [];
  end
  if isempty(varargin{3})
    varargin(3) = [];
  end
  if isempty(varargin{2})
    varargin(2) = [];
  end
else
  syncflag = false;
end
    
%Execute q call, synchronously or asynchronously based on inputs
switch length(varargin)
  
  case 1

    %Kx kdb+ command or input object
    if syncflag
      tmp = c.handle.k(varargin{1});
    else
      c.handle.ks(varargin{1});
    end
    
  case 2
      
    %Kx kdb+ command plus one input parameters
    if syncflag
      tmp = c.handle.k(varargin{1},varargin{2});
    else
      c.handle.ks(varargin{1},varargin{2});
    end
    
  case 3

    %Kx kdb+ command plus two input parameters
    if syncflag
      tmp = c.handle.k(varargin{1},varargin{2},varargin{3});
    else
      c.handle.ks(varargin{1},varargin{2},varargin{3});
    end
    
  case 4
    
    %Kx kdb+ command plus three input parameters 
    if syncflag
      tmp = c.handle.k(varargin{1},varargin{2},varargin{3},varargin{4});
    else
      c.handle.ks(varargin{1},varargin{2},varargin{3},varargin{4});
    end
    
end

%Return output argument
if nargout > 0
  if exist('tmp','var')
    x = tmp;
  else
    x = [];
  end
end
  
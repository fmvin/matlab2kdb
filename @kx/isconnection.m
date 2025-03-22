function x = isconnection(c) 
%ISCONNECTION True if valid Kx Systems kdb+ connection.
%   X = ISCONNECTION(K) returns 1 if K is a valid Kx kdb+ connection
%   and 0 otherwise.
%
%   See also KX, CLOSE, FETCH, GET.

%   Copyright 1999-2008 The MathWorks, Inc.

%Test connection by invoking tables method
try
  tables(c);
  x = true;
catch exception %#ok
  x = false;
end

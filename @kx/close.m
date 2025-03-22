function close(k)
%CLOSE Close connection to Kx Systems kdb+.
%   CLOSE(K) closes the connection, K, to the Kx kdb+ database.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt: 
%
%   K = KX('localhost',5001)
%   CLOSE(K)
%
%   See also KX.

%   Copyright 1999-2008 The MathWorks, Inc.

try
  close(k.handle)
catch exception %#ok
  %Trap attempted close of invalid connection
end

classdef kx < handle
%KX  Kx Systems kdb+ connection.
%   K = KX(IP,P) makes a connection to the Kx kdb+ database given an
%   IP address, IP, and port number, P.
%
%   K = KX(IP,P,ID) makes a connection to the Kx kdb+ database given an
%   IP address, IP, port number, P, and username:password string, ID.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt: 
%
%   K = KX('LOCALHOST',5001)
%
%   returns
%
%   K =
% 
%           handle: [1x1 c] 
%        ipaddress: 'localhost'
%             port: '5001'
%
%   Note that the Kx file, kx.jar must be added to the MATLAB javaclasspath
%   with either the javaaddpath command or by referencing it in classpath.txt.
%
%   See also CLOSE, GET, EXEC, FETCH, TABLES.   

%   Copyright 1999-2018 The MathWorks, Inc. 

  properties
    handle
    ipaddress
    port
  end
  
  methods (Access = 'public')
    
    function  k = kx(ip,p,id)

      %   $Revision: 1.1.8.2 $   $Date: 2013/10/09 06:17:09 $
      
      %Need default constructor
      if nargin < 1
        k.handle = [];
        k.ipaddress = [];
        k.port = [];
        return
      end
        
      %Build object structure
      % kx.c syntax is used with jdbc.jar
      % c syntax is used with kx.jar
      switch nargin
        case 2
          try
            k.handle = c(ip,p);
          catch
            k.handle = kx.c(ip,p);
          end
        case 3
          try
            k.handle = c(ip,p,id);
          catch
            k.handle = kx.c(ip,p,id);
          end
      end
      k.ipaddress = ip;
      k.port = p;

    end
    
  end
  
end
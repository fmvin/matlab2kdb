function v = get(c,p)
%GET    Get Kx Systems kdb+ connection properties.
%   V = GET(K,'PropertyName') returns the value of the specified 
%   properties for the Kx kdb+ connection object.  'PropertyName' is
%   a string or cell array of strings containing property names.
%
%   V = GET(K) returns a structure where each field name is the name
%   of a property of K and each field contains the value of that 
%   property.
%
%   The property names are:
%
%      handle
%   ipaddress
%        port
%      
%   See also CLOSE, EXEC, FETCH, INSERT, KX.

%   Copyright 1999-2016 The MathWorks, Inc.

%Build properties if none are given   
prps = {'handle';'ipaddress';'port';...
  };

%Check input properties for invalid entries
if nargin == 1
  
  p = prps;     %Use default property list
  x = 1:3;    %Default index scheme
  
else
  
  if ischar(p) || isstring(p)  %Convert string input to cell array
    p = cellstr(p);
  end

  x = zeros(length(p),1);
  for i = 1:length(p)  %Validate each given property
    try
      x(i) = find(strcmpi(p(i),prps));
    catch exception
      error(message('datafeed:kx:invalidProperty', class( c ), p{ i }))
    end
  end

  p = prps(x);
  
end

%Return requested fields
for i = 1:length(x)
  v.(p{i}) = c.(p{i});
end

%Single field returns value only
if length(x) == 1
  v = v.(p{1});
end

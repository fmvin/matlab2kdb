function d = fetch(c,varargin)
%FETCH Request data from Kx Systems kdb+.
%   D = FETCH(K,KSQL) returns data from Kx kdb+ in a MATLAB structure where K
%   is the Kx kdb+ object and KSQL is the Kx kdb+ command.  KSQL can be any valid
%   Kx kdb+ command and the output of this method will be any data resulting
%   from the given command.
%
%   FETCH(K,KSQL,P1) executes the given command, KSQL, with one input
%   parameter and returns the data from this command.
%
%   FETCH(K,KSQL,P1,P2) executes the given command, KSQL, with two input
%   parameters and returns the data from this command.
%
%   FETCH(K,KSQL,P1,P2,P3) executes the given command, KSQL, with three input
%   parameters and returns the data from this command.
%
%   For example, after running
%
%   q tradedata.q -p 5001 
%
%   at the DOS prompt, the data in the table TRADE can be retrieved with
%   the commands
%
%   K = KX('localhost',5001);
%   D = FETCH(K,'select from trade');
%
%   D = 
% 
%          sec: {5000x1 cell}
%        price: [5000x1 double]
%       volume: [5000x1 int32]
%     exchange: [5000x1 double]
%         date: [5000x1 c$Time[]]
%
%   The call
%
%   D = FETCH(K,'totalvolume','ACME');
%
%   returns 
%   
%   D = 
%
%      volume: 2443500
%    
%   the total trading volume for the security ACME in the table
%   TRADE.  The function TOTALVOLUME is defined in the sample Kx kdb+ file,
%   tradedata.q.
%   
%   See also KX, EXEC, INSERT.

%   Copyright 1999-2015 The MathWorks, Inc.

%Execute q call
switch length(varargin)
  
  case 0
    
    %No inputs, getting message from Kx kdb+
    t = c.handle.k;

  case 1

    %Kx kdb+ command or input object
    t = c.handle.k(varargin{1});
    
  case 2
      
    %Kx kdb+ command plus one input parameters
    t = c.handle.k(varargin{1},varargin{2});
    
  case 3

    %Kx kdb+ command plus two input parameters
    t = c.handle.k(varargin{1},varargin{2},varargin{3});
    
  case 4
    
    %Kx kdb+ command plus three input parameters 
    t = c.handle.k(varargin{1},varargin{2},varargin{3},varargin{4});
    
end

%Date and time offsets
dateconst = datenum(2000,1,1);
timeconst = datenum(1970,1,1);

%Parse kx return data type
kxtype = class(t);
switch kxtype
  
  case {'c$Dict','kx.c$Dict'}
    
    %Get c$Flip components
    tx = t.x;
    ty = t.y;
    tmp = kxout2struct(tx.x,tx.y);
    flds = fieldnames(tmp);
    for i = 1:length(flds)
      d.(flds{i}) = tmp.(flds{i});
    end
    tmp = kxout2struct(ty.x,ty.y);
    flds = fieldnames(tmp);
    for i = 1:length(flds)
      d.(flds{i}) = tmp.(flds{i});
    end
   
  case {'c$Flip','kx.c$Flip'}
    
    x = t.x;
    y = t.y;
    d = kxout2struct(x,y);
    
  otherwise
    
    switch class(t)
      case {'java.lang.String[]'}
        d = cellstr(char(t));
      case {'c$Date','kx.c$Date'}
        d = t.i + dateconst;
      case {'c$Time','kx.c$Time'}
        d = (t.i ./ 86400000);
      otherwise
        d = t;
    end
    return
    
end

%Convert dates and times to MATLAB date numbers
x = fieldnames(d);
numcols = length(x);
for i = 1:numcols
  
  switch class(d.(x{i}))
    
    case {'c$Date[]','kx.c$Date[]'}
      
      numrows = length(d.(x{i}));
      tmp = zeros(numrows,1);
      
      for z = 1:numrows
        
        tmp(z) = d.(x{i})(z).i;
        
      end
      
      d.(x{i}) = tmp + dateconst;
      
    case {'c$Time[]','kx.c$Time[]'}
      
      numrows = length(d.(x{i}));
      tmp = zeros(numrows,1);
      
      for z = 1:numrows
        
        tmp(z) = d.(x{i})(z).i;
        
      end
      
      d.(x{i}) = tmp ./ 86400000;
     
    case {'c$Year[]','c$Month[]','c$Day[]','kx.c$Year[]','kx.c$Month[]','kx.c$Day[]'}
      
      d.(x{i}) = kx2ml(d.(x{i}));
      d.(x{i}) = datenum(d.(x{i}));

    case {'c$Hour[]','c$Minute[]','c$Second[]','kx.c$Hour[]','kx.c$Minute[]','kx.c$Second[]'}
      
      d.(x{i}) = kx2ml(d.(x{i}));
      d.(x{i}) = mod(datenum(d.(x{i})),1);
      
    case {'java.util.Date[]','java.sql.Date[]','java.sql.Timestamp[]','java.sql.Time[]'}
      
      %Allocate temporary output
      numrows = length(d.(x{i}));
      tmp = zeros(numrows,1);

      %Convert KX types to MATLAB strings
      for z = 1:numrows
        
        % 86400000 milliseconds in a day, 1440 minutes in a day
        tmp(z) = d.(x{i})(z).getTime / 86400000 + timeconst - ...
                 d.(x{i})(z).getTimezoneOffset / 1440;
        
      end
      
      d.(x{i}) = tmp;
      
    case {'java.lang.Object[]'}
      
      numels = length(d.(x{i}));
      tmp = cell(numels,1);
      for j = 1:numels
        tmp{j} = d.(x{i})(j);
      end
      
      if isempty(tmp)
        d = [];
        return
      end
      
      switch class(tmp{1})
        
        case {'java.util.Date[]','java.sql.Date[]','java.sql.Timestamp[]','java.sql.Time[]'}
          
          %Allocate temporary output
          numrows = length(tmp);
          tmpout = cell(numrows,1);

          %Convert KX types to MATLAB types
          for z = 1:numrows
        
            numsubrows = length(tmp{z});
            tmpsubout = zeros(numsubrows,1);
            
            for y = 1:numsubrows
            
               % 86400000 milliseconds in a day, 1440 minutes in a day
              tmpsubout(y) = tmp{z}(y).getTime / 86400000 + timeconst - ...
                     tmp{z}(y).getTimezoneOffset / 1440;
            end
            
            tmpout{z} = tmpsubout;
        
          end
          
          tmp = tmpout;
          
        case {'java.lang.Object[]','java.lang.String[]'}
          
          numrows = length(tmp);
          tmpout = cell(numrows,1);
          
          %Convert KX types to MATLAB types
          for z = 1:numrows
            
            numsubrows = length(tmp{z});
            tmpsubout = cell(numsubrows,1);
            
            for y = 1:numsubrows
              
              switch class(tmp{z}(y))
                
                case {'java.lang.String'}
                  
                  tmpsubout{y} = char(tmp{z}(y));
                  
                case {'char'}
                  
                  tmpsubout{y} = tmp{z}(y)';
                  
                otherwise
                  
                  tmpsubout{y} = tmp{z}(y);
                  
              end
              
            end

            tmpout{z} = tmpsubout;
            
          end
          
          tmp = tmpout;
          
        case {'char'}
          
          numrows = length(tmp);
          tmpout = cell(numrows,1);
          
          for z = 1:numrows
            
            tmpout{z} = tmp{z}';
          
          end
          
          tmp = tmpout;
          
      end
          
      d.(x{i}) = tmp;

  end
  
end


function s = kxout2struct(x,y)
%KXOUT2STRUCT KX c$Flip to MATLAB structure.
%   S = KXOUT2STRUCT(X,Y)

%Parse data
numcols = size(x,1);

%Convert fieldnames to cell strings
x = cellstr(char(x));

%Build struct
for i = 1:numcols
  
  switch class(y(i))
      
     case {'java.lang.String[]'}
        
       s.(x{i}) = cellstr(char(y(i)));
    
     otherwise
        
       s.(x{i}) = y(i);    
          
  end
  
end

function y = kx2ml(x)
%KX2ML KX data type to MATLAB data type
%   Y = KX2ML(X) converts a KX data type to a MATLAB data type

%Allocate temporary output
numrows = length(x);
tmp = cell(numrows,1);

%Convert KX types to MATLAB strings
for z = 1:numrows
        
  tmp{z} = char(x(z).toString);
        
end
      
y = tmp;

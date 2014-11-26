function [result] =  array2string(arr)
if length(arr) == 1
    result = num2str(arr(1));
   return; 
end
result = '[';
if length(arr) < 9
   for i=1:(length(arr)-1)
      result = [result num2str(arr(i)) ' ']; 
   end
   if ~isempty(arr)
        result = [result num2str(arr(length(arr)))];
   end
        result = [result ']'];

else
    result = [result num2str(arr(1)) ' ' num2str(arr(2)) ' ' num2str(arr(3)) ' ... '...
        num2str(arr(length(arr))) ']'];
end
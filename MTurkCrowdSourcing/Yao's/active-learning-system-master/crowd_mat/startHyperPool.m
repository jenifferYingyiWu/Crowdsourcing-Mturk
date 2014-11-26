function  startHyperPool(number_of_cores, start_servers)

if start_servers

    system('/home/barzan/mdcc/toolbox/distcomp/bin/stopjobmanager -name barzanmjs -remotehost ben -clean');

    system('/home/barzan/mdcc/toolbox/distcomp/bin/mdce stop');
    
    system('/home/barzan/LM/etc/lmdown');
    
    system('/home/barzan/LM/etc/lmstart');
    
    system('/home/barzan/mdcc/toolbox/distcomp/bin/mdce start -clean');
    
    system('/home/barzan/mdcc/toolbox/distcomp/bin/startjobmanager -name barzanmjs -remotehost ben -clean');
    
end

% stop workers
for i=1:64
    system(['/home/barzan/MATLAB/R2012a/toolbox/distcomp/bin/stopworker -name w' num2str(i)]);
end

for i=1:number_of_cores
   system(['/home/barzan/MATLAB/R2012a/toolbox/distcomp/bin/startworker -jobmanagerhost ben -jobmanager barzanmjs -clean -name w' num2str(i)]);
end

out = findResource('scheduler', 'type', 'jobmanager');
matlabpool(out);

fprintf('We created the following number of threads: ');
matlabpool size


end


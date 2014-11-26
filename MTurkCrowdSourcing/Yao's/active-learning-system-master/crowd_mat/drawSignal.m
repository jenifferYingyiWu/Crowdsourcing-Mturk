function [ output_args ] = drawSignal( signal, xlab, ylab, brk)

figure;
plot(signal);
grid on;
hold on;
xlabel(xlab);
ylabel(ylab);
slope = signal(end) / length(signal);

for i=1:(length(brk)-1)
    x1 = brk(i); 
    x2 = brk(i+1);
    x = x1:(x2-1);
    y = signal(x1) + (x-x1) * slope;
    plot(x, y, 'r');
end
legend('Actual', 'Expected');


end


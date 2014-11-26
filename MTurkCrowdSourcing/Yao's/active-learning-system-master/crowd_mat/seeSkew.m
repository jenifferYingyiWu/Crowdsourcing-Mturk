fontsize = 20;
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultlinelinewidth',3);


cm = CrowdManager('small-entity2.dat', 1, 2, 3:8, 9:12, false);
expr = load('iter-pbr');
w = expr.whenWasAskedAvg;
sw = sortrows(w, 2);
order = sw(:,1);
labels = cm.getRealLabelsByPrimaryKey(order);
clabels = cm.getCrowdLabelsByPrimaryKey(order);
mistakes = xor(labels, clabels); 

order1 = order(labels == 1);
order0 = order(labels == 0);

clabels1 = cm.getCrowdLabelsByPrimaryKey(order1);
mistakes1 = xor(1, clabels1); 

clabels0 = cm.getCrowdLabelsByPrimaryKey(order0);
mistakes0 = xor(0, clabels0); 

C = cumsum(labels);
C0 = cumsum(1-labels);
gap = 100;
n = length(C);

drawSignal(C, '# labels acquired', '# of 1-labels acquired', 1:gap:n);

drawSignal(cumsum(mistakes), '# labels acquired', '# of mistakes', 1:gap:n);

breakPoints1 = C(gap:gap:n);
breakPoints0 = C0(gap:gap:n);

drawSignal(cumsum(mistakes1), '# 1-labels acquired', '# of mistakes in 1', [1; breakPoints1]);

drawSignal(cumsum(mistakes0), '# 0-labels acquired', '# of mistakes in 0', [1; breakPoints0]);



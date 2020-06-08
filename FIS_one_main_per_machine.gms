* maintenance at the beginning
* alterantive constraints
set j jobs /1*3/;
set m maintenance /m1*m2/;
set c machines /c1*c2/;
alias(i,j);
sets edg(j,j) /
1.2
2.3
/;
sets hedg(i,j) /
1.3
/;
*$Include

display edg, hedg;

Scalar
price "price for outsourcing" /20/
big_J "big M constant" /20/;

Parameters
cost(m) /m1 2, m2 3/;
*$INCLUDE "vztahy.txt";

Parameters q(i,j) "penalties FROM R" /
1.2 4
2.3 5
/;
*$INCLUDE "vztahy.txt";
Parameters delta(i,j) "improvements FROM R" /
1.2 3
2.3 3
/;
*$INCLUDE "vztahy.txt";

Binary variables
x(j,c) "assignment of a job to a machine"
xx(m,c) "assignment of a maintenance to a machine"
y(i,j) "assignment of possibly overlapping jobs"
zz(i,j,m,c) "auxiliary variable to determine Z"
z(i,j) "assignment of possibly overlapping jobs and a maintenance";


Variable
objfunction;

Equations
costs,
all_jobs(j),
maint_per_time(m),
maint_per_machine(c),
hard_edges(i,j,c),
soft_edges_1(i,j,c),
soft_edges_2(i,j,c),
maint_1(i,j,m,c),
maint_2(i,j,m,c),
maint_3(i,j,m,c),
z_sum(i,j);

* costs.. objfunction =e= sum(m, cost(m))sum(m, x(m,c)) + price*sum(HRANA, q(i,j)*y(i,j)) - price*sum(HRANA,delta(i,j)*z(i,j))   ;
costs.. objfunction =e= sum(m, cost(m)*sum(c, xx(m,c))) + price*sum((i,j)$edg(i,j), q(i,j)*y(i,j) - delta(i,j)*z(i,j));
all_jobs(j).. sum(c, x(j,c)) =e= 1;
maint_per_time(m).. sum(c, xx(m,c)) =l= 1;
maint_per_machine(c).. sum(m, xx(m,c)) =l= 1;
hard_edges(i,j,c)$hedg(i,j).. x(j,c) + x(i,c) =l= 1;
soft_edges_1(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =l= 1 + y(i,j);
soft_edges_2(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =g= 2*y(i,j) - big_J*(1-x(j,c)) - big_J*(1-x(i,c));
maint_1(i,j,m,c)$edg(i,j).. x(j,c) + x(i,c) + xx(m,c) =l= 2 + zz(i,j,m,c);
maint_2(i,j,m,c)$edg(i,j).. x(j,c) + x(i,c) =g= 2*zz(i,j,m,c);
maint_3(i,j,m,c)$edg(i,j).. x(i,c) + xx(m,c) =g= 2*zz(i,j,m,c);
z_sum(i,j)$edg(i,j).. z(i,j) =e= sum((m,c), zz(i,j,m,c)) 

Model FIS_maintenance /all/;

*option limrow = 10;

solve FIS_maintenance minimizing objfunction using MIP;

*display x.l, y.l, z.l, zz.l, xx.l;
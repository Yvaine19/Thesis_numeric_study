* vstupy: mno�ina hran - pole dvojic - many to many mapping
* indexy: joby, maintenance, machines
* alias i pro j\prime?
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
2.3 4
/;
*$INCLUDE "vztahy.txt";

Binary variables
x(j,c) "assignment of a job to machine"
xx(m,c) "assignment of a maintenance to machine"
y(i,j) "assignment of possibly overlapping jobs"
z(i,j) "assignment of possibly overlapping jobs and maintenance";

* xx.lo('m1', 'c1') = 1;
* xx.lo('m2', 'c2') = 1;

Variable
objfunction;

Equations
costs,
all_jobs(j),
maint(m),
hard_edges(i,j,c),
soft_edges_1(i,j,c),
soft_edges_2(i,j,c),
maint_1(i,j,m,c),
maint_2(i,j,c),
maint_3(i,j,m,c);


* costs.. objfunction =e= sum(m, cost(m))sum(m, x(m,c)) + price*sum(HRANA, q(i,j)*y(i,j)) - p*sum(HRANA,delta(i,j)*z(i,j))   ;
costs.. objfunction =e= sum(m, cost(m)*sum(c, xx(m,c))) + price*sum((i,j)$edg(i,j), q(i,j)*y(i,j) - delta(i,j)*z(i,j));
all_jobs(j).. sum(c, x(j,c)) =e= 1;
maint(m).. sum(c, xx(m,c)) =l= 1;
hard_edges(i,j,c)$hedg(i,j).. x(j,c) + x(i,c) =l= 1;
soft_edges_1(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =l= 1 + y(i,j);
soft_edges_2(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =g= 2*y(i,j) - big_J*(1-x(j,c)) - big_J*(1-x(i,c));
maint_1(i,j,m,c)$edg(i,j).. x(j,c) + x(i,c) + xx(m,c) =l= 2 + z(i,j);
maint_2(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =g= 2*z(i,j);
maint_3(i,j,m,c)$edg(i,j).. x(i,c) + xx(m,c) =g= 2*z(i,j) - big_J*(1-xx(m,c)) - big_J*(1-x(i,c));

Model FIS_maintenance /all/;

solve FIS_maintenance minimizing objfunction using MIP;

display x.l, y.l, z.l, xx.l;
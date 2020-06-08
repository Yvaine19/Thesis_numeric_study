* puvodni zadani ulohy, maintenance na zacatku

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


Parameters q(i,j) "penalties FROM R" /
1.2 4
2.3 5
/;

Parameters delta(i,j) "improvements FROM R" /
1.2 3
2.3 4
/;


Binary variables
x(j,c) "assignment of a job to machine"
xx(m,c) "assignment of a maintenance to machine"
y(i,j) "assignment of possibly overlapping jobs"
z(i,j) "assignment of possibly overlapping jobs and maintenance";

Variable
objfunction;

Equations
costs,
all_jobs(j),
maint(m),
hard_edges(i,j,c),
soft_edges_1(i,j,c),
maintenance_job(i,j,m,c),
maintenance_subseq_job(i,j,c);


costs.. objfunction =e= sum(m, cost(m)*sum(c, xx(m,c))) + price*(sum((i,j)$edg(i,j), q(i,j)*y(i,j)) - sum((i,j)$edg(i,j),delta(i,j)*z(i,j)))   ;
*costs.. objfunction =e= sum(m, cost(m)*sum(c, xx(m,c))) + price*sum((i,j)$edg(i,j), q(i,j)*y(i,j) - delta(i,j)*z(i,j));
all_jobs(j).. sum(c, x(j,c)) =e= 1;
maint(m).. sum(c, xx(m,c)) =l= 1;
hard_edges(i,j,c)$hedg(i,j).. x(j,c) + x(i,c) =l= 1;
soft_edges_1(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =l= 1 + y(i,j);
maintenance_job(i,j,m,c)$edg(i,j).. x(i,c) + xx(m,c) =g= 1 + z(i,j);
* equation above forces to aply maintenance on the machine, where there is not the overlap!!
maintenance_subseq_job(i,j,c)$edg(i,j).. x(j,c) + x(i,c) =g= 2*z(i,j);

Model FIS_maintenance /all/;

option limrow = 10;

solve FIS_maintenance minimizing objfunction using MIP;

display x.l, y.l, z.l, xx.l;
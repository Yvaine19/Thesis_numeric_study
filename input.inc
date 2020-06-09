set  j jobs /1*3/;
set  m maintenance /1*2/;
set  c machines /1*2/;
alias(i,j);
sets edg(i,j) /
	1.2
	2.3
/;
sets hedg(i,j) /
	1.3
/;
scalar price "price for outsourcing" /20/;
scalar big_J "big M constant" /3/;
Parameters costs(m) /
1 2
2 3
/;
Parameters q(i,j) "penalties" /
	1.2 4
	2.3 5
/;
Parameters delta(i,j) "improvements" /
	1.2 3
	2.3 3
/;

data usage;
input week useQ rain trmt;
datalines;
1 55939 12000 0.18
2 56263 18000 0.18
3 65031 20000 0.10
4 67348 22000 0.10
;

data contract;
input option price min;
datalines;
1 0.15 25000
2 0.12 35000
;

proc optmodel;

/*** LOADING DATA ***/

/*usage table*/
set <num> WEEK;
num useQ{WEEK};
num rain{WEEK};
num trmt{WEEK};
read data usage into WEEK=[week] useQ rain trmt;

/*price table*/
set <num> OPTION;
num price{OPTION};
num min{OPTION};
read data contract into OPTION=[option] price min;

/*62500: current quantity in water tank*/
/*30000: the minimum left-over quantity for watertank*/
num watertankavailable = 62500-30000;

/*** SETTING DECISION VARIABLES ***/
/*usage amount(contract1)*/
var x1 >=0;
var x2 >=0;
var x3 >=0;
var x4 >=0;

/*usage amount(from watertank)*/
var y1 >=0;
var y2 >=0;
var y3 >=0;
var y4 >=0;

/*usage amount(contract2)*/
var z1 >=0;
var z2 >=0;
var z3 >=0;
var z4 >=0;

var Contract1 Binary;
var Contract2 Binary;

/*** SETTING DECISION CONSTRAINTS ***/
/* Week1 */
con x1*Contract1+z1*Contract2+y1 >= useQ[1];
con x1 >= min[1];
con z1 >= min[2];
con y1 >= useQ[1]*0.25;
con y1 <= watertankavailable+rain[1];

/* Week2 */
con x2*Contract1+z2*Contract2+y2 >= useQ[2];
con x2 >= min[1];
con z2 >= min[2];
con y2 >= useQ[2]*0.25;
con y2 <= watertankavailable+rain[1]-y1+rain[2];

/* Week3 */
con x3*Contract1+z3*Contract2+y3 >= useQ[3];
con x3 >= min[1];
con z3 >= min[2];
con y3 >= useQ[3]*0.25;
con y3 <= watertankavailable+rain[1]-y1+rain[2]-y2+rain[3];

/* Week4 */
con x4*Contract1+z4*Contract2+y4 >= useQ[4];
con x4 >= min[1];
con z4 >= min[2];
con y4 >= useQ[4]*0.25;
con y4 <= watertankavailable+rain[1]-y1+rain[2]-y2+rain[3]-y3+rain[4];

/* Binary Constrants decide using contract 1 or 2*/
con Contract1 + Contract2 = 1;

/*** SETTING OBJECTIVE FUNCTION ***/
min Cost= (price[1]*(x1 + x2 + x3 + x4))*Contract1 + (price[2]*(z1 + z2 +z3 + z4))*Contract2 + trmt[1]*(y1 + y2) +trmt[3]*(y3 + y4);

solve with nlp relaxint/ algorithm=ipdirect;
print Cost Contract1 Contract2;
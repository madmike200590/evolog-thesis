employee(bob, sales, 2000).
employee(alice, development, 6000).
employee(dilbert, development, 4500).
employee(jane, sales, 3500).
employee(carl, controlling, 5000).
employee(bill, controlling, 4000).
employee(claire, development, 5000).
employee(mary, sales, 3000).
employee(joe, controlling, 5500).

department(DEP) :- employee(_, DEP, _).

min_salary(SAL, DEP) :- SAL = #min{S : employee(_, DEP, S)}, department(DEP).
worst_paid(DEP, EMP) :- min_salary(S, DEP), employee(EMP, DEP, S).
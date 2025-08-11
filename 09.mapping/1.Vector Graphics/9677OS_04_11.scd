f = {arg n; if  (n>1)  {n * f.value(n-1)} {1} }; // a recursive function
f.(5).postln; // factorial of 5

# Exec("date");Rewritability(AlternatingGroup(5),10);time;Exec("date");
Rewritability:=function(G,limit)
local eltsG, s, A, orbsA, x, q, n, isnrw, nrw, S, i, j, u, K, y, orbsK, v, tw; 
eltsG:=Filtered( G, s -> s <> () );
A:=AutomorphismGroup(G);
orbsA:=Orbits(A,G);
x:=Filtered( List(orbsA, q -> q[1] ), q -> q <> () );
x:=List( x, q -> [q] );
n:=1;
repeat
    n:=n+1;
    Print("Started enumeration of NRW of length ", n, "\n");
    nrw:=[];
    S := SymmetricGroup( n );
    S := Filtered( S, s -> s <> () );
    for i in [1..Length(x)] do   
        # Print( i, "/", Length(nrw), "\r");
        u := x[i]; 
        K:=Stabilizer(A,u[1]);
        for j in [ 2 .. Length(u) ] do
            K:=Intersection( K, Stabilizer( A,u[j] ) );
            if Size(K) = 1 then
                y := eltsG;
                break;
             fi;
        od;
        if Size(K) > 1 then
            orbsK:=Orbits(K,G);
            y:=Filtered( List(orbsK, q -> q[1] ), q -> q <> () );
        fi;    
        tw := u;
        for v in y do
            tw[n] := v;
            isnrw:=true;
            for s in S do
                if Product(tw)=Product(Permuted(tw,s)) then
                    isnrw := false;
                    break;
                fi;    
            od;
            if isnrw then     
                Add( nrw, ShallowCopy(tw) );
            fi;
        od;
    od;
    Print( Length(nrw), " NRW of length ", n, " constructed\n");
    if nrw=[] then
        return n;
    fi;
    x := ShallowCopy( nrw );
until n=limit;
return fail;
end;


# Exec("date");RewritabilityWithCache(AlternatingGroup(5),10);time;Exec("date");
RewritabilityWithCache:=function(G,limit)
local eltsG, s, A, orbsA, x, q, n, isnrw, nrw, S, i, j, u, K, y, orbsK, v, tw; 
eltsG:=Filtered( G, s -> s <> () );
A:=AutomorphismGroup(G);
orbsA:=Orbits(A,G);
x:=Filtered( List(orbsA, q -> q[1] ), q -> q <> () );
x:=List( x, q -> [ [ q ], Stabilizer( A,q ) ] );
n:=1;
repeat
    n:=n+1;
    Print("Started enumeration of NRW of length ", n, "\n");
    nrw:=[];
    S := SymmetricGroup( n );
    S := Filtered( S, s -> s <> () );
    for i in [1..Length(x)] do   
        # Print( i, "/", Length(nrw), "\r");
        u := x[i][1]; 
        K := x[i][2];
        if Size(K) = 1 then
            y := eltsG;        
        else
            orbsK:=Orbits(K,G);
            y:=Filtered( List(orbsK, q -> q[1] ), q -> q <> () );
        fi;    
        tw := u;
        for v in y do
            tw[n] := v;
            isnrw:=true;
            for s in S do
                if Product(tw)=Product(Permuted(tw,s)) then
                    isnrw := false;
                    break;
                fi;    
            od;
            if isnrw then     
                Add( nrw, [ ShallowCopy(tw), Intersection( K, Stabilizer( A,v ) ) ] );
            fi;
        od;
    od;
    Print( Length(nrw), " NRW of length ", n, " constructed\n");
    if nrw=[] then
        return n;
    fi;
    x := ShallowCopy( nrw );
until n=limit;
return fail;
end;


RewritabilityWorker:=function( a )
local G, w, stab, limit, x ,eltsG, s, A, orbsA, q, n, isnrw, nrw, S, 
      i, j, u, K, y, orbsK, v, tw, res, g;
G:=a[1];       
w:=a[2];
stab:=a[3];
limit:=a[4];
eltsG:=Filtered( G, s -> s <> () );
A:=AutomorphismGroup(G);
if stab=[] then
    x:=[ [ w, Subgroup(A, [One(A)] ) ] ];
else
    x:=[ [ w, Subgroup( A, List(stab, g -> GroupHomomorphismByImages( G, G, g[1], g[2] ) ) ) ] ];
fi;    
#orbsA:=Orbits(A,G);
#x:=Filtered( List(orbsA, q -> q[1] ), q -> q <> () );
#x:=List( x, q -> [ [ q ], Stabilizer( A,q ) ] );
n:=Length(w);
res:=[];
repeat
    n:=n+1;
    Print("Started enumeration of NRW of length ", n, " on worker\n");
    nrw:=[];
    S := SymmetricGroup( n );
    S := Filtered( S, s -> s <> () );
    for i in [1..Length(x)] do   
        # Print( i, "/", Length(nrw), "\r");
        u := x[i][1]; 
        K := x[i][2];
        if Size(K) = 1 then
            y := eltsG;        
        else
            orbsK:=Orbits(K,G);
            y:=Filtered( List(orbsK, q -> q[1] ), q -> q <> () );
        fi;    
        tw := u;
        for v in y do
            tw[n] := v;
            isnrw:=true;
            for s in S do
                if Product(tw)=Product(Permuted(tw,s)) then
                    isnrw := false;
                    break;
                fi;    
            od;
            if isnrw then     
                Add( nrw, [ ShallowCopy(tw), Intersection( K, Stabilizer( A,v ) ) ] );
            fi;
        od;
    od;
    Print( Length(nrw), " NRW of length ", n, " constructed on worker\n");
    res[n]:=Length(nrw);
    if nrw=[] then
        return res;
    fi;
    x := ShallowCopy( nrw );
until n=limit;
return res;
end;

RewritabilityParallel:=function(G,limit,depth)
local eltsG, s, A, orbsA, x, q, n, isnrw, nrw, S, 
      i, j, u, K, y, orbsK, v, tw, res, res1, w, r; 
if depth<3 then
    Error("the third argument should be bigger than 2 \n");
fi;
eltsG:=Filtered( G, s -> s <> () );
A:=AutomorphismGroup(G);
orbsA:=Orbits(A,G);
x:=Filtered( List(orbsA, q -> q[1] ), q -> q <> () );
x:=List( x, q -> [ [ q ], Stabilizer( A,q ) ] );
n:=1;
res:=[];
repeat
  n:=n+1;
  Print("Started enumeration of NRW of length ", n, "\n");
  if n>=depth then
    res1 := Sum( ParListWithSCSCP( 
                    List( x, w -> [ G, w[1], List( GeneratorsOfGroup(w[2]),MappingGeneratorsImages), limit ] ), 
                          "RewritabilityWorker" ) );
    res := res + Concatenation( ListWithIdenticalEntries( n-1, 0), res1 );                      
    return res;
  else
    nrw:=[];
    S := SymmetricGroup( n );
    S := Filtered( S, s -> s <> () );
    for i in [1..Length(x)] do   
        # Print( i, "/", Length(nrw), "\r");
        u := x[i][1]; 
        K := x[i][2];
        if Size(K) = 1 then
            y := eltsG;        
        else
            orbsK:=Orbits(K,G);
            y:=Filtered( List(orbsK, q -> q[1] ), q -> q <> () );
        fi;    
        tw := u;
        for v in y do
            tw[n] := v;
            isnrw:=true;
            for s in S do
                if Product(tw)=Product(Permuted(tw,s)) then
                    isnrw := false;
                    break;
                fi;    
            od;
            if isnrw then     
                Add( nrw, [ ShallowCopy(tw), Intersection( K, Stabilizer( A,v ) ) ] );
            fi;
        od;
    od;
  fi;  
  Print( Length(nrw), " NRW of length ", n, " constructed\n");
  res[n]:=Length(nrw);
  if nrw=[] then
      return res;
  fi;
  x := ShallowCopy( nrw );
until n=limit;
return res;
end;


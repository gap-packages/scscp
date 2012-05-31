# scscp, chapter 7

# [ "/Users/alexk/gap4r5p4May26/pkg/scscp/doc/examples.xml", 71, 93 ]

gap> LoadPackage("anupq");
-------------------------------------------------------------
Loading ANUPQ 3.0 (ANU p-Quotient package)
C code by  Eamonn O'Brien <obrien@math.auckland.ac.nz>
           (ANU pq binary version: 1.8)
GAP code by Werner Nickel <nickel@mathematik.tu-darmstadt.de>
        and   Greg Gamble  <gregg@math.rwth-aachen.de>

            For help, type: ?ANUPQ
-------------------------------------------------------------
true
gap> G := DihedralGroup( 512 );            
<pc group of size 512 with 9 generators>
gap> F := PqStandardPresentation( G );
<fp group on the generators [ f1, f2, f3, f4, f5, f6, f7, f8, f9 ]>
gap> H := PcGroupFpGroup( F );
<pc group of size 512 with 9 generators>
gap> IdStandardPresented512Group( H );
[ 512, 2042 ]


# [ "/Users/alexk/gap4r5p4May26/pkg/scscp/doc/examples.xml", 144, 157 ]

gap> IdGroup512 := function( G )
>    local code, result;
>    if Size( G ) <> 512 then
>      Error( "G must be a group of order 512 \n" );
>    fi;
>    code := CodePcGroup( G );
>    result := EvaluateBySCSCP( "IdGroup512ByCode", [ code ], 
>                               "localhost", 26133 );
>    return result.object;
> end;;


# [ "/Users/alexk/gap4r5p4May26/pkg/scscp/doc/examples.xml", 163, 168 ]

gap> IdGroup512(DihedralGroup(512));
[ 512, 2042 ]


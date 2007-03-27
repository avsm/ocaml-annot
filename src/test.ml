
(* this module simply contains some test cases *)

let id x = x
let rec map f = function
    | []    -> []
    | x::xs -> f x :: map f xs
    

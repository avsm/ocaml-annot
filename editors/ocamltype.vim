" 
" Lookup type annotation at cursor position in *.annot file.
" The name for the annot file is derived from the buffer name.
"
function! OCamlType()
    let col  = col('.')
    let line = line('.')
    let file = expand("%:p:r")
    echo system("annot -type " . line . " " . col . " " . file . ".annot")
endfunction    
map ,t :call OCamlType()<return>



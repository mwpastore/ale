" Author: w0rp <devw0rp@gmail.com>
" Description: This file implements debugging information for ALE

function! s:GetLinterVariables(filetype, linter_names) abort
    let l:variable_list = []
    let l:filetype_parts = split(a:filetype, '\.')

    for l:key in keys(g:)
        " Extract variable names like: 'ale_python_flake8_executable'
        let l:match = matchlist(l:key, '\v^ale_([^_]+)_([^_]+)_.+$')

        " Include matching variables.
        if !empty(l:match)
        \&& index(l:filetype_parts, l:match[1]) >= 0
        \&& index(a:linter_names, l:match[2]) >= 0
            call add(l:variable_list, l:key)
        endif
    endfor

    call sort(l:variable_list)

    return l:variable_list
endfunction

function! s:EchoLinterVariables(variable_list) abort
    for l:key in a:variable_list
        echom 'let g:' . l:key . ' = ' . string(g:[l:key])
    endfor
endfunction

function! ale#debugging#Info() abort
    let l:filetype = &filetype

    " We get the list of enabled linters for free by the above function.
    let l:enabled_linters = deepcopy(ale#linter#Get(l:filetype))

    " But have to build the list of available linters ourselves.
    let l:all_linters = []
    let l:linter_variable_list = []

    for l:part in split(l:filetype, '\.')
        let l:aliased_filetype = ale#linter#ResolveFiletype(l:part)
        call extend(l:all_linters, ale#linter#GetAll(l:aliased_filetype))
    endfor

    let l:all_names = map(l:all_linters, 'v:val[''name'']')
    let l:enabled_names = map(l:enabled_linters, 'v:val[''name'']')

    " Load linter variables to display
    " This must be done after linters are loaded.
    let l:variable_list = s:GetLinterVariables(l:filetype, l:enabled_names)

    echom ' Current Filetype: ' . l:filetype
    echom 'Available Linters: ' . string(l:all_names)
    echom '  Enabled Linters: ' . string(l:enabled_names)
    echom ' Linter Variables:'
    echom ''
    call s:EchoLinterVariables(l:variable_list)
endfunction

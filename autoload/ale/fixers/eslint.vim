" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing files with eslint.

function! s:FindConfig(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:basename in [
        \   '.eslintrc.js',
        \   '.eslintrc.yaml',
        \   '.eslintrc.yml',
        \   '.eslintrc.json',
        \   '.eslintrc',
        \]
            let l:config = ale#path#Simplify(l:path . '/' . l:basename)

            if filereadable(l:config)
                return l:config
            endif
        endfor
    endfor

    return ale#path#FindNearestFile(a:buffer, 'package.json')
endfunction

function! ale#fixers#eslint#Fix(buffer) abort
    let l:executable = ale#handlers#eslint#GetExecutable(a:buffer)
    let l:config = s:FindConfig(a:buffer)

    if empty(l:config)
        return 0
    endif

    return {
    \   'command': ale#node#Executable(a:buffer, l:executable)
    \       . ' -c ' . ale#Escape(l:config)
    \       . ' --fix %t',
    \   'read_temporary_file': 1,
    \}
endfunction

if exists('g:loaded_umbrella') || &cp || version < 700
    finish
endif

let g:loaded_umbrella = 0.1
let s:keepcpo = &cpo
set cpo&vim

" Declare highlights.
highlight UmbrellaCovered ctermfg=0 ctermbg=121 guifg=Black guibg=Green
highlight UmbrellaPartial ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
highlight UmbrellaNone ctermfg=15 ctermbg=1 guifg=White guibg=Red

" Declare signs.
sign define UmbrellaCovered text==] texthl=UmbrellaCovered
sign define UmbrellaPartial text==| texthl=UmbrellaPartial
sign define UmbrellaNone text==[ texthl=UmbrellaNone

function! s:Initialize()
    let s:coverage_systems = {
                \'umbrella': './umbrella',
                \}

    if exists('g:umbrella_root')
        unlet g:umbrella_root
    endif

    if exists('g:umbrella_program')
        unlet g:umbrella_program
    endif

    if exists('g:umbrella_coverage')
        unlet g:umbrella_coverage
    endif

    call s:FindProgram(expand('%:p:h'))
endfunction

function! s:FindProgram(dir)
    for [l:filename, l:program] in items(s:coverage_systems)
        let l:found = globpath(a:dir, l:filename)
        if filereadable(l:found)
            let g:umbrella_root = a:dir
            let g:umbrella_program = l:program
            let g:umbrella_coverage = a:dir . "/.umbrella-coverage"
        endif
    endfor

    let l:parent = fnamemodify(a:dir, ':h')
    if l:parent != a:dir
        call s:FindProgram(l:parent)
    endif
endfunction

function! s:SetMakeProgram(program)
    if len(a:program)
        let &l:makeprg=a:program
    endif
endfunction

function! s:RunCoverage()
    if exists('g:umbrella_root') && exists('g:umbrella_program')
        exec "cd! " . g:umbrella_root
        call s:SetMakeProgram(g:umbrella_program)
        exec ":silent make"
        cd! -
    endif
endfunction

function! s:ClearCoverage()
    sign unplace *
endfunction

function! s:ShowCoverage()
    call s:ClearCoverage()

    if !has("signs") || empty(bufname(""))
        return
    endif


    if exists('g:umbrella_root') && exists('g:umbrella_coverage')
        exec "cd! " . g:umbrella_root
        for line in readfile(g:umbrella_coverage)
            let parts = split(l:line, ";")

            if bufexists(l:parts[0])
                if len(l:parts[1])
                    exe ":sign place 1 line=" . l:parts[1] . " name=UmbrellaCovered file=" . l:parts[0]
                endif

                if len(l:parts[2])
                    exe ":sign place 1 line=" . l:parts[2] . " name=UmbrellaPartial file=" . l:parts[0]
                endif

                if len(l:parts[3])
                    exe ":sign place 1 line=" . l:parts[3] . " name=UmbrellaNone file=" . l:parts[0]
                endif
            endif
        endfor
        cd! -
    endif
endfunction

" Commands
command Umbrella
    \ call s:RunCoverage()
    \ call s:ShowCoverage()
command UmbrellaRefresh
    \ call s:ShowCoverage()
command UmbrellaClear
    \ call s:ClearCoverage()

" Autocommands
augroup umbrella
    autocmd BufReadPost * call s:BufReadPostHook()
    autocmd BufWritePost * call s:BufWritePostHook()
    autocmd BufWinEnter * call s:BufWinEnterHook()
    autocmd BufEnter * call s:BufEnterHook()
augroup END

" Hooks
function! s:BufReadPostHook()
    call s:Initialize()
    call s:ShowCoverage()
endfunction

function! s:BufWritePostHook()
    call s:RunCoverage()
    call s:ShowCoverage()
endfunction

function! s:BufWinEnterHook()
    call s:Initialize()
    call s:ShowCoverage()
endfunction

function! s:BufEnterHook()
    call s:Initialize()
    call s:ShowCoverage()
endfunction

let &cpo=s:keepcpo
unlet s:keepcpo
" vim: et:sw=4:ts=8:ft=vim

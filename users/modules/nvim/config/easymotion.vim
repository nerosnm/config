" Don't bind any keys by default, because they create conflicts
let g:EasyMotion_do_mapping = 0

" This autocommand group sets up the bindings we actually want
augroup easymotionbindings | au!
    " <Leader>f{char} to move to {char}
    au VimEnter * map <Leader>f <Plug>(easymotion-bd-f)
    au VimEnter * nmap <Leader>f <Plug>(easymotion-overwin-f)
    " <Leader>j to jump to a word
    au VimEnter * map  <Leader>j <Plug>(easymotion-bd-w)
    au VimEnter * nmap <Leader>j <Plug>(easymotion-overwin-w)
augroup END

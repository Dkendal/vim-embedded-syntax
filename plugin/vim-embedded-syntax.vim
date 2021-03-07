function! s:embedding(filetype, start, end, textSnipHl, options) abort
  let ft=toupper(a:filetype)

  let group='textGroup'.ft

  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry

  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif

  execute printf('syntax region textSnip%S matchgroup=%S start="%S" end="%S" contains=@%S %S',
        \ ft,
        \ a:textSnipHl,
        \ escape(a:start, '"'),
        \ escape(a:end, '"'),
        \ group,
        \ join(a:options, ' '))
endfunction

hi CodeBlock NONE
hi link CodeBlock Comment

augroup embeddedSyntax
  au!
  au FileType vim :call s:embedding(
        \ 'lua','lua << LUA','^LUA$','CodeBlock', [])

  au FileType ruby :call s:embedding(
        \ 'ruby','<<[~-]\=\z\(\w*RUBY\w*\)\>','^\s\+\zs\z1$','CodeBlock', ['keepend'])

  au FileType markdown :call s:embedding(
        \ 'ruby','```ruby','```','CodeBlock', ['keepend'])


  au FileType elixir :call s:embedding(
        \ 'graphql',
        \ '"""\ze\n\+\s\+\(mutation\|query\)', '"""',
        \ 'elixirStringDelimiter', [])
augroup END

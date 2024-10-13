vim9script

import autoload "../autoload/recentdirs.vim"
if v:version < 900
    finish
endif
g:source_session = 0
g:directory_history = []

def ViewAllBuffersInSplits()
  for buf in range(1, bufnr('$'))
    if bufwinnr(buf) == -1 && bufexists(buf)
      if buf != range(1, bufnr('$'))[0]
        split
      endif
      execute 'buffer' buf
    endif
  endfor
enddef



# add netrw bookmarks
def SourceNetrwBook()
    var vim_dir = split(&runtimepath, ',')[0]

    if filereadable(vim_dir .. '/.netrwbook')
        execute('source ' ..  vim_dir .. '/.netrwbook')
    endif
    if exists('g:netrw_bookmarklist')
        g:directory_history = g:directory_history + g:netrw_bookmarklist   
    endif

enddef

def SourceSessionIfExists()
    var session_file = getcwd() .. '/Session.vim'
    if filereadable(session_file)
        execute('source ' .. session_file)
        echom 'Session file sourced: ' .. session_file
    endif
enddef

def LoadOldDirs()
    for line in split(execute('old'), '\n')[0 : 10]
         var path = substitute(line, '\v^\d+:\s*(.+)', '\1', '')
            if !empty(path)
                var dir = fnamemodify(path, ':h')
                    if index(g:directory_history, dir) == -1
                        g:directory_history->add(dir)
                    endif
            endif 
    endfor
enddef
command! -nargs=0 OpenAllFiles execute 'args *' | silent! argdo execute 'buffer ' . bufnr(
command! ViewAllBuffersInSplits call ViewAllBuffersInSplits()
command! GetRecentUpdatedDirs call recentdirs.SelectDirectory()
nnoremap <leader>os      <Cmd>ViewAllBuffersInSplits<CR>
nnoremap <leader>fD      <Cmd>GetRecentUpdatedDirs<CR>
augroup DirectoryHistory
    autocmd!
    autocmd VimEnter * call SourceNetrwBook()
    autocmd VimEnter * call LoadOldDirs()
    autocmd DirChanged * call  recentdirs.SaveDirectoryHistory()
    if g:source_session
        autocmd DirChanged * call SourceSessionIfExists()
    endif 
augroup END

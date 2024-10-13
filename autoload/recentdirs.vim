vim9script

export def RefreshNetrw()
     if exists('b:netrw_curdir')
        b:netrw_curdir = getcwd()
       exe 'Lexplore ' .. b:netrw_curdir
    endif
enddef


export def GetRecentlyUpdatedDirs(): list<string>
    var recentDirs: list<string> = []
    var currentDir = getcwd()
    var subdirs = filter(globpath(currentDir, '*', 0, 1), 'isdirectory(v:val)')
    
    var dirModTimes = {}
    if len(subdirs) < 1
        return []
    endif
    for dir in subdirs
        var files = split(globpath(dir, '*'), '\n')
        var latestMod: number
        for file in files
            var modTime = getftime(file)
            if modTime > latestMod
                latestMod = modTime
            endif
        endfor
        dirModTimes[dir] = latestMod
    endfor

    var sortedDirs = keys(dirModTimes)->sort((a, b) => dirModTimes[b] - dirModTimes[a])

    for i in range(10)
        if i >= len(sortedDirs)
            break
        endif
        var dir = sortedDirs[i]
        var modTime = strftime('%Y-%m-%d %H:%M:%S', dirModTimes[dir])
        recentDirs->add(printf('%d. %s - %s', i + 1, dir, modTime))
    endfor

    return recentDirs

enddef

# Function to save the current directory to the history

export def SaveDirectoryHistory() 
    var current_dir = getcwd()
    if index(g:directory_history, current_dir) == -1
        call add(g:directory_history, current_dir)
    endif
enddef

# Define a function to select a directory
export def SelectDirectory()
    # Get the list of directories (modify the path as needed)
    var dirs = GetRecentlyUpdatedDirs()

    # If there are no directories, notify the user
    if len(dirs) == 0 
        echo "No directories found."
        return
    endif

    var selection = inputlist(dirs)

    # Check if the selection is valid
    if selection > 0 && selection <= len(dirs)
        # Change to the selected directory
        var path = substitute(dirs[selection - 1], '^\d\+\.\s\+\(.\{-}\)\s\+-.*$', '\1', '')
        SaveDirectoryHistory()
        execute 'cd' path
        RefreshNetrw()
        echo "Changed directory to: " .. dirs[selection - 1]

        # Check for Session.vim and source it if present
        if filereadable('Session.vim')
            execute 'source Session.vim'
            echo "Sourced Session.vim"
        else
            echo "No Session.vim"
        endif
    else
        echo "Invalid selection."
    endif

enddef

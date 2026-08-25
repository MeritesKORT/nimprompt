import strutils, strformat, terminal, winlean

const
    RESET = "\e[0m"
    RED = "\e[31m"
    YELLOW = "\e[33m"
    CYAN = "\e[36m"


type MenuKey = enum
    mkUp, mkDown, mkEnter


when defined(windows):
    const
        KEY_EVENT = 0x0001
        VK_RETURN = 0x0D
        VK_UP = 0x26
        VK_DOWN = 0x28

    proc flushConsoleInputBuffer(hConsoleInput: Handle): WINBOOL {.
        stdcall, dynlib: "kernel32", importc: "FlushConsoleInputBuffer".}

    proc getVirtualKey(): int =
        let fd = getStdHandle(STD_INPUT_HANDLE)
        discard flushConsoleInputBuffer(fd)
        var rec: KEY_EVENT_RECORD
        var numRead: cint
        
        while true:
            discard readConsoleInput(fd, addr(rec), 1, addr(numRead))
            if rec.eventType == KEY_EVENT and rec.bKeyDown != 0:
                if rec.uChar != 0:
                    return int(rec.uChar)
                else:
                    return int(rec.wVirtualKeyCode)

proc getMenuKey(): MenuKey =
    when defined(windows):
        let key = getVirtualKey()
        if key == VK_RETURN: 
            return mkEnter
        elif key == VK_UP: 
            return mkUp
        elif key == VK_DOWN: 
            return mkDown
        else: 
            return mkEnter
    else:
        let c = getch()
        if c == '\r' or c == '\n':
            return mkEnter
        elif c == '\x1B':
            let c2 = getch()
            if c2 == '[':
                let c3 = getch()
                if c3 == 'A': 
                    return mkUp
                elif c3 == 'B': 
                    return mkDown
        return mkEnter
    
proc ask*(question: string, required: bool = false, minLength: int = 0, hidden: bool = false): string = 
    while true:
        stdout.write(question)
        stdout.flushFile()
        var answer: string

        if hidden:
            answer = readPasswordFromStdin("")
        else:
            answer = stdin.readLine()
        answer = answer.strip()

        if required and answer.len == 0:
            echo fmt"{RED}This field is required.{RESET}"
            continue
        if answer.len < minLength:
            echo fmt"{RED}The answer does not meet the required length.{RESET}"
            continue
        return answer

proc askMenu*(question: string, choices: seq[string]): int =
    var currentIndex = 0
    
    echo question
    for i, choice in choices:
        if i == currentIndex:
            echo fmt"> {choice}"
        else:
            echo fmt"  {choice}"
    
    while true:
        let key = getMenuKey()
        
        if key == mkEnter:
            return currentIndex

        if key == mkUp:
            if currentIndex == 0:
                currentIndex = choices.len - 1
            else:
                dec currentIndex
            cursorUp(choices.len)
            for i, choice in choices:
                if i == currentIndex:
                    echo fmt"> {choice}"
                else:
                    echo fmt"  {choice}"
                    
        elif key == mkDown:
            if currentIndex == choices.len - 1:
                currentIndex = 0
            else:
                inc currentIndex
            cursorUp(choices.len)
            for i, choice in choices:
                if i == currentIndex:
                    echo fmt"> {choice}"
                else:
                    echo fmt"  {choice}"

proc askChoiceIndex*(question: string, options: seq[string]): int =
    if options.len == 0:
        return
    while true:
        echo fmt"{YELLOW}question:{RESET} {question}"
        for i, option in options:
            echo fmt"  {YELLOW}{i + 1}{RESET}. {CYAN}{option}{RESET}"
        
        stdout.write(fmt"{YELLOW}>{RESET} ")
        stdout.flushFile()
        let answer = stdin.readLine().strip()
        
        try:
            let idx = parseInt(answer)
            if idx >= 1 and idx <= options.len:
                return idx
            else:
                echo fmt"{RED}Enter a number between 1 and {options.len}{RESET}"
        except ValueError:
            echo fmt"{RED}Enter valid number.{RESET}"

proc askChoice*(question: string, options: seq[string]): string =
    let idx = askChoiceIndex(question, options)
    return options[idx - 1]
        
proc askYesNo*(question: string, default: bool = false): bool =
    const
        yes_seq = @["y", "yes", "да", "д"]
        no_seq = @["n", "no", "нет", "н"]

    let hint = if default: "(Y/n)" else: "(y/N)"
    
    while true:
        stdout.write(fmt"{YELLOW}{question} {hint}{RESET} ")
        stdout.flushFile()
        let answer = stdin.readLine().strip().toLowerAscii()

        if answer in yes_seq:
            return true
        elif answer in no_seq:
            return false
        elif answer.len == 0:
            return default
        else:
            echo fmt"{RED}This option is unavailable.{RESET}"
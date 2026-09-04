import strutils, strformat, terminal, winlean, unicode

const
    RESET = "\e[0m"
    RED = "\e[31m"
    YELLOW = "\e[33m"
    CYAN = "\e[36m"


type MenuKey = enum
    mkUp, mkDown, mkEnter, mkUnknown


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
            return mkUnknown
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
        return mkUnknown
    
proc ask*(question: string, required: bool = false, minLength: int = 0, hidden: bool = false): string = 
    if minLength < 0:
        raise newException(ValueError, "The length of the response cannot be less than zero")
    while true:
        stdout.write(question)
        stdout.flushFile()
        var answer: string

        if hidden:
            answer = readPasswordFromStdin("")
        else:
            answer = stdin.readLine()
        answer = answer.strip()

        if required and answer.runeLen == 0:
            echo fmt"{RED}This field is required.{RESET}"
            continue
        if answer.runeLen < minLength:
            echo fmt"{RED}The answer does not meet the required length.{RESET}"
            continue
        return answer

proc askMenu*(question: string, choices: seq[string]): string =
    if choices.len == 0:
        raise newException(ValueError, "The list of options cannot be empty")

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
            return choices[currentIndex]

        if key == mkUp:
            if currentIndex == 0:
                currentIndex = choices.len - 1
            else:
                dec currentIndex
            for i in 0 ..< choices.len:
                cursorUp(1)
                eraseLine()
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
            for i in 0 ..< choices.len:
                cursorUp(1)
                eraseLine()
            for i, choice in choices:
                if i == currentIndex:
                    echo fmt"> {choice}"
                else:
                    echo fmt"  {choice}"

proc askChoiceIndex*(question: string, choices: seq[string]): int =
    if choices.len == 0:
        raise newException(ValueError, "The list of options cannot be empty")
    while true:
        echo fmt"{YELLOW}question:{RESET} {question}"
        for i, option in choices:
            echo fmt"  {YELLOW}{i + 1}{RESET}. {CYAN}{option}{RESET}"
        
        stdout.write(fmt"{YELLOW}>{RESET} ")
        stdout.flushFile()
        let answer = stdin.readLine().strip()
        
        try:
            let idx = parseInt(answer)
            if idx >= 1 and idx <= choices.len:
                return idx
            else:
                echo fmt"{RED}Enter a number between 1 and {choices.len}{RESET}"
        except ValueError:
            echo fmt"{RED}Enter valid number.{RESET}"

proc askChoice*(question: string, choices: seq[string]): string =
    let idx = askChoiceIndex(question, choices)
    return choices[idx - 1]
        
proc askYesNo*(question: string, default: bool = false): bool =
    const
        yes_seq = @["y", "yes", "да", "д"]
        no_seq = @["n", "no", "нет", "н"]

    let hint = if default: "(Y/n)" else: "(y/N)"
    
    while true:
        stdout.write(fmt"{YELLOW}{question} {hint}{RESET} ")
        stdout.flushFile()
        let answer = stdin.readLine().strip().toLower()

        if answer in yes_seq:
            return true
        elif answer in no_seq:
            return false
        elif answer.len == 0:
            return default
        else:
            echo fmt"{RED}This option is unavailable.{RESET}"
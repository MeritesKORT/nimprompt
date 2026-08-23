import strutils, strformat

const
    RESET = "\e[0m"
    RED = "\e[31m"
    YELLOW = "\e[33m"
    CYAN = "\e[36m"


proc ask*(question: string, required: bool = false, minLength: int = 0): string =
    while true:
        stdout.write(question)
        stdout.flushFile()
        var answer = stdin.readLine()
        answer = answer.strip()

        if required and answer.len == 0:
            echo fmt"{RED}This field is required.{RESET}"
            continue
        if answer.len < minLength:
            echo fmt"{RED}The answer does not meet the required length.{RESET}"
            continue
        return answer

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
import strformat, strutils, os, terminal


proc progressBar*(current: int, total: int, width: int = 30) =

    let percent = (current.float / total.float) * 100.0
    let filled = int(percent / 100.0 * width.float)
    let empty = width - filled
    let bar = "#".repeat(filled) & ".".repeat(empty)
    let (_, y) = getCursorPos()
    eraseLine()
    setCursorPos(0, y)
    
    stdout.write(fmt"[{bar}] {percent:.1f}% ({current}/{total})")
    stdout.flushFile()

    if current == total:
        echo ""

proc spinner*(message: string = "Downloading", delay: int = 150, frames: seq[string] = @["   ", ".  ", ".. ", "..."]) =
    for frame in frames:
        let (_, y) = getCursorPos()
        
        eraseLine()
        setCursorPos(0, y)
        
        stdout.write(fmt"{message}{frame}")
        stdout.flushFile()
        sleep(delay)
import
    strformat,
    strutils,
    terminal,
    asyncdispatch

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

var isSpinning* = true

proc spinner*(message: string, delay: int, frames: seq[string]) {.async.}=
    while isSpinning:
        for frame in frames:
            if not isSpinning:
                break
            
            let (_, y) = getCursorPos()
            eraseLine()
            setCursorPos(0, y)
            
            stdout.write(fmt"{message}{frame}")
            stdout.flushFile()
            await sleepAsync(delay)

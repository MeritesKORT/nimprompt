import
    strformat,
    strutils,
    terminal,
    asyncdispatch
    
proc progressBar*(current: int, total: int, width: int = 30) =
    if total <= 0:
        raise newException(ValueError, "total must be greater than 0")
    if width <= 0:
        raise newException(ValueError, "width must be greater than 0")

    let safeCurrent = clamp(current, 0, total)
    let percent = (safeCurrent.float / total.float) * 100.0
    let filled = int(percent / 100.0 * width.float)
    let empty = width - filled
    let bar = "#".repeat(filled) & ".".repeat(empty)
    let (_, y) = getCursorPos()
    eraseLine()
    setCursorPos(0, y)
    
    stdout.write(fmt"[{bar}] {percent:.1f}% ({safeCurrent}/{total})")
    stdout.flushFile()

    if safeCurrent == total:
        echo ""

var isSpinning = true

proc spinner*(message: string, delay: int, frames: seq[string]) {.async.}=
    if delay < 0:
        raise newException(ValueError, "The delay cannot be negative")
    if frames.len == 0:
        raise newException(ValueError, "The list of frames cannot be empty")
    
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

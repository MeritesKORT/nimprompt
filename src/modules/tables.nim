import strutils, unicode, strformat, sequtils

proc getMaxWidths(headers: seq[string], rows: seq[seq[string]]): seq[int] = 
    var columnWidths = headers.mapIt(runeLen(it))
    for row in rows:
        for i in 0 ..< columnWidths.len:
            let cellLen = runeLen(row[i])
            if cellLen > columnWidths[i]:
                columnWidths[i] = cellLen
    return columnWidths

proc drawLine(widths: seq[int], lineType: string) = 
    var startChar = ""
    var sepChar = ""
    var endChar = ""
    var middleChar = ""
    case lineType
    of "top":
        startChar = "┌"
        sepChar = "┬"
        endChar = "┐"
        middleChar = ""
    
    of "middle":
        startChar = "├"
        sepChar = "┼"
        endChar = "┤"

    of "bottom":
        startChar = "└"
        sepChar = "┴"
        endChar = "┘"

    stdout.write(startChar)
    for i, width in widths:
        let linePart = "─".repeat(width)
        if i == widths.len - 1:
            stdout.write(fmt"{linePart}{endChar}")
        else:
            stdout.write(fmt"{linePart}{sepChar}")
    echo ""

proc drawRow(cells: seq[string], widths: seq[int]) = 
    stdout.write("│")
    for i in 0 ..< cells.len:
        let cell = alignLeft(cells[i], widths[i])
        stdout.write(fmt"{cell}│")
    echo ""
        
proc printTable*(headers: seq[string], rows: seq[seq[string]]) = 
    let widths = getMaxWidths(headers, rows)
    drawLine(widths, "top")
    drawRow(headers, widths)
    drawLine(widths, "middle")
    
    for i, row in rows:
        drawRow(row, widths)
        if i != rows.len - 1:
            drawLine(widths, "middle")
            
    drawLine(widths, "bottom")
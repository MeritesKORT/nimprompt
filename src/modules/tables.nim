import strutils, unicode, strformat, sequtils

type LineType* = enum
    ItTop, ItMiddle, ItBottom

proc getMaxWidths(headers: seq[string], rows: seq[seq[string]]): seq[int] = 
    var columnWidths = headers.mapIt(runeLen(it))
    for row in rows:
        for i in 0 ..< columnWidths.len:
            let cellLen = runeLen(row[i])
            if cellLen > columnWidths[i]:
                columnWidths[i] = cellLen
    return columnWidths

proc drawLine(widths: seq[int], lineType: LineType) = 
    var startChar = ""
    var sepChar = ""
    var endChar = ""
    case lineType
    of ItTop:
        startChar = "┌"
        sepChar = "┬"
        endChar = "┐"
    
    of ItMiddle:
        startChar = "├"
        sepChar = "┼"
        endChar = "┤"

    of ItBottom:
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
    if headers.len == 0:
        raise newException(ValueError, "The list of headers cannot be empty")
    
    for row in rows:
        if row.len != headers.len:
            raise newException(ValueError, "The line length does not match the number of headers")
    let widths = getMaxWidths(headers, rows)
    drawLine(widths, ItTop)
    drawRow(headers, widths)
    drawLine(widths, ItMiddle)
    
    for i, row in rows:
        drawRow(row, widths)
        if i != rows.len - 1:
            drawLine(widths, ItMiddle)
            
    drawLine(widths, ItBottom)
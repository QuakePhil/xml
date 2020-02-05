// https://play.golang.org/p/OiUazm8DqtZ
package main

import (
    "bufio"
    "fmt"
    "io"
    "log"
    "strconv"
    "strings"
)

var inside int
var close int
var buffer []string
var current string

func processClosedTag() {
    closed := strings.Trim(strings.Replace(buffer[1], "/", "", -1), " ")
    contents := strings.Trim(buffer[0], " ")

    if len(contents) > 0 {
        fmt.Printf("<%s>\t\"%s\"\n", closed, contents)
    } else {
        fmt.Printf("<%s> (no contents)\n", closed)
    }
    buffer[0] = ""
    buffer[1] = ""
}

func processBuffer() {
    if len(current) > 0 {
        if inside == 0 {
            if close == 1 {
                processClosedTag()
                if current[0:1] == "/" {
                    // fmt.Printf("close tag")
                } else {
                    // fmt.Printf("open and close tag")
                }
            } else {
                if current[0:1] == "?" {
                    // fmt.Printf("standalone tag")
                    buffer[1] = ""
                } else {
                    buffer[1] = ""
                    // fmt.Printf("open tag")
                }
            }
            // fmt.Printf(" : %s\n", current)
        } else {
            // fmt.Printf("inside: %s\n", buffer[0])
        }
    }
    current = ""
}

func readRune(rune rune) {
    switch rune {
    case 60: // <
        inside = 1
        close = 0
        processBuffer()
    case 62: // >
        inside = 0
        processBuffer()
    default:
        if rune == 47 {
            close = 1 // also include the slash as part of buffer for later logic
        }
        if strconv.IsPrint(rune) {
            buffer[inside] = buffer[inside] + string(rune)
            current = current + string(rune)
        }
    }
}

// Scan a xsd file and process it in as bulletproof fashion as possible
func readXsd(text string) {
    r := bufio.NewReader(strings.NewReader(text))

    for {
        if rune, _, err := r.ReadRune(); err != nil {
            if err == io.EOF {
                break
            } else {
                log.Fatal(err)
            }
        } else {
            readRune(rune)
        }
    }
}

func main() {
    inside = 0
    close = 0
    current = ""
    buffer = make([]string, 2, 2)
    readXsd(`
<?xml ?>
<a>
<c
>test</c>
<
c2>test2</c2>
<c3/>
<c4 />
<c5/ >
<c>test3</c>
</a>
<b>
another
</b>
`)
}


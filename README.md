# nimprompt

A simple and interactive CLI prompt library for [Nim](https://nim-lang.org/)

It provides a clean and colorful way to ask users for input in the terminal, with built-in validation.

## Features

### prompt

- **`ask`**: Get string input with validation (required fields, minimum length).
- **`askChoice`**: Let the user select an option from a numbered list.
- **`askYesNo`**: Get a boolean answer with a default value (Y/n).
- **`askMenu`**: A cross-platform, interactive menu with arrow-key navigation
- **Colorful output**: Built-in ANSI colors for a better CLI experience.

### progress

- **`progressBar`**: Visualizes task progress. Ideal for file downloads, data processing, or any operation with a known number of steps.
- **`Spinner`**: Displays an animated loading indicator. Used for long-running operations with an unknown duration to show the program is still working.

### tables

- **`printTables`**: Renders formatted tables with auto-calculated column widths and clean Unicode borders in a single function call.

## Installation

Since the library is not yet published on Nimble, you can use it by cloning the repository:

```bash
nimble install nimprompt
```

## Usage

Here is a quick example of how to use **nimprompt**

```nim
import nimprompt
import strformat

# ==========================================
# 1. Interactive Prompts
# ==========================================

# Text input with validation
let name = ask("What is your name?", required = true, minLength = 2)

# Choice from a list (returns the selected string)
let color = askChoice("Choose your favorite color:", @["Red", "Green", "Blue"])

# Choice from a list (returns the selected index as int)
let roleIndex = askChoiceIndex("Choose your role:", @["Admin", "Moderator", "User"])

# Prompt the user to select an OS from a list of strings
let os = askMenu("Select your OS:", @["Windows", "Linux", "macOS"])

# Yes/No question with a default value
let confirm = askYesNo("Do you want to save the changes?", default = true)

echo fmt"Hello, {name}!"
echo fmt"You chose: {color}"
echo fmt"Role Index: {roleIndex}"
echo fmt"You chose: {os}"
echo fmt"Changes saved: {confirm}"


# ==========================================
# 2. Beautiful Tables
# ==========================================

let headers = @["Name", "Age", "City"]
let rows = @[
  @["John", "25", "New York"],
  @["James", "30", "Chicago"]
]

# Automatically calculates widths and draws the table
printTable(headers, rows)


# ==========================================
# 3. Loading Indicators (Progress & Spinners)
# ==========================================

# Example: Progress bar
progressBar(current, total, width = 50)

# Example: Spinner
spinner("Processing data...")
sleep(2000) # Simulate work
```

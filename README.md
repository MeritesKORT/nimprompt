# nimprompt

A simple and interactive CLI prompt library for [Nim](https://nim-lang.org/)

It provides a clean and colorful way to ask users for input in the terminal, with built-in validation.

## Features

- **`ask`**: Get string input with validation (required fields, minimum length).
- **`askChoice`**: Let the user select an option from a numbered list.
- **`askYesNo`**: Get a boolean answer with a default value (Y/n).
- **Colorful output**: Built-in ANSI colors for a better CLI experience.

## Installation

Since the library is not yet published on Nimble, you can use it by cloning the repository:

```bash
git clone https://github.com/MeritesKORT/nimprompt.git
```

Then, import it in your project (make sure src/ is in your import path):

## Usage

Here is a quick example of how to use **nimprompt**

```nim
import src/nimprompt
import strformat

# 1. Basics text input with validation
let name = ask("What is your name?", required=true, minLength=2)

# 2. Choice from a list(return string)
let color = askChoice("Choice your favorite color:", @["Red", "Green", "Blue"])

# 3. Choice from a list(return int)
let role = askChoiceIndex("Choice role", @["Admin", "Moderator", "User"])

# 4. Yes/No question with a default value
let confirm = askYesNo("Do you want to save the changes?", default = true)

# Output the results
echo fmt"Hello, {name}!" # return string
echo fmt"You choice {color}" # return string
echo fmt"Role Index {role}" # return int
echo fmt"Changes saved: {confirm}" # return bool
```

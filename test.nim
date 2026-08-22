import nimprompt, strformat

var name = ask("как вас зовут? ", false, 3)
echo fmt"вас зовут {name}"

var list = askChoiceIndex(fmt"что будем делать с {name}", @["бить", "пощадить"])



var yesno = askYesNo(fmt"{name} Вы готовы?", true)
echo fmt"Ваш ответ {yesno}"
echo fmt"вот что вы выбрали: {GREEN}{list}{RESET}"
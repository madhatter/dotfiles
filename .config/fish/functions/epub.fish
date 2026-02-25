# functions/epub.fish — Render an epub file as HTML and view it in w3m.

function epub --description 'Read an epub file in the terminal via w3m'
    pandoc -f epub -t html $argv | w3m -T text/html
end

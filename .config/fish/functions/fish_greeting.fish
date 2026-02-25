# functions/fish_greeting.fish — Startup display (replaces fish's default version greeting).

function fish_greeting
    if test (uname -s) = Darwin
        neofetch --disable wm --disable de
    else
        archey
    end
end

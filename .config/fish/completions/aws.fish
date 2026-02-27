# AWS CLI completion via aws_completer.
# Overrides the bundled fish aws.fish which only covers top-level service names.
function __fish_complete_aws
    set -lx COMP_LINE (commandline)
    set -lx COMP_POINT (string length (commandline))
    aws_completer | string trim --right
end

complete -c aws -f -a '(__fish_complete_aws)'

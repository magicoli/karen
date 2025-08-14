alias debug_start='trap '\''previous_command=$this_command; this_command=$BASH_COMMAND'\'' DEBUG'
alias debug_result='echo "$previous_command result $?"'

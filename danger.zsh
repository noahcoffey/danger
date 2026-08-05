# danger — claude with no permission prompts, but with a swarm of claudes first
function danger() {
  local R=$'\e[1;31m' O=$'\e[38;5;208m' X=$'\e[0m'
  local ROWS=20 BTOP=8 BCOL=14

  # draw lines at (row, col) relative to the canvas top, then return to the top
  _danger_draw() {
    local r=$1 c=$2 n=0 line
    (( r > 0 )) && printf '\e[%dB' "$r"
    for line in "${@:3}"; do
      printf '\e[%dG%s\e[B' "$c" "$line"
      (( n++ ))
    done
    printf '\e[%dA' $(( r + n ))
  }

  # DANGER! split per letter so each can bounce; Lcol = column offset of each letter
  local -a Lcol=( 0 8 16 26 35 43 51 )
  local -a L1=( "██████╗ " " █████╗ " "███╗   ██╗" " ██████╗ " "███████╗" "██████╗ " "██╗" )
  local -a L2=( "██╔══██╗" "██╔══██╗" "████╗  ██║" "██╔════╝ " "██╔════╝" "██╔══██╗" "██║" )
  local -a L3=( "██║  ██║" "███████║" "██╔██╗ ██║" "██║  ███╗" "█████╗  " "██████╔╝" "██║" )
  local -a L4=( "██║  ██║" "██╔══██║" "██║╚██╗██║" "██║   ██║" "██╔══╝  " "██╔══██╗" "╚═╝" )
  local -a L5=( "██████╔╝" "██║  ██║" "██║ ╚████║" "╚██████╔╝" "███████╗" "██║  ██║" "██╗" )
  local -a L6=( "╚═════╝ " "╚═╝  ╚═╝" "╚═╝  ╚═══╝" " ╚═════╝ " "╚══════╝" "╚═╝  ╚═╝" "╚═╝" )

  # erase the banner band, then draw each letter at its bounce offset for frame $1
  # (a wave: adjacent letters are one phase apart; frame -1 = everything flat)
  _danger_banner() {
    local f=$1 j off blank
    printf -v blank '%54s' ''
    _danger_draw $(( BTOP - 1 )) $BCOL \
      "$blank" "$blank" "$blank" "$blank" "$blank" "$blank" "$blank" "$blank"
    local -a bounce=( 0 -1 0 1 )
    for j in {1..7}; do
      if (( f < 0 )); then off=0; else off=${bounce[$(( (f + j) % 4 + 1 ))]}; fi
      _danger_draw $(( BTOP + off )) $(( BCOL + Lcol[j] )) \
        "${R}${L1[j]}${X}" "${R}${L2[j]}${X}" "${R}${L3[j]}${X}" \
        "${R}${L4[j]}${X}" "${R}${L5[j]}${X}" "${R}${L6[j]}${X}"
    done
  }

  # scatter claudes at random spots, avoiding the banner band and each other
  local NUM=14 tries=0 r c ok k
  local -a spots=()
  while (( $#spots < NUM * 2 )); do
    (( ++tries > 400 )) && break
    r=$(( RANDOM % (ROWS - 2) ))
    c=$(( RANDOM % 70 + 1 ))
    (( r >= BTOP - 3 && r <= BTOP + 6 && c >= BCOL - 8 && c <= BCOL + 53 )) && continue
    ok=1
    for (( k = 1; k <= $#spots; k += 2 )); do
      (( r + 2 >= spots[k] && r <= spots[k] + 2 && c + 8 >= spots[k+1] && c <= spots[k+1] + 8 )) &&
        { ok=0; break }
    done
    (( ok )) && spots+=( $r $c )
  done

  printf '\e[?25l'
  trap 'printf "\e[?25h"; unfunction _danger_draw _danger_banner 2>/dev/null' EXIT
  trap 'printf "\e[%dB" "$ROWS"; return 130' INT

  # reserve a blank canvas and move to its top
  printf '\n%.0s' {1..$ROWS}
  printf '\e[%dA' "$ROWS"

  local frame=0 next=1
  while (( frame < $#spots + 8 )); do
    if (( frame % 2 == 0 && next <= $#spots )); then
      _danger_draw $spots[next] $spots[next+1] \
        "${O} ▐▛███▜▌ ${X}" \
        "${O}▝▜█████▛▘${X}" \
        "${O}  ▘▘ ▝▝  ${X}"
      (( next += 2 ))
    fi
    _danger_banner $frame
    sleep 0.12
    (( frame++ ))
  done
  _danger_banner -1

  printf '\e[%dB\e[?25h\n' "$ROWS"
  trap - INT
  claude --dangerously-skip-permissions "$@"
}

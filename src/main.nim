import tables
import math

import nico

var
  size, padx, pady, csize, player, active_x, active_y, winner: int
  board: Table[(int, int), int]
  player_colours: seq[int]

proc reset_game =
  size = 100
  padx = 70
  pady = 24
  csize = 33
  player = 0
  active_x = 0
  active_y = 0
  winner = -1
  board = initTable[(int, int), int]()
  player_colours = @[12, 14]

var
  p0_score = 0
  p1_score = 0

reset_game()
  
proc draw_cell(x, y, player: int) =
  if player == 0:
    setColor(12)
    circfill(padx + x * csize + csize div 2, pady + csize * y + csize div 2, csize div 2 - 3)
  else:
    setColor(14)
    boxfill(padx + x * csize + 4, pady + csize * y + 4, csize - 8, csize - 8)

proc board_occupied(x, y: int): int =
  if board.contains((x, y)):
    return board[(x, y)]
  else:
    return -1

proc get_winner: int =
  for x in 0..2: # columns
    var last_p = -1
    for y in 0..2:
      let cur_p = board_occupied(x, y)
      if y == 0: last_p = cur_p
      if cur_p == -1: break
      if cur_p != last_p: break
      if cur_p == last_p and y == 2: return cur_p
      last_p = cur_p
  for y in 0..2: # rows
    var last_p = -1
    for x in 0..2:
      let cur_p = board_occupied(x, y)
      if x == 0: last_p = cur_p
      if cur_p == -1: break
      if cur_p != last_p: break
      if cur_p == last_p and x == 2: return cur_p
      last_p = cur_p
  # diagonals
  let
    d00 = board_occupied(0, 0)
    d11 = board_occupied(1, 1)
    d22 = board_occupied(2, 2)
    d02 = board_occupied(0, 2)
    d20 = board_occupied(2, 0)
  if d00 != -1 and d00 == d11 and d11 == d22:
    return d00
  if d02 != -1 and d02 == d11 and d11 == d20:
    return d02
  if board.len() >= 9:
    return 2 # board full
  return -1
        
proc draw_field =
  setColor(10)
  line(padx + csize, pady, padx + csize, pady + size)
  line(padx + csize * 2, pady, padx + csize * 2, size + pady)
  line(padx, pady + csize, padx + size, pady + csize)
  line(padx, pady + 2 * csize, padx + size, pady + 2 * csize)

proc get_cell(x, y: int): (int, int) =
  let
    r_x = x - padx
    r_y = y - pady
  if r_x > 0 and r_y > 0:
    let
      loc_x = floor(r_x / csize).int
      loc_y = floor(r_y / csize).int
    if loc_x <= 2 and loc_y <= 2:
      return (loc_x, loc_y)
    else:
      return (-1, -1)
  else:
    return (-1, -1)
  
proc gameInit() =
  loadFont(0, "font.png")

proc gameUpdate(dt: float32) =
  discard

proc gameDraw() =
  cls()
  draw_field()
  let
    (mx, my) = mouse()
    pressed = mousebtnp(0)
    (cx, cy) = get_cell(mx, my)

  if cx != -1 and cy != -1:
    active_x = cx
    active_y = cy

  if winner == -1:
    if btnp(pcUp): active_y -= 1
    if btnp(pcDown): active_y += 1
    if btnp(pcLeft): active_x -= 1
    if btnp(pcRight): active_x += 1

  if active_x < 0: active_y = 0
  if active_x > 2: active_x = 0
  if active_y < 0: active_y = 0
  if active_y > 2: active_y = 0
  if btnp(pcA) or pressed:
    if board_occupied(active_x, active_y) == -1:
      board[(active_x, active_y)] = player
      winner = get_winner()
      if winner == -1:
        if player == 0: player = 1 else: player = 0
      else:
        if winner == 0: p0_score += 1
        if winner == 1: p1_score += 1

  for (x, y) in board.keys():
    draw_cell(x, y, board[(x,y)])

  setColor(player_colours[player])
  box(padx + active_x * csize + 2, pady + csize * active_y + 2, csize - 4, csize - 4)

  if btnp(pcB):
    reset_game()
  if winner != -1:
    setColor(7)
    boxfill(70, 73, 101, 20)
    setColor(0)
    if winner == 0:
      print("Bob wins!", 95, 75)
    if winner == 1:
      print("Liz wins!", 95, 75)
    if winner == 2:
      print("Bob and Liz draw", 72, 75)
    print("Press 'x' to reset", 72, 85)

  setColor(7)
  print("Nim Nam Nom", 92, 5)
  print("Press X to reset", 82, 130)
  print("Bob", 15, 40)
  print("Liz", 195, 40)
  print($p0_score, 20, 60)
  print($p1_score, 200, 60)
    
when isMainModule:
  nico.init("oxfordfun.com", "nimnamnom")
  fixedSize(true)
  integerScale(true)
  setPalette(loadPalettePico8())
  nico.createWindow("Nim Nam Nom", 240, 140, 4, false)
  nico.run(gameInit, gameUpdate, gameDraw)

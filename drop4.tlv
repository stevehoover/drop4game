\m5_TLV_version 1d: tl-x.org
\m5
   / A library for Makerchip that provides a game with gameplay similar to the
   / Connect 4 game from Hasbro.
   
   use(m5-1.0)
   default_var(player0_id, random)
   default_var(player1_id, random)
   
   
   var(spacing, 26)  /// Width/height of checker position.
   var(hole_color, "#F0F0F0")
   define_hier(XX, 7, 0)
   define_hier(YY, 5, 0)

// Player logic providing random plays.
\TLV player_random(/_top)
   m4_rand($rand, 31, 0)
   $play[2:0] = $rand % m5_XX_CNT;

\TLV drop4game()
   $reset = *reset;
   
   // Which player's turn is it?
   $Player <= $reset ? 1'b0 : ! $Player;
   
   /player0
      m5+call(['player_']m5_player0_id, /player0)
   /player1
      m5+call(['player_']m5_player1_id, /player1)
   /active_player
      $ANY = /top$Player ? /top/player1$ANY : /top/player0$ANY;
   
   /m5_XX_HIER
      \viz_js
         all: {
            box: {left: -3, top: -4, fill: "#1010D0", strokeWidth: 0, height: m5_spacing * 5 + 15, width: m5_spacing * 7 + 6, strokeWidth: 1, stroke: "darkblue"},
         },
         box: {strokeWidth: 0},
      // Is the play in this column.
      $play = /top/active_player$play == #xx;
      /m5_YY_HIER
         \viz_js
            box: {strokeWidth: 0, width: 26, height: 26},
            layout: "vertical",
            template: {
               circle: ["Circle", {left: 3, top: 3, radius: 10, strokeWidth: 1, stroke: "#303090A0", fill: m5_hole_color}]
            },
            render() {
               //debugger
               let playerColor = function(player) {return player ? "#d01010" :"#d0d010"}
               let player_color = playerColor('$Player'.asBool())
               let drop_color = playerColor('/top$Player'.asBool())
               this.getObjects().circle.set({
                    fill: ! '$Filled'.asBool() ? m5_hole_color : player_color,
                    //stroke: '$fill_pos'.asBool() ? "gray" : "blue"
               });
               // If there is a win, determine whether this checker is involved in the win.
               // We must determine a win for the play this cycle (in which case, show it after
               // the drop) or the next cycle (when we stop simulation).
               let won = '/top$win'.asBool()
               let win = '/top$win'.step(1).asBool(false) || won
               let step = won ? 0 : 1
               let player = '/top$Player'.step(step-1).asBool() ? 1 : 0
               let winning_checker = false
               if (win) {
                  let its_me = '$win'.step(step).asBool()
                  let xx = this.getIndex("xx")
                  let yy = this.getIndex("yy")
                  let vertical_win =
                          '/yy[(yy + 1) % m5_YY_CNT]/player[player]$vertical_win'.step(step).asBool()
                       || '/yy[(yy + 2) % m5_YY_CNT]/player[player]$vertical_win'.step(step).asBool()
                       || '/yy[(yy + 3) % m5_YY_CNT]/player[player]$vertical_win'.step(step).asBool()
                  let horizontal_win =
                          '/xx[(xx + 1) % m5_XX_CNT]/yy[yy]/player[player]$horizontal_win'.step(step).asBool()
                       || '/xx[(xx + 2) % m5_XX_CNT]/yy[yy]/player[player]$horizontal_win'.step(step).asBool()
                       || '/xx[(xx + 3) % m5_XX_CNT]/yy[yy]/player[player]$horizontal_win'.step(step).asBool()
                  let diagonal1_win =
                          '/xx[(xx + 1) % m5_XX_CNT]/yy[(yy + 1) % m5_YY_CNT]/player[player]$diagonal1_win'.step(step).asBool()
                       || '/xx[(xx + 2) % m5_XX_CNT]/yy[(yy + 2) % m5_YY_CNT]/player[player]$diagonal1_win'.step(step).asBool()
                       || '/xx[(xx + 3) % m5_XX_CNT]/yy[(yy + 3) % m5_YY_CNT]/player[player]$diagonal1_win'.step(step).asBool()
                  let diagonal2_win =
                          '/xx[(xx - 1 + m5_XX_CNT) % m5_XX_CNT]/yy[(yy + 1) % m5_YY_CNT]/player[player]$diagonal2_win'.step(step).asBool()
                       || '/xx[(xx - 2 + m5_XX_CNT) % m5_XX_CNT]/yy[(yy + 2) % m5_YY_CNT]/player[player]$diagonal2_win'.step(step).asBool()
                       || '/xx[(xx - 3 + m5_XX_CNT) % m5_XX_CNT]/yy[(yy + 3) % m5_YY_CNT]/player[player]$diagonal2_win'.step(step).asBool()
                  winning_checker = its_me || vertical_win || horizontal_win || diagonal1_win || diagonal2_win;
               }
               
               let circle = this.getObjects().circle
               
               // Animate the win.
               this.win_timeout = null
               circle.set({stroke: "#303090A0"})
               let highlight = () => {
                  circle.set({stroke: "cyan"})
                  this.getCanvas().requestRenderAll()
               }
               if (winning_checker) {
                  if (won) {
                     highlight()
                  } else {
                     this.win_timeout = setTimeout(highlight, m5_YY_CNT * 60)
                  }
               }
               
               // Animate the drop.
               this.timeout = null
               if ('/xx[this.getIndex("xx")]$play'.asBool() && ! '$Filled'.asBool() && ! '/top$win'.asBool()) {
                  // This checker is in the drop and is not the final play after a win (which we'll ignore).
                  let index = this.getIndex("yy")
                  let fill = '$fill'.asBool()
                  this.timeout = setTimeout(() => {
                     circle.set({
                          fill: drop_color
                     })
                     if (! fill) {
                        // Not the checker's final resting place.
                        this.timeout = setTimeout(() => {
                             this.timeout = null
                             circle.set({
                                  fill: m5_hole_color
                             })
                             this.getCanvas().requestRenderAll()
                        }, 40)
                     }
                     this.getCanvas().requestRenderAll()
                  }, index * 60)
               }
            },
            unrender() {
               if (this.timeout !== null) {
                  clearTimeout(this.timeout)
               }
               if (this.win_timeout !== null) {
                  clearTimeout(this.win_timeout)
               }
            },
         $reset = /top$reset;
         // Is this position above the top of the stack.
         $fill_pos = ! $Filled && (#yy == 4 || /xx/yy[(#yy + 1) % 5]$Filled);
         // Fill this space this cycle.
         $fill = $fill_pos && /xx$play;
         // Is this space filled.
         $Filled <= $reset ? 1'b0 : $Filled || $fill;
         // Which player's checker is here (if $Filled).
         $Player <= $reset ? 1'b0 :
                    $fill  ? /top$Player :
                             $RETAIN;
         
         /player[1:0]
            // Determine victory condition for this player.
            // For each checker, detect whether it is:
            //   - the lowest      checker of a vertical victory
            //   - the right-most  checker of a horizontal victory
            //   - the lower-right checker of a diagonal victory
            //   - the lower-left  checker of a diagonal victory
            // This approach attempts to optimize the circuit implementation for
            // power (not area) even though the this example is really targeting simulation.
            // To optimize for simulation, we would examine the player checker only.
            // To optimize for area, we would compute only for the active player
            // (toggling many signals every cycle).
            $owned = /yy$Filled && (/yy$Player == #player);
            $vertical_win = (#yy > 2) && $owned
                 && /yy[(#yy - 1 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /yy[(#yy - 2 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /yy[(#yy - 3 + m5_YY_CNT) % m5_YY_CNT]/player$owned;
            $horizontal_win = (#xx > 2) && $owned
                 && /xx[(#xx - 1 + m5_XX_CNT) % m5_XX_CNT]/yy/player$owned
                 && /xx[(#xx - 2 + m5_XX_CNT) % m5_XX_CNT]/yy/player$owned
                 && /xx[(#xx - 3 + m5_XX_CNT) % m5_XX_CNT]/yy/player$owned;
            $diagonal1_win = (#xx > 2) && (#yy > 2) && $owned
                 && /xx[(#xx - 1 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 1 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /xx[(#xx - 2 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 2 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /xx[(#xx - 3 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 3 + m5_YY_CNT) % m5_YY_CNT]/player$owned;
            $diagonal2_win = (#xx < m5_XX_CNT - 3) && (#yy > 2) && $owned
                 && /xx[(#xx + 1 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 1 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /xx[(#xx + 2 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 2 + m5_YY_CNT) % m5_YY_CNT]/player$owned
                 && /xx[(#xx + 3 + m5_XX_CNT) % m5_XX_CNT]/yy[(#yy - 3 + m5_YY_CNT) % m5_YY_CNT]/player$owned;
            $win = $vertical_win
                || $horizontal_win
                || $diagonal1_win
                || $diagonal2_win;
         $win = | /player[*]$win;
      $win = | /yy[*]$win;
   $win = | /xx[*]$win;
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 80 || $win;
   *failed = 1'b0;

\SV
   m5_makerchip_module
\TLV
   m5+drop4game()
\SV
   endmodule

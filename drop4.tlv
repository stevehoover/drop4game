\m5_TLV_version 1d: tl-x.org
\m5
   / A library for Makerchip that provides a game with gameplay similar to the
   / Connect 4 game from Hasbro.
   
   use(m5-1.0)
   / Player IDs should be defined by each player's library file using
   / var(player_id, xxx)
   / thus defining a stack of player_ids.
   
   / Push up to two random players if player_id's are not already defined.
   repeat(2, [
      if(m5_depth_of(player_id) < 2, [
         var(player_id, random)
      ])
   ])
   
   
   var(x_spacing, 28)  /// Width of checker position.
   var(y_spacing, 25)  /// Height of checker position.
   var(x_border, 4)    /// Additional space at left/right edge of board.
   var(top_border, 5)  /// Additional space at top edge of board.
   var(bottom_border, 10) /// Additional space at bottom edge of board.
   var(player0_color, d01010)
   var(player1_color, d0d010)
   var(hole_color, "#F0F0F0")
   define_hier(XX, 7, 0)
   define_hier(YY, 6, 0)

// Player logic providing random plays.
\TLV player_random(/_top)
   m4_rand($rand, 31, 0)
   $play[2:0] = $rand % m5_XX_CNT;

\TLV drop4game()
   // Reset, delayed by one cycle, so we have an empty board on cycle 0.
   $real_reset = *reset;
   $reset = >>1$real_reset;
   
   // Which player's turn is it?
   $Player <= $reset ? 1'b0 : ! $Player;
   
   /player[1:0]
      \viz_js
         box: {width: 100, height: 16, fill: "#a0e0a0"},
         init() {
            return {
               circle: new fabric.Circle({
                    left: 4.5, top: 2.5,
                    radius: 5, strokeWidth: 1,
                    fill: "gray",
                    stroke: "#00000080"}),
               id: new fabric.Text("-", {
                    left: 17, top: 4,
                    fontSize: 7, fontFamily: "Roboto", fill: "black"
               }),
            }
         },
         render() {
            // Can't do this in init() because this.getIndex isn't currently available.
            let o = this.getObjects()
            let i = this.getIndex()
            o.circle.set({fill: i ? "#m5_player1_color" : "#m5_player0_color",
                          stroke: '/top$win'.asBool() && ('/top>>1$Player'.asInt() == this.getIndex()) ? "cyan" : "gray"})
            o.id.set({text: this.getIndex() ? "m5_get_ago(player_id, 1)" : "m5_player_id"})
         },
         where: {left: (26 * m5_XX_CNT - 100) / 2, top: -50},
   
   /player0
      m5+call(['player_']m5_get_ago(player_id, 0), /player0)
      $color[23:0] = 24'h\m5_player0_color;
   /player1
      m5+call(['player_']m5_get_ago(player_id, 1), /player1)
      $color[23:0] = 24'h\m5_player1_color;
   /active_player
      $ANY = /top$Player ? /top/player1$ANY : /top/player0$ANY;
      `BOGUS_USE($color)
   
   /m5_XX_HIER
      \viz_js
         all: {
            box: {left: -m5_x_border, top: -m5_top_border, fill: "#1010D0", strokeWidth: 0, width: m5_x_spacing * m5_XX_CNT + 2 * m5_x_border, height: m5_y_spacing * m5_YY_CNT + m5_top_border + m5_bottom_border, strokeWidth: 1, stroke: "darkblue"},
         },
         box: {strokeWidth: 0},
      // Is the play in this column.
      $play = /top/active_player$play == #xx;
      /m5_YY_HIER
         \viz_js
            box: {strokeWidth: 0, width: m5_x_spacing, height: m5_y_spacing},
            layout: "vertical",
            template: {
               circle: ["Circle", {left: m5_x_spacing / 2, top: m5_y_spacing / 2, radius: 10, strokeWidth: 1, stroke: "#303090A0", fill: m5_hole_color,
                                   originX: "center",
                                   originY: "center"}]
            },
            render() {
               //debugger
               let playerColor = function(player) {return player ? "#m5_player1_color" : "#m5_player0_color"}
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
               circle.set({stroke: "#303090A0"})
               if (winning_checker) {
                  if (!won) {
                    circle.wait(m5_YY_CNT * 60).thenSet({stroke: "cyan"})
                  } else {
                    circle.set({stroke: "cyan"})
                  }
               }
               
               // Animate the drop.
               if (! '/top$reset'.asBool() && '/xx[this.getIndex("xx")]$play'.asBool() && ! '$Filled'.asBool() && ! '/top$win'.asBool()) {
                  // This checker is in the drop and is not the final play after a win (which we'll ignore).
                  let index = this.getIndex("yy")
                  circle.wait(index * 60).thenSet({fill: drop_color})
                  if (! '$fill'.asBool()) {
                     // Not the checker's final resting place.
                     circle.thenWait(40).thenSet({fill: m5_hole_color})
                  }
               }
            },
         $reset = /top$reset;
         // Is this position above the top of the stack.
         $fill_pos = ! $Filled && ((#yy == m5_YY_CNT - 1) || /xx/yy[(#yy + 1) % m5_YY_CNT]$Filled);
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

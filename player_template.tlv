\m5_TLV_version 1d: tl-x.org
\m5
   / A template for a player circuit in Drop4 - a 4-in-a-row game with similar gameplay to Hasbro's Connect 4 game.
   / Player circuits can compete against one another using the game template (which looks similar to this one).
   use(m5-1.0)
   
   / Instructions:
   /  1) Define your Player ID below.
   /  2) Update the name fo the "\TLV player_..." macro correspondingly (without removing "player_").
   /  3) Define your player circuit in this macro.
   var(player_id, my_github_id_and_unique_name)

\TLV player_my_github_id_and_unique_name(/_top)
   m4_rand($rand, 31, 0)
   $play[2:0] = $rand % m5_XX_CNT;

\SV
   // To test against another opponent, include their player circuit library here, but
   // this is not a legal player circuit library until you remove it.
   /// m4_include_lib(player-circuit-URL)
   
   // Include the game.
   m4_include_lib(https://raw.githubusercontent.com/stevehoover/drop4game/2291bdaf63822748d48ca654b1de342fd75a4a0d/drop4.tlv)
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   m5+drop4game()   // Instantiate the game.
\SV
   endmodule

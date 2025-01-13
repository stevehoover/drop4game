\m5_TLV_version 1d: tl-x.org
\m5
   / A template for players to compete in Drop4 - a 4-in-a-row game with similar gameplay to Hasbro's Connect 4 game.
   / Each player provides a Makerchip library based on https://github.com/stevehoover/drop4game/blob/main/player_template.tlv
   / with a circuit to determine plays.
   use(m5-1.0)
   
   / Instructions:
   / Substitute URLs for the player circuits here, the first plays first as red.
\SV
   m4_include_lib(https://raw.githubusercontent.com/stevehoover/drop4game/6baddeb046a3e261bb45bbc2cb879cd8c9931778/player_template.tlv)
   m4_include_lib(https://raw.githubusercontent.com/stevehoover/drop4game/6baddeb046a3e261bb45bbc2cb879cd8c9931778/player_template.tlv)
   
   // Include the game.
   m4_include_lib(https://raw.githubusercontent.com/stevehoover/drop4game/0c409c33dc9e576ab8521ae10f9b91abfedd9675/drop4.tlv)
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   m5+drop4game()   // Instantiate the game.
\SV
   endmodule

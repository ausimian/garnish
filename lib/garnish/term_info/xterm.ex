defmodule Garnish.TermInfo.Xterm do
  use Garnish.TermInfo

  def get_keymap(),
    do: %{
      "\e[19;3~" => :kf56,
      "\e[24;6~" => :kf48,
      "\e[1;4P" => :kf61,
      "\e[15;5~" => :kf29,
      "\eOQ" => :kf2,
      "\e[19~" => :kf8,
      "\e[1;2F" => :kEND,
      "\e[19;2~" => :kf20,
      "\e[19;6~" => :kf44,
      "\e[24;5~" => :kf36,
      "\e[20;6~" => :kf45,
      "\eOC" => :kcuf1,
      "\e[1;2R" => :kf15,
      "\e[15;2~" => :kf17,
      "\e[23;5~" => :kf35,
      "\e[5~" => :kpp,
      "\e[1;2S" => :kf16,
      "\e[17~" => :kf6,
      "\e[3~" => :kdch1,
      "\e[23;6~" => :kf47,
      "\e[1;3Q" => :kf50,
      "\eOB" => :kcud1,
      "\e[24~" => :kf12,
      "\e[5;2~" => :kPRV,
      "\b" => :kbs,
      "\e[15;3~" => :kf53,
      "\e[6~" => :knp,
      "\eOP" => :kf1,
      "\e[1;2P" => :kf13,
      "\e[1;5Q" => :kf26,
      "\e[24;3~" => :kf60,
      "\eOA" => :kcuu1,
      "\e[1;4R" => :kf63,
      "\e[20;5~" => :kf33,
      "\eOD" => :kcub1,
      "\e[2;2~" => :kIC,
      "\e[18;3~" => :kf55,
      "\e[21;3~" => :kf58,
      "\e[1;6P" => :kf37,
      "\e[1;3R" => :kf51,
      "\e[24;2~" => :kf24,
      "\eOM" => :kent,
      "\e[18;6~" => :kf43,
      "\e[15~" => :kf5,
      "\e[20;2~" => :kf21,
      "\e[20~" => :kf9,
      "\e[1;4Q" => :kf62,
      "\e[19;5~" => :kf32,
      "\e[1;5R" => :kf27,
      "\e[21;2~" => :kf22,
      "\e[17;6~" => :kf42,
      "\e[15;6~" => :kf41,
      "\eOF" => :kend,
      "\e[21;5~" => :kf34,
      "\e[1;3P" => :kf49,
      "\e[1;2H" => :kHOM,
      "\e[20;3~" => :kf57,
      "\e[1;6R" => :kf39,
      "\e[3;2~" => :kDC,
      "\eOS" => :kf4,
      "\e[17;3~" => :kf54,
      "\e[21;6~" => :kf46,
      "\eOE" => :kb2,
      "\e[1;3S" => :kf52,
      "\e[17;5~" => :kf30,
      "\e[2~" => :kich1,
      "\e[1;2D" => :kLFT,
      "\e[18~" => :kf7,
      "\e[1;2Q" => :kf14,
      "\e[6;2~" => :kNXT,
      "\eOR" => :kf3,
      "\e[17;2~" => :kf18,
      "\e[Z" => :kcbt,
      "\e[1;6Q" => :kf38,
      "\e[1;2A" => :kri,
      "\e[21~" => :kf10,
      "\e[23;2~" => :kf23,
      "\e[23~" => :kf11,
      "\e[M" => :kmous,
      "\e[1;5P" => :kf25,
      "\e[1;2C" => :kRIT,
      "\e[1;6S" => :kf40,
      "\eOH" => :khome,
      "\e[1;5S" => :kf28,
      "\e[1;2B" => :kind,
      "\e[18;5~" => :kf31,
      "\e[23;3~" => :kf59,
      "\e[18;2~" => :kf19,
    }

  def smcup(), do: "\e[?1049h"
  def rmcup(), do: "\e[?1049l"
  def smkx(), do: "\e[?1h\e="
  def rmkx(), do: "\e[?1l\e>"
  def clear(), do: "\e[H\e[2J"
  def civis(), do: "\e[?25l"
  def cnorm(), do: "\e[?12l\e[?25h"
  def colors(), do: 8

  def cup(row, col) do
    <<"\e[", Integer.to_string(row + 1)::binary, ?;, Integer.to_string(col + 1)::binary, ?H>>
  end

  def setaf(fg) when is_integer(fg) do
    <<
      "\e[", <<?3, Integer.to_string(fg)::binary>>, ?m
    >>
  end

  def setab(bg) when is_integer(bg) do
    <<
      "\e[", <<?4, Integer.to_string(bg)::binary>>, ?m
    >>
  end

  def sgr(flags) when is_integer(flags) do
    <<
      if(bitset?(flags, 8), do: "\e(0", else: "\e(B")::binary,
      "\e[0"::binary,
      if(bitset?(flags, 5), do: ";1", else: "")::binary,
      if(bitset?(flags, 4), do: ";2", else: "")::binary,
      if(bitset?(flags, 1), do: ";4", else: "")::binary,
      if(bitset?(flags, 0) || bitset?(flags, 2), do: ";7", else: "")::binary,
      if(bitset?(flags, 3), do: ";5", else: "")::binary,
      if(bitset?(flags, 6), do: ";8", else: "")::binary,
      ?m
    >>
  end

  def sgr0(), do: "\e(B\e[m"
end

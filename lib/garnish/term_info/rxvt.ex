defmodule Garnish.TermInfo.Rxvt do
  use Garnish.TermInfo

  def get_keymap(),
    do: %{
      "\e[15\^" => :kf27,
      "\e[19~" => :kf8,
      "\e[29~" => :kf16,
      "\e[8$" => :kEND,
      "\e[1~" => :kfnd,
      "\e[d" => :kLFT,
      "\e[34~" => :kf20,
      "\e[18\^" => :kf29,
      "\e[11\^" => :kf23,
      "\e[28\^" => :kf37,
      "\e[5~" => :kpp,
      "\e[32\^" => :kf40,
      "\e[17~" => :kf6,
      "\e[3~" => :kdch1,
      "\e[23$" => :kf21,
      "\e[24~" => :kf12,
      "\b" => :kbs,
      "\e[25~" => :kf13,
      "\e[31~" => :kf17,
      "\e[6~" => :knp,
      "\e[26\^" => :kf36,
      "\e[D" => :kcub1,
      "\e[23@" => :kf43,
      "\e[24@" => :kf44,
      "\e[28~" => :kf15,
      "\e[31\^" => :kf39,
      "\e[34\^" => :kf42,
      "\e[12\^" => :kf24,
      "\e[26~" => :kf14,
      "\e[c" => :kRIT,
      "\e[B" => :kcud1,
      "\e[13\^" => :kf25,
      "\eOu" => :kb2,
      "\e[b" => :kri,
      "\e[21\^" => :kf32,
      "\e[24$" => :kf22,
      "\eOM" => :kent,
      "\e[33~" => :kf19,
      "\e[15~" => :kf5,
      "\e[14\^" => :kf26,
      "\e[7$" => :kHOM,
      "\eOs" => :kc3,
      "\e[2$" => :kIC,
      "\e[20~" => :kf9,
      "\e[23\^" => :kf33,
      "\e[33\^" => :kf41,
      "\e[24\^" => :kf34,
      "\e[29\^" => :kf38,
      "\e[6$" => :kNXT,
      "\e[A" => :kcuu1,
      "\e[3$" => :kDC,
      "\e[7~" => :khome,
      "\eOy" => :ka3,
      "\e[13~" => :kf3,
      "\e[12~" => :kf2,
      "\e[14~" => :kf4,
      "\e[2~" => :kich1,
      "\e[18~" => :kf7,
      "\e[4~" => :kslt,
      "\e[32~" => :kf18,
      "\e[19\^" => :kf30,
      "\e[17\^" => :kf28,
      "\e[Z" => :kcbt,
      "\e[C" => :kcuf1,
      "\e[5$" => :kPRV,
      "\e[25\^" => :kf35,
      "\e[21~" => :kf10,
      "\eOq" => :kc1,
      "\eOw" => :ka1,
      "\e[23~" => :kf11,
      "\e[M" => :kmous,
      "\e[8~" => :kend,
      "\e[8\^" => :kel,
      "\e[11~" => :kf1,
      "\e[a" => :kind,
      "\e[20\^" => :kf31
    }

  def smcup(), do: "\e7\e[?47h"
  def rmcup(), do: "\e[2J\e[?47l\e8"
  def smkx(), do: "\e="
  def rmkx(), do: "\e>"
  def clear(), do: "\e[H\e[2J"
  def civis(), do: "\e[?25l"
  def cnorm(), do: "\e[?25h"
  def colors(), do: 8

  def cup(row, col) do
    <<"\e[", Integer.to_string(row + 1)::binary, ?;, Integer.to_string(col + 1)::binary, ?H>>
  end

  def setaf(fg) when is_integer(fg) do
    <<
      "\e[", <<?3, Integer.to_string(rem(fg, 8))::binary>>, ?m
    >>
  end

  def setab(bg) when is_integer(bg) do
    <<
      "\e[", <<?4, Integer.to_string(rem(bg, 8))::binary>>, ?m
    >>
  end

  def sgr(flags) when is_integer(flags) do
    <<
      "\E[0"::binary,
      # "%?%p6%t;1%;",
      if(bitset?(flags, 5), do: ";1", else: "")::binary,
      # "%?%p2%t;4%;",
      if(bitset?(flags, 1), do: ";4", else: "")::binary,
      # "%?%p1%p3%|%t;7%;",
      if(bitset?(flags, 0) || bitset?(flags, 2), do: ";7", else: "")::binary,
      # "%?%p4%t;5%;",
      if(bitset?(flags, 3), do: ";5", else: "")::binary,
      ?m,
      # "%?%p9%t\016%e\017%;",
      if(bitset?(flags, 8), do: 0o016, else: 0o017)
    >>
  end

  def sgr0(), do: <<"\e[m", 0o017>>
end

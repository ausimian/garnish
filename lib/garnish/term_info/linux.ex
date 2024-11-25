defmodule Garnish.TermInfo.Linux do
  use Garnish.TermInfo

  def get_keymap(),
    do: %{
      "\e[19~" => :kf8,
      "\e[29~" => :kf16,
      "\e[1~" => :khome,
      "\e[34~" => :kf20,
      "\e[5~" => :kpp,
      "\e[17~" => :kf6,
      "\e[3~" => :kdch1,
      "\e[24~" => :kf12,
      "\e[25~" => :kf13,
      "\e[31~" => :kf17,
      "\e[6~" => :knp,
      "\e[[D" => :kf4,
      "\e[D" => :kcub1,
      "\e[28~" => :kf15,
      "\e[[A" => :kf1,
      "\e[26~" => :kf14,
      "\e[B" => :kcud1,
      "\e[[C" => :kf3,
      "\\177" => :kbs,
      "\e[33~" => :kf19,
      "\e[20~" => :kf9,
      "\e[A" => :kcuu1,
      "\e[[E" => :kf5,
      "\e[2~" => :kich1,
      "\e[18~" => :kf7,
      "\e[4~" => :kend,
      "\e[32~" => :kf18,
      "\e[Z" => :kcbt,
      "\e[C" => :kcuf1,
      "\e[[B" => :kf2,
      "\e[21~" => :kf10,
      "\e[23~" => :kf11,
      "\e[G" => :kb2,
      "\e[M" => :kmous
    }

  def smcup(), do: ""
  def rmcup(), do: ""
  def smkx(), do: ""
  def rmkx(), do: ""
  def clear(), do: "\e[H\e[J"
  def civis(), do: "\e[?25l\e[?1c"
  def cnorm(), do: "\e[?25h\e[?0c"
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
      "\E[0;10"::binary,
      # "%?%p1%t;7%;",
      if(bitset?(flags, 0), do: ";7", else: "")::binary,
      # "%?%p2%t;4%;",
      if(bitset?(flags, 1), do: ";4", else: "")::binary,
      # "%?%p3%t;7%;",
      if(bitset?(flags, 2), do: ";7", else: "")::binary,
      # "%?%p4%t;5%;",
      if(bitset?(flags, 3), do: ";5", else: "")::binary,
      # "%?%p5%t;2%;",
      if(bitset?(flags, 4), do: ";2", else: "")::binary,
      # "%?%p6%t;1%;",
      if(bitset?(flags, 5), do: ";1", else: "")::binary,
      # "%?%p9%t;11%;",
      if(bitset?(flags, 8), do: ";11", else: "")::binary,
      ?m
    >>
  end

  def sgr0(), do: "\e[0;10m"
end

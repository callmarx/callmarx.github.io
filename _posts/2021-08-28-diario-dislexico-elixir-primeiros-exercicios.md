---
layout: single
title:  "Diário disléxico - Elixir: Os primeiros exercícios"
date:   2021-08-28 23:49:03 -0300
tags: Elixir Learn
description: >-
  Sobre os primeiros exercícios de Elixir do exercism.io
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---
<div class="tenor-gif-embed" data-postid="7770370" data-share-method="host" data-aspect-ratio="1.16602" data-width="100%"><a href="https://tenor.com/view/gim-gimnasio-pesas-fuerte-james-corden-gif-7770370"></a></div><script type="text/javascript" async src="https://tenor.com/embed.js"></script>
<br/>
Volto aqui para falar um pouco sobre o que eu aprendi com os exercícios básicos e iniciantes do
<https://exercism.io>{:target="_blank"} sobre Elixir. Abaixo segue o que eu resolvi da trilha até
agora e o que eu aprendi/utilizei em cada.
- **Word Count**: *Pipe*, `String.split` e *regex*
- **RNA Transcription**: *map* e `Enum.map`
- **Nucleotide Count**: *map*, `Enum.reduce` e *codepoint* de um caractere
- **Accumulate**: Múltipla definição de funções (nome + aridade)
- **Secret Handshake**: *Bitwise* e `Enum.reduce`
- **Roman Numerals**: Recursão e argumento opcional
- **Beer Song**: *case*, argumento opcional e `Enum.map_join`
- **Bob**: *Regex* com `String.match?` vs funções auxiliares como `String.trim`,
`String.downcase` e `String.ends_with?`

# Word Count

O enunciado pode ser obtido [aqui](){:target="_blank"}.
{: .notice--info}

Exercício simples, perfeito para aplicar a estrutura *pipe* sem muita dificuldade. Entendi melhor
o uso de `String.split` que possui um terceiro argumento opcional, com `trim: true` strings vazias
são excluídas da lista resultante.

Solução:
```elixir
defmodule WordCount do
  @doc """
  Count the number of words in the sentence.
  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    String.downcase(sentence)
    |> String.split(~r/[^[:alnum:]-]/u, trim: true)
    |> Enum.frequencies
  end
end
```

# 

O enunciado pode ser obtido [aqui](){:target="_blank"}.
{: .notice--info}

Solução:
```elixir
```

# 

O enunciado pode ser obtido [aqui](){:target="_blank"}.
{: .notice--info}

Solução:
```elixir
```

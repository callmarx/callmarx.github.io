---
layout: single
title:  "Diário disléxico - Elixir: preciso falar sobre \"Pattern Matching\""
date:   2021-05-06 22:26:09 -0300
tags: Elixir Learn
description: >-
  Parte II.
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---

Quanto mais eu pesquiso sobre Elixir em tutoriais, artigos, livros e vídeos pela internet, mais eu
vejo isto sendo enfatizado. Acredito que seja por conta de legibilidade do código, mas provavelmente
não deve se limitar a apenas isto dada a cobertura que diversos autores dão.


# "Pattern Matching"
Essa parte provavelmente vai parecer confusa e desnecessária, mas confie - "pattern matching" é uma
característica poderosa do Elixir. Inicialmente precisamos entender que ```=``` é um operador
*match*, em uma tradução livre de *match* seria "correspondência". Sim, também o utilizamos para
atribuição, mas a aplicação vai mais além.

```elixir
iex> x = 3
3
iex> 3 = x
3
iex> 4 = x
** (MatchError) no match of right hand side value: 3
```
**Curiosidade**: Caso queira remover a numeração das linhas e habilitar histórico de comandos para
o seu ```iex```, consulte este tutorial
<https://www.toptechskills.com/elixir-phoenix-tutorials-courses/how-to-change-prompt-in-iex-elixir-tutorial-examples/>{:target="_blank"}.
{: .notice--info}

A atribuição ```x = 3``` ocorre como a maioria das linguagens, mas o que aconteceu com ```3 = x```?
Retornou ```3``` e não um erro como o caso seguinte, ou seja, foi uma expressão válida. Quando essa
expressão não faz sentido, devolve um erro, melhor dizendo, quando a operação *match* não é feita
sob dois valores iguais temos um *MatchError*.

Note que a atribuição é SEMPRE feita da esquerda para direita - ```4 = x``` não define a
variável x como 4. Porém, podemos fazer a operação *match* da esquerda para direita com o uso de
```^```, operador *pin*, antes da variável para não reatribui-la.

```elixir
iex> x = 2
2
iex> 2 = x
2
iex> ^x = 3
** (MatchError) no match of right hand side value: 3

iex> ^x = 2
2
```

O mesmo padrão se repete com *lists* e *tuples*.

```elixir
iex> list = [1, 2, 3]
[1, 2, 3]
iex> [1, 2, 3] = list
[1, 2, 3]
iex> [4, 5, 6] = list
** (MatchError) no match of right hand side value: [1, 2, 3]

iex> x = 2
2
iex> [^x, 3, 4, 5] = [2, 3, 4, 5]
[2, 3, 4, 5]
iex> {y, ^x} = {1, 2}
{1, 2}
iex> y
1
```

Inclusive, a atribuição pode ser feita sob toda uma *list* ou *tuple*, quando correta.

```elixir
iex> [a, b, c] = [1, 2, 3]
[1, 2, 3]
iex> a
1
iex> b
2
iex> c
3
iex> {:ok, var} = {:ok, 3}
{:ok, 3}
iex> var
3
iex> {:ok, var} = {:nonok, 3}
** (MatchError) no match of right hand side value: {:nonok, 3}
```
Conseguimos fazer também o *pattern matching* com a "cabeça" e "calda" de uma lista. Isso é feito
com auxílio do operador ```|``` e o comportamento é similar aos das funções ```hd/1``` e ```tl/1```.

```elixir
iex> [head | tail] = [1, 2, 3, 4]
[1, 2, 3, 4]
iex> head
1
iex> tail
[2, 3, 4]
iex> [head | tail] = [1]
[1]
iex> head
1
iex> tail
[]
iex> [head | tail] = []
** (MatchError) no match of right hand side value: []

iex> tl([1])
[]
iex> hd([1])
1
iex> tl([])
** (ArgumentError) argument error
    :erlang.tl([])
```

Note que a expressão ```[head | tail] = []``` retorna um erro pois uma lista vazia, ```[]```, não
possui "calda". Da mesma forma, obtemos erro ao chamar a função ```tl/1``` sob o mesmo valor.

# Funções e o "pattern matching"
--> continuar com isso: https://elixirschool.com/pt/lessons/basics/functions/#fun%C3%A7%C3%B5es-e-pattern-matching

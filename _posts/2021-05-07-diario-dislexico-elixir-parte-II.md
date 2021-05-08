---
layout: single
title:  "Diário disléxico - Elixir: parte II"
date:   2021-05-06 22:26:09 -0300
tags: Elixir Learn
description: >-
  Parte II.
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---


Parte II

# Preciso falar sobre "Pattern Matching"
Essa parte provavelmente vai parecer confusa e desnecessária, mas confie - "pattern matching" é uma
parte poderosa do Elixir. Inicialmente precisamos entender que ```=``` é um operador *match*, em
uma tradução livre de *match* seria "correspondência". Sim, também o utilizamos para atribuição,
mas a aplicação vai além.

```elixir
iex> x = 3
3
iex> 3 = x
3
iex> 4 = x
** (MatchError) no match of right hand side value: 3
```

A atribuição ```x = 3``` ocorre como a maioria das linguagens, mas o que ocorre com ```3 = x```?
Retornou ```3``` e não um erro como o caso seguinte, ou seja, foi uma expressão válida. Quando essa
expressão não faz sentido, devolve um erro, melhor dizendo, quando a operação *match* não feita sob
dois valores iguais temos um *MatchError*.

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

Inclusive, a atribuição pode ser feita sob toda a toda uma *list* ou *tuple*, quando correta.

```elixir
iex> {:ok, result} = {:ok, 3}
{:ok, 3}
iex> {:ok, var} = {:ok, 3}
{:ok, 3}
iex> var
3
iex> {:ok, var} = {:nonok, 3}
** (MatchError) no match of right hand side value: {:nonok, 3}
```


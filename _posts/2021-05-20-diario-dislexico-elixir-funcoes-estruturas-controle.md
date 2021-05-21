---
layout: single
title:  "Diário disléxico - Elixir: Funções e Estruturas de Controle"
date:   2021-05-20 17:51:49 -0300
tags: Elixir Learn
description: >-
  Parte II.
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---


# Estruturas de Controle

**Obs:**: Me senti bem idiota em escrever esta parte porque no final das contas ficou basicamente
igual ao tutorial oficial, disponível em
<https://elixir-lang.org/getting-started/case-cond-and-if.html>{:target="_blank"}, então sinta-se à
vontade em pular para o próximo tópico. Pelo menos isso me serviu pra fixar o conteúdo, que
inclusive é o proposito disso aqui.
{: .notice--warning}

Uma breve explicação das estruturas ```case```, ```if/else/unless``` e blocos com ```do/end```.

***case***
{: .notice--relative--primary}

Trata-se de um *switch-case*, no qual podemos simplificar múltiplos *if/else*. Quando uma condição
é satisfatória, seu resultado é devolvido e as demais condições do bloco não são averiguadas.
Repere que quando fazemos ```case``` com uma lista, **não** à percorremos item por item, mas
aplicamos cada condição nela inteira.

```elixir
iex> case {1, 2, 3} do
...>   {1} ->
...>     "Esta condição não será correspondida."
...>   {1, 2, 3} ->
...>     "Esta condição será correspondida."
...> end
"Esta condição será correspondida."

iex> case {1, 2, 3} do
...>   {2, 3, 4} ->
...>     "Esta condição não será correspondida."
...>   {1, x, 3} ->
...>     "Esta condição será correspondida e
...>     atribuirá 'x' à #{x}."
...> end
"Esta condição será correspondida e\n    atribuirá 'x' à 2."
```
**Obs**: Cuidado com o escopo, no segundo exemplo a variável ```x = 2``` é atribuída e
disponibilizada dentro da condição dela. Se, por exemplo, você fizer ```x = 7``` antes do ```case```,
depois dele verá que *x* ainda vale 7, ou seja, não é reescrito.
{: .notice--warning}

Você pode usar o operador ```^``` antes de uma variável para fazer a condição sob ela. Para
definir uma condição *default*, que sempre será válida, basta utilizar ```_```.

```elixir
iex> x = 1
1
iex> case 2 do
...>   ^x -> "não irá corresponder."
...>   _ -> "irá corresponder."
...> end
"irá corresponder."
```
Note que ```_``` deve ser a última se não o ```case``` sempre cairá nela. Outro
detalhe é que se nenhuma condição for satisfeita é obtido o erro *CaseClauseError*.


```elixir
iex> case 2 do
...>   _ -> "irá corresponder."
...>   ^x -> "Também corresponde, mas não chegará até aqui."
...> end
"irá corresponder."

iex> case :fool do
...>   :smart -> "não irá corresponder."
...> end
** (CaseClauseError) no case clause matching: :fool
```

***cond***
{: .notice--relative--primary}

Parecido com o ```case```, mas atende a necessidade de checar múltiplos valores ou condições para
além de igualdade.

```elixir
iex> cond do
...>   1 + 1 == 3 ->
...>    "é falso."
...>   2 - 1  == 3 ->
...>    "também é falso."
...>   1 + 2 == 3 ->
...>    "é verdadeiro."
...> end
"é verdadeiro."
```

Importante pontuar que tudo para além de ```nil``` e ```false``` é considerado verdadeiro.

```elixir
iex>  hd(["a", "b", "c"])
"a"
iex> cond do
...>   hd(["a", "b", "c"]) ->
...>     "'a' é considerado como verdadeiro."
...> end
"'a' é considerado como verdadeiro."
```

***if*** e ***unless***
{: .notice--relative--primary}

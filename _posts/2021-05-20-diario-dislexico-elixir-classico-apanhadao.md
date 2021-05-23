---
layout: single
title:  "Diário disléxico - Elixir: Aquele clássico apanhadão"
date:   2021-05-20 17:51:49 -0300
tags: Elixir Learn
description: >-
  Uma "rápida" síntese de mais alguns conceitos antes de ir para resolução de exercícios.
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---
<div class="tenor-gif-embed" data-postid="12225126" data-share-method="host" data-width="100%" data-aspect-ratio="1.1340782122905029"><a href="https://tenor.com/view/steve-carrell-dont-like-that-the-office-michael-scott-nope-gif-12225126"></a></div><script type="text/javascript" async src="https://tenor.com/embed.js"></script>
<br/>

Antes de partir para a resolução de alguns exercícios, achei válido pontuar mais algumas
funcionalidades do Elixir em um "apanhadão". Neste post abordo sobre estruturas de controle,
funções, operador *Pipe* e *Enum*.

# Estruturas de Controle

**Obs**: Me senti bem idiota depois de escrever esta parte. No final das contas ficou bem próximo
ao tutorial oficial, disponível em <https://elixir-lang.org/getting-started/case-cond-and-if.html>{:target="_blank"}
e em <https://elixirschool.com/en/lessons/basics/control-structures/>{:target="_blank"}, exceto a
parte do ```with```, que dei uma atenção maior. Então sinta-se à vontade em pular para o próximo
tópico. Pelo menos me serviu pra fixar o conteúdo, que inclusive é o proposito disso aqui.
{: .notice--warning}

Uma breve explicação das estruturas ```case```, ```cond```, ```if/else/unless```, ```with``` e
blocos com ```do/end```.

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

Nada de novo, são basicamente iguais a maioria das linguagens. Ambos aceitam o bloco ```else```
e ```unless``` checa o inverso de ```if```. Lembrando, novamente, que tudo para além de ```nil```
e ```false``` é considerado verdadeiro.

```elixir
iex> if true do
...>   "isto será devolvido!"
...> end
"isto será devolvido!"

iex> unless true do
...>   "isto nunca será devolvido!"
...> end
nil

iex> if nil do
...>   "isto não será devolvido."
...> else
...>   "mas isto será."
...> end
"mas isto será."

iex> unless 1 do
...>   "isto não será devolvido, '1' é considerado true."
...> else
...>   "mas isto será."
...> end
"mas isto será."
```

Blocos ***do***/***end***
{: .notice--relative--primary}

Provavelmente você já deve ter notado que funções e estruturas de controle são delimitadas por
 ```do``` e ```end```. Nada de novo também, mas vale pontuar que é possível simplificar esse blocos
em uma linha:

```elixir
iex> if true, do: 1 + 2
3

iex> if false, do: :this, else: :that
:that
```

***with***
{: .notice--relative--primary}

Introduzido na versão 1.2 do Elixir, a estrutura ```with``` permite simplificar o código,
substituído, por exemplo, clausulas aninhadas de ```case```.

```elixir
iex> full_name = %{first: "Nila", last: "Minha gatatinha idosa"}
%{first: "Nila", last: "Minha gatatinha idosa"}

iex> with {:ok, first} <- Map.fetch(full_name, :first),
...>   {:ok, last} <- Map.fetch(full_name, :last),
...>   do: last <> ", " <> first
"Minha gatatinha idosa, Nila"

iex> only_first = %{first: "Nila"}
%{first: "Nila"}

iex> with {:ok, first} <- Map.fetch(only_first, :first),
...>   {:ok, last} <- Map.fetch(only_first, :last),
...>   do: last <> ", " <> first
:error
```

Primeiro, vamos entender precisamente este exemplo. O que faz a função ```fetch/2``` do módulo
 ```Map```? Ela "pega" o valor de uma chave de um *map*:

```elixir
iex> m = %{a: 1, b: 3, c: 5}
%{a: 1, b: 3, c: 5}
iex> Map.fetch(m, :a)
{:ok, 1}
iex> Map.fetch(m, :b)
{:ok, 3}
Map.fetch(m, :d)
:error
```

Note que seu retorno não é apenas o valor, mas uma *tuple* com o *atom* ```:ok``` mais o valor da
chave requisitada. Repare ainda que ao não encontrar devolve ```:error``` **sozinho**.

Para fazer o equivalente com ```case```, perceba como aumenta a verbosidade do código:

```elixir
iex> full_name = %{first: "Nila", last: "Minha gatatinha idosa"}
%{first: "Nila", last: "Minha gatatinha idosa"}

iex> case Map.fetch(full_name, :first) do
...>   {:ok, first} ->
...>     case Map.fetch(full_name, :last) do
...>       {:ok, last} -> last <> ", " <> first
...>       :error -> :error # retorna o atom :error
...>     end
...>   :error -> :error # retorna o atom :error
...> end
"Minha gatatinha idosa, Nila"

iex> only_first = %{first: "Nila"}
%{first: "Nila"}

iex> case Map.fetch(only_first, :first) do
...>   {:ok, first} ->
...>     case Map.fetch(only_first, :last) do
...>       {:ok, last} -> last <> ", " <> first
...>       :error -> :error # retorna o atom :error
...>     end
...>   :error -> :error # retorna o atom :error
...> end
:error
```
<div class="notice--warning">
 <p><strong>Obs</strong>: Note como a direção das flechas apontam a "direção de partida" da execução e, consequentemente, leitura do código:</p>
  <ul>
    <li>Quando temos <code class="language-plaintext highlighter-rouge">-></code> em <code class="language-plaintext highlighter-rouge">case</code>, significa que se o conteúdo <strong>à esquerda</strong> da flecha der <em>match</em> com o argumento do <code class="language-plaintext highlighter-rouge">case</code>, executamos então o que segue a direita dela.</li>
    <li>Quando temos <code class="language-plaintext highlighter-rouge"><-</code> em <code class="language-plaintext highlighter-rouge">with</code>, significa que se o conteúdo <strong>à direita</strong> da flecha der <em>match</em> com o da esquerda, executamos então o bloco <code class="language-plaintext highlighter-rouge">do</code>.</li>
    </ul>
</div>

Para esclarecer um pouco mais este poder de síntese com ```with```, vamos para outro exemplo.
Suponha o seguinte trecho de código encontrado em um projeto Elixir:

```elixir
case Repo.insert(changeset) do
  {:ok, user} ->
    case Guardian.encode_and_sign(user, :token, claims) do
      {:ok, token, full_claims} ->
        important_stuff(token, full_claims)

      error ->
        error
    end

  error ->
    error
end
```

Mesmo não sabendo o comportamento, e muito menos como foi implementado, algumas das chamadas feitas
neste trecho, podemos interpretar que:
- No primeiro ```case```, se ```Repo.insert(changeset)``` retornar um ```{:ok, user}``` entramos
  no segundo ```case```, caso contrário obtemos um erro. 
- Já no segundo ```case```, se ```Guardian.encode_and_sign(user, :token, claims)``` retornar um
 ```{:ok, token, full_claims}``` então a chamada de ```important_stuff(token, full_claims)``` é
 feita, caso contrário obtemos o mesmo erro anterior.

Note como podemos simplificar, utilizando menos linhas, mas mantendo a lógica e até aumentando a
legibilidade.

```elixir
with {:ok, user} <- Repo.insert(changeset),
     {:ok, token, full_claims} <- Guardian.encode_and_sign(user, :token, claims) do
  important_stuff(token, full_claims)
end
```

***with*** com **else**
{: .notice--relative--primary}

A partir da versão 1.3, ```with/1``` também suporta ```else```. Vejamos primeiro um exemplo com
 ```with``` direto (não aninhado):

```elixir
iex> full_name = %{first: "Nila", last: "Minha gatatinha idosa"}
%{first: "Nila", last: "Minha gatatinha idosa"}
iex> with {:ok, first} <- Map.fetch(full_name, :first) do
...>   "O primeiro nome é '#{first}'"
...> else
...>   :error -> "Erro! Não há a chave ':first'"
...> end
"O primeiro nome é 'Nila'"

iex> only_last = %{last: "Minha gatatinha idosa"}
%{last: "Minha gatatinha idosa"}
iex> with {:ok, first} <- Map.fetch(only_last, :first) do
...>   "O primeiro nome é '#{first}'"
...> else
...>   :error -> "Erro! Não há a chave ':first'"
...> end
"Erro! Não há a chave ':first'"
```

Agora refazendo o primeiro exemplo, aninhado com dois *match*s, temos:

```elixir
iex> full_name = %{first: "Nila", last: "Minha gatatinha idosa"}
%{first: "Nila", last: "Minha gatatinha idosa"}
iex> with {:ok, first} <- Map.fetch(full_name, :first),
...>   {:ok, last} <- Map.fetch(full_name, :last) do
...>     last <> ", " <> first
...>   else
...>     :error -> "Erro! precisa ter as chaves 'first' e 'last'"
...> end
"Minha gatatinha idosa, Nila"

iex> only_first = %{first: "Nila"}
%{first: "Nila"}
iex> with {:ok, first} <- Map.fetch(only_first, :first),
...>   {:ok, last} <- Map.fetch(only_first, :last) do
...>     last <> ", " <> first
...>   else
...>     :error -> "Erro! precisa ter as chaves 'first' e 'last'"
...> end
"Erro! precisa ter as chaves 'first' e 'last'"

iex> only_last = %{last: "Minha gatatinha idosa"}
%{last: "Minha gatatinha idosa"}
iex> with {:ok, first} <- Map.fetch(only_last, :first),
...>   {:ok, last} <- Map.fetch(only_last, :last) do
...>     last <> ", " <> first
...>   else
...>     :error -> "Erro! precisa ter as chaves 'first' e 'last'"
...> end
"Erro! precisa ter as chaves 'first' e 'last'"
```

Como ```Map.fetch``` é chamado em ambos os *match*s, o bloco de ```else``` precisa lidar apenas
com um único caso de negativa - quando ```Map.fetch``` retorna ```:error```. Como lidar então com
múltiplos casos de negativa?

```elixir
defmodule Fool do
  import Integer

  def check_even_on_map(m, key) do
    with {:ok, number} <- Map.fetch(m, key),
      true <- is_even(number) do
        "é par"
    else
      :error ->
        "Valor não encontrado no map"
      false ->
        "é impar"
    end
  end
end

iex> my_map = %{a: 2, b: 3}
%{a: 2, b: 3}
iex> Fool.check_even_on_map(my_map, :a)
"é par"
iex> Fool.check_even_on_map(my_map, :b)
"é impar"
iex> Fool.check_even_on_map(my_map, :c)
"Valor não encontrado no map"
```

Temos um ```with``` com dois casos distintos de negativa tratados pelo bloco ```else```:
- Com ```Map.fetch```, que retorna ```:error```
- Com ```is_even/1```, do módulo ```Integer``` importado, que retorna ```false```.

# Funções



---
layout: single
title:  "Diário disléxico - Elixir: Um pouco mais que um \"Hello World\""
date:   2021-04-30 12:26:09 -0300
tags: Elixir Learn
description: >-
  Começando pelo básico: instalação, configuração e primeiras impressões.
categories: blog
header:
  og_image: assets/posts/elixir-logo.webp
---

<div class="tenor-gif-embed" data-postid="13830351" data-share-method="host" data-width="100%" data-aspect-ratio="2.4057971014492754"><a href="https://tenor.com/view/hello-sexy-hi-hello-mr-bean-gif-13830351"></a></div><script type="text/javascript" async src="https://tenor.com/embed.js"></script>
<br/>

Para além de instalar e codar o clássico "Hello World", vamos explorar os passos iniciais com a
tecnologia. Entender os *data types*, as operações básicas e algumas curiosidades.

# Instalação e configuração
Inicialmente pensei em utilizar algum gerenciador de versão como faço com Ruby através do RVM, mas
optei, por agora, em instalar diretamente no meu Linux, no caso Arch Linux. Para outros sistemas
operacionais veja em <https://elixir-lang.org/install.html>{:target="_blank"}.

```bash
# instalação
$ sudo pacman -S elixir
```

Você deve obter algo como:

```
$ elixir -v
Erlang/OTP 23 [erts-11.2] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe]

Elixir 1.11.3 (compiled with Erlang/OTP 23)
```

Além do comando ```elixir``` temos o ```iex```, que é o *Elixir's interactive shell*, e o ```mix```,
que é o *build tool* da linguagem. Aparentemente equivalentes ao ```irb``` e ```bundle``` do Ruby.

```elixir
$ iex
Erlang/OTP 23 [erts-11.2] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe]

Interactive Elixir (1.11.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 1 + 1
2
iex(2)> 2 < 3
true
iex(3)> 8 == 8.0
true
iex(4)> 8 === 8.0
false
iex(5)> true == :true
true
iex(6)> String.split("Duas palavras", " ")
["Duas", "palavras"]
```
**Obs**: Mais a diante explico melhor, e com mais exemplos, as interações do console acima. Caso
esteja perdido ~~como eu fiquei~~ para sair do ```iex```, basta dar CTRL+C duas vezes.
{: .notice--warning}

Existem diversas funcionalidades contempladas pelo ```mix``` como podemos ver em
<https://hexdocs.pm/mix/Mix.html>{:target="_blank"}. Para esta primeira parte utilizei para criar
um projeto.

```
$ mix new hello
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/hello.ex
* creating test
* creating test/test_helper.exs
* creating test/hello_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd hello
    mix test

Run "mix help" for more commands.
```



---
layout: single
title:  "Diário disléxico - Elixir: Um pouco mais que um \"Hello World\""
date:   2021-05-05 20:26:09 -0300
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

# Um pouco de história
Elixir é uma linguagem de programação dinâmica, funcional e concorrente, compilada e executada na
máquina virtual Erlang (BEAM - *Bogdan/Björn’s Erlang Abstract Machine*). Criada em 2012 pelo
brasileiro [José Valim](https://github.com/josevalim){:target="_blank"} em um projeto de pesquisa e
desenvolvimento da empresa [Plataformatec](http://blog.plataformatec.com.br){:target="_blank"},
hoje uma subsidiária do Nubank.

<br/>
![Erlang logo](/assets/posts/erlang-logo.webp){: .align-left}
Mas e esse tal de [Erlang](https://en.wikipedia.org/wiki/Erlang_(programming_language)){:target="_blank"}?
Trata-se de uma linguagem também funcional e concorrente criada pela empresa Ericson em 1986.
Projetada para lidar com as demandas de telecomunicações, ou seja, alta capacidade de resposta,
escalabilidade e disponibilidade constante. Afinal uma ligação não podia (e ainda não pode) ser
afetada pelas outras, um imprevisto ou atualização não pode derrubar o sistema telefônico. Com o
avanço da internet e a sofisticação das aplicações como redes sociais, jogos multiplayer, sistemas
de gerenciamento de conteúdo (CMS - *Content Management Systems*), compartilhamento e execução
online de arquivos multimídia, entre outros exemplos, a necessidade de alta-performance e o chamado
*non-stop system* deixou de ser exclusividade para as telecoms.

Isto pode ser visto não apenas com a popularidade do Elixir, mas como do próprio Erlang, utilizado
por exemplo no desenvolvimento do WhatsApp, por grandes empresas como MasterCard, Nintendo, Amazon e
[entre outros](https://www.erlang-solutions.com/blog/which-companies-are-using-erlang-and-why-mytopdogstatus){:target="_blank"}.
No lado do Elixir, mesmo sendo uma tecnologia mais recente, temos casos de sucesso com as empresas
Pinterest, Financial Times, Discord (sim, aquele mesmo que você pra conversar com os amiguinhos em
jogos online), PepsiCo, Toyota Connected [etc](https://www.monterail.com/blog/famous-companies-using-elixir){:target="_blank"}.

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

Este comando gera uma estrutura de pastas e arquivos para abranger testes, dependências, ambiente e
versão.

**Curiosidade**: Arquivos de extensão ```.ex``` são compilados pelo Elixir para arquivos
```.beam```, que é o *bytecode* interpretado pela máquina virtual do Erlang, enquanto os de
extensão ```.exs``` rodam como *script*, ou seja, compilados e disponibilizados em memória RAM.
{: .notice--info}


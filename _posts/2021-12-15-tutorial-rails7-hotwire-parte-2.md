---
layout: single
title:  "Tutorial: Rails7, Tailwind e Hotwire - Parte 2"
date:   2021-12-09 20:23:03 -0300
tags: Tutorial Rails Ruby Tailwind Hotwire
description: >-
  Parte 1: Montando um layout com Tailwind - Tutorial sobre Rails 7 com esbuild, tailwind e
  Hotwire(Turbo e Stimulus). Como desenvolver um aplicação estilo Kanban, com cards/tarefas, com
  persistência simultânea via websockets.
categories: blog
header:
  og_image: assets/posts/hotwire-turbo.webp
---

![Hotwire Turbo](/assets/posts/hotwire-turbo.webp){: .align-center}

Na [parte anterior]({% post_url 2021-12-09-tutorial-rails7-hotwire-parte-1 %}){:target="_blank"}
deste tutorial eu expliquei à como customizar e utilizar o Tailwind sem uma linha se quer de CSS e
JavaScript. Agora vou abordar um pouco sobre o pacote
[Hotwire Turbo](https://turbo.hotwired.dev){:target="_blank"}.
<!-- excerpt-separator -->

## Objetivo Geral
A meta é desenvolver (e aprender) utilizando Rails 7, esbuild, Tailwind e Hotwire (Turbo e
Stimulus), mas meu foco será mais sobre o pacote Hotwire e como ele pode nos ajudar. Esta dividido
nas seguintes partes:
* [Parte 0: Rails 7]({% post_url 2021-12-07-tutorial-rails7-hotwire %}){:target="_blank"}
* [Parte 1: Tailwind]({% post_url 2021-12-09-tutorial-rails7-hotwire-parte-1 %}){:target="_blank"}
* [Parte 2: Hotwire Turbo](#etapa-2---hotwire-turbo) → página atual
* ~~Parte 3: Hotwire Stimulus~~ → em breve

O pano de fundo é uma aplicação estilo Kanban, com um quadro em que podemos incluir, ver, editar e
excluir os cards/tarefas e isso ser persistido simultaneamente via *websockets* para todas as
sessões abertas da aplicação. Todo código esta disponível neste
[repositório](https://github.com/callmarx/LearningHotwire){:target="_blank"}. Note que incluí
algumas [*branches*](https://github.com/callmarx/LearningHotwire/branches/all){:target="_blank"} que
representam as partes abordadas aqui.

## Etapa 2 - Hotwire Turbo
Nesta etapa explico sobre a proposta desta ferramenta e implemento o modo *render* `turbo_stream`
juntamente com o `broadcast` via *ActionCable*. O resultado desta etapa eu dividi em duas partes:
a *branch*
[blog-part-2.1](https://github.com/callmarx/LearningHotwire/tree/blog-part-2.2){:target="_blank"},
em que uso apenas o `turbo_stream` sem `broadcast`, e a final com `broadcast` na *branch*
[blog-part-2.2](https://github.com/callmarx/LearningHotwire/tree/blog-part-2.2){:target="_blank"}.

### Objetivo: Turbina o que?
Consultando a introdução do
[Handbook](https://turbo.hotwired.dev/handbook/introduction){:target="_blank"}, e fazendo uma
tradução livre, conceitualmente temos um pacote que
> Agrupa uma serie de ferramentas para criar aplicação web velozes, modernas e de aprimoramento
> progressivo, sem muito JavaScript.

Talvez a tradução de
[*Progressive Enhancement*](https://www.freecodecamp.org/news/what-is-progressive-enhancement-and-why-it-matters-e80c7aaf834a/){:target="_blank"} -
"aprimoramento progressivo" - não soe muito claro. Criado em 2003, trata-se de uma estratégia de
design, de arquitetura web, que enfatiza o carregamento progressivo da página, priorizando o
conteúdo principal (HTML) e distribuindo os demais (CSS, JavaScript, HTML adicionais etc) em outras
camadas de apresentação/carregamento.

Continuando minha tradução livre sobre as diretrizes do *Hotwire Turbo*
> Oferece uma alternativa mais simples contra a predominância das estruturas do lado do cliente,
> das quais colocam toda a lógica no front-end, confinando o lado do servidor da aplicação a ser
> pouco mais do que uma API JSON.

Este é o trecho que mais me chamou atenção, me conquistou, me incentivou a estudar e querer
utilizar isso. A "*predominância das estruturas do lado do cliente*" é algo que me vêm chamando
atenção nos últimos anos, parece que **de repente todo área do back-end foi "*confinada*" à API
JSON**. Porém, com todo dinamismo que uma página web precisa, como processamento de dados de acordo
com o comportamento do usuário e da navegação, isso acabou sendo feito pelo lado cliente, front-end,
via JavaScript com bibliotecas como jQuery. Como determinadas lógicas desse processamento devem
estar protegidas no back-end, não podendo serem completamente expostas no front-end, ou seja, não
podendo serem totalmente feitas no front-end, **nos deparamos eventualmente com "*espelhamentos da
lógica em ambos os lados*"**. E as diretrizes continuando exatamente nesse sentido.
> Com Turbo você permite que o servidor entregue HTML diretamente (...). Você não liderá mais com
> espelhamento da lógica em abos os lados da aplicação, permeados via JSON. Toda lógica reside no
> servidor e o navegador lida apenas com o HTML final.

É o conceito de HTML-Over-The-Wire - Hotwire. 🤓

### *Turbo Frame* VS. *Turbo Stream*
Algo que me confundiu bastante no começo foi a demora em entender a diferença entre *Turbo Frame* e
*Turbo Stream*, pois tratam-se de abordagens diferentes. Felizmente eu encontrei essa tabela
publicada pelo
[*The Pragmatic Programmers*](https://medium.com/pragmatic-programmers/turbo-frames-vs-turbo-streams-4eee1c574d23){:target="_blank"}.
```
---------------------------------------------------------------------------+---------------------------------------------------------------------------+
                Turbo Frames                                 |                     Turbo Streams                                                       |
----------------------------------------------------------------------------+--------------------------------------------------------------------------+
Altera apenas um elemento do DOM por requisição.             |  Altera inúmeros elementos do DOM por requisição.
Consegui apenas atualizar o elemento interno do HTML.        |  Pode concatenar ou preceder um novo elemento, além de atualizar ou remover um elemento.
Afeta apenas elementos dentro da tag turbo-frame com DOM ID. |  Afeta qualquer tipo de elemento HTML desde que tenha um DOM ID para ser referenciado.
É "ativado" na requisição dentro do elemento turbo-frame.    |  Ativado também via ActionCable/broadcasts.
```

**OBS**: Não pretendo utilizar o *Turbo Frames* neste projeto. Talvez eu repense isso para
aproveitar a funcionalidade de *lazily load*, mas se for o caso adicionarei um post separado sobre
isso.
{: .notice--info}

### Começando apenas com *Turbo Stream*
Para explicar separadamente o modo *render* `turbo_stream` eu incluí o código desta subparte na
[blog-part-2.1](https://github.com/callmarx/LearningHotwire/tree/blog-part-2.2){:target="_blank"}.

No `ChoresController` que geramos na
[etapa anterior]({% post_url 2021-12-09-tutorial-rails7-hotwire-parte-1 %}#um-simples-scaffold){:target="_blank"}
deste tutorial, por padrão o Rails incluiu múltiplos formatos de renderização, no caso HTML e JSON.
Como incluímos `gem "turbo-rails"` no Gemfile, temos acesso também à renderização via *Turbo Stream*,
bastando adicionar `format.turbo_stream` dentro do bloco `respond_to do |format|`. Fazendo isso
para os métodos *create* e *destroy*, temos em
[app/controllers/chores_controller.rb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/controllers/chores_controller.rb){:target="_blank"}:
```ruby
# app/controllers/chores_controller.rb
class ChoresController < ApplicationController
  ...
  def create
    ...
    respond_to do |format|
      if @chore.save
        format.turbo_stream # include this
        format.html { redirect_to @chore, notice: "Chore was successfully created." }
        format.json { render :show, status: :created, location: @chore }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chore.errors, status: :unprocessable_entity }
      end
    end
  end
  ...
  def destroy
    @chore.destroy
    respond_to do |format|
      format.turbo_stream # include this
      format.html { redirect_to chores_url, notice: "Chore was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  ...
end
```

Para esse tipo de renderização também precisamos de arquivos dedicados em `app/views`, como o temos
para HTML e JSON. Sendo assim, temos o seguinte
[app/views/chores/create.turbo_stream.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/create.turbo_stream.erb){:target="_blank"}:
```erb
<!-- app/views/chores/create.turbo_stream.erb -->
<%= turbo_stream.append "chores", partial: "chores/chore", locals: { chore: @chore } %>
<%= turbo_stream.replace "chore_form", partial: "chores/form", locals: { chore: Chore.new } %>
```

Como queremos ver a aplicação disso sem recarregar uma página inteira, ou seja, poder **renderizar
apenas uma parte** da página, o faremos no *index* de *chores*. Por isso usamos os métodos
`turbo_stream.append` e `turbo_stream.replace` acima apontados para o DOM ID da página, ou seja,
respectivamente os primeiros argumentos `"chores"` e `"chore_form"` devem estar presentes na página
**completamente renderizada** por
[app/views/chores/index.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/index.html.erb){:target="_blank"}.
Sendo isso assim precisamos incluir `id="chores"` na `<div>` que envolve a listagem dos *chores*:
```erb
<!-- app/views/chores/index.html.erb -->
<div ...>
  <div ...>
    <div id="chores" ...> <!-- include id="chores" for turbo_stream.append -->
      <% @chores.each do |chore| %>
        <%= render "chore", chore:chore %>
      <% end %>
    </div>
  </div>
  <div ...>               <!-- don't include id="chore_form" here!         -->
    <%= render "form", chore: @chore %>
  </div>
</div>
```

Agora, para `id="chore_form"`, não podemos incluir na `<div>` que envolve
`<%= render "form", chore: @chore %>` pois o método `turbo_stream.replace` **substitui completamente
o elemento** e como o fazemos substituindo pelo *partial view*
[app/views/chores/_form.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/_form.html.erb){:target="_blank"}
essa `<div>` seria apagada, sendo assim devemos incluir `id="chore_form"` no próprio arquivo *form*:
```erb
<!-- app/views/chores/_form.html.erb -->
<%= form_with(model: chore, id: "chore_form") do |form| %>
  ...
<% end %>
```

Com isso temos o seguinte resultado ao criar um novo *chore*, note que não há um carregamento total
da página a cada inclusão, a página é recarregada parcialmente via
[*fetch*](https://developer.mozilla.org/pt-BR/docs/Web/API/Fetch_API/Using_Fetch){:target="_blank"}.
{% include video id="1DmtL-9P9SylUJet2MJjMrqiHCySCCng5" provider="google-drive" %}

Agora, para excluir um *chore* é ainda mais simples, temos o seguinte
[app/views/chores/destroy.turbo_stream.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/destroy.turbo_stream.erb){:target="_blank"}
```erb
<!-- app/views/chores/destroy.turbo_stream.erb -->
<%= turbo_stream.remove dom_id(@chore) %>
```

Da mesma forma, devemos incluir o DOM ID, mas no caso um específico para cada *chore*, por isso o
`dom_id(@chore)`. Além disso, também precisamos editar o `<button>` do ícone de exclusão para
apontar para o método delete do controller, sendo assim em:
[app/views/chores/_chore.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/_chore.html.erb){:target="_blank"}
```erb
<!-- app/views/chores/_chore.html.erb -->
<div id="<%= dom_id(chore) %>" ...> <!-- include dom_id(chore) for turbo_stream.remove -->
  <div ...>
    ...
    <div ...>
      ...
      <%= button_to chore_path(chore), method: :delete, class: ... do %> <!-- make button point to delete method -->
        <svg ...>
          ...
        </svg>
      <% end %>
      ...
```

Agora, ao remover um *chore* temos também uma **renderização parcialmente** que remove o HTML do
*chore* excluído sem recarregar toda a página. Porém, se você abrir duas janelas de
<http://localhost:3000/chores>{:target="_blank"} e incluir ou excluir *chores* em uma delas verá
que as alterações são feita apenas na janela que você fez isso, **não haverá persistência em todas
as sessões**. Para isso precisamos fazer via *ActionCable* com `broadcast`.

### Aplicando *broadcast*

```ruby
```
### Resultado final
Essas alterações correspondem basicamente ao que há na *branch*
[blog-part-2](https://github.com/callmarx/LearningHotwire/tree/blog-part-2){:target="_blank"}.
Então, agora se você subir o projeto com `bin/dev` e acessar <http://localhost:3000/chores>{:target="_blank"},
deve obter este resultado:
{% include video id="1DmtL-9P9SylUJet2MJjMrqiHCySCCng5" provider="google-drive" %}


Por agora, é isso.
<div class="tenor-gif-embed" data-postid="16435573" data-share-method="host" data-aspect-ratio="1.5311" data-width="100%">
  <a href="https://tenor.com/view/cat-driving-leaving-meow-im-leaving-right-meow-gif-16435573">
</div>
<script type="text/javascript" async src="https://tenor.com/embed.js"></script>

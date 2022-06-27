---
layout: single
title:  "Tutorial: Rails7, Tailwind e Hotwire - Parte 3"
date:   2022-06-27 14:42:03 -0300
tags: Tutorial Rails Ruby Tailwind Hotwire
description: >-
  Parte 3: Modal para inserção e edição com Stimulus. Rails 7 com esbuild, tailwind e
  Hotwire (Turbo e Stimulus) - Como desenvolver um aplicação estilo Kanban, com cards/tarefas e
  persistência simultânea via websockets.
categories: blog
header:
  og_image: assets/posts/hotwire-turbo.webp
---

![Hotwire Turbo](/assets/posts/hotwire-turbo.webp){: .align-center}

Na [parte anterior]({% post_url 2021-12-19-tutorial-rails7-hotwire-parte-2 %}){:target="_blank"}
deste tutorial eu expliquei como utilizar a renderização parcial de html com `turbo_stream` do
[Hotwire Turbo](https://turbo.hotwired.dev){:target="_blank"}, o que nos permitiu mostrar os cards
recem inseridos ou excluidos do nosso humilde prototipo de Kanban. Agora vou abordar sobre
o pacote [Hotwire Stimulus](https://stimulus.hotwired.dev/){:target="_blank"}.
<!-- excerpt-separator -->

## Objetivo Geral
A meta é desenvolver (e aprender) utilizando Rails 7, esbuild, Tailwind e Hotwire (Turbo e
Stimulus), mas meu foco será mais sobre o pacote Hotwire e como ele pode nos ajudar. Conforme
avanço nos estudos e na implementação, vou complementando este tutorial. Por enquanto temos:
* [Parte 0: Rails 7]({% post_url 2021-12-07-tutorial-rails7-hotwire %}){:target="_blank"}
* [Parte 1: Tailwind]({% post_url 2021-12-09-tutorial-rails7-hotwire-parte-1 %}){:target="_blank"}
* [Parte 2: Hotwire Turbo]({% post_url 2021-12-19-tutorial-rails7-hotwire-parte-2 %}){:target="_blank"}
* [Parte 3: Hotwire Stimulus](#etapa-3---hotwire-stimulus) → página atual

O pano de fundo é uma aplicação estilo Kanban, com um quadro em que podemos incluir, ver, editar e
excluir os cards/tarefas e isso ser persistido simultaneamente via *websockets* para todas as
sessões abertas da aplicação. Todo código esta disponível neste
[repositório](https://github.com/callmarx/LearningHotwire){:target="_blank"}. Note que incluí
algumas [*branches*](https://github.com/callmarx/LearningHotwire/branches/all){:target="_blank"} que
representam as partes abordadas aqui.

## Etapa 3 - Hotwire Stimulus
Nesta etapa final, implemento um modal (o famoso pop-up que não é exatamente um pop-up) do qual
será controlado por JS através do Hotwire Stimulus.


### Breve introdução sobre Stimulus no Rails


### Foi só falar que eu não ia usar turbo-frame que...
Na etapar anterior, na parte que faço uma breve explicação sobre a diferença entre
[turbo-frame e turbo-stream]({% post_url 2021-12-19-tutorial-rails7-hotwire-parte-2 %}#turbo-frame-vs-turbo-stream){:target="_blank"},
coloquei uma observação dizendo que não pretendia utilizar o turbo-frame e eis q surge a
oportunidade: com ele podemos renderizar dinamicamente o formulário do *chore* para usuário quando
ele precisar inserir ou editar.

Coloquei essa parte,  na *branch*

Primeiro incluí a linha `<%= turbo_frame_tag "modal" %>` no arquivo
[app/views/layouts/application.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/layouts/application.html.erb){:target="_blank"},
resultando no seguinte:
```erb
<!-- file app/views/layouts/application.html.erb of blog-part-3.1 branch -->
<!DOCTYPE html>
<html>
  <head>
    <title>LearningHotwire</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>
  </head>

  <body>
    <%= turbo_frame_tag "modal" %>
    <%= yield %>
  </body>
</html>
```

Depois envolvi o conteudo de
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/chores/new.html.erb){:target="_blank"},
pelo *block* de `<%= turbo_frame_tag "modal" do %>...<% end %>`, mas que no caso ficou apenas para
dar o *render* do *partial form*, ou seja:
```erb
<!-- file app/views/chores/new.html.erb of blog-part-3.1 branch -->
<%= turbo_frame_tag "modal" do %>
  <%= render "form", chore: @chore %>
<% end %>
```

E então, alterei o link de inserir um novo *chore* adicionando a opção
`data: { turbo_frame: 'modal' }` em
[app/views/chores/index.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/chores/index.html.erb){:target="_blank"},
também incluí um ícone para o botão e removi o `render` do `form` que tinha no final:
```erb
<!-- file app/views/chores/index.html.erb of blog-part-3.1 branch -->
<%= turbo_stream_from "chores" %>
<div class="z-0 flex flex-col h-screen bg-slate-300">
  <div class="flex justify-end py-2">
    <%= link_to new_chore_path,
      data: { turbo_frame: 'modal' }, # required for turbo frame
      class:"flex m-1 mr-12 p-2 w-fit h-fit text-white bg-slate-600 hover:bg-slate-900 rounded-md" do %>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
        <path d="M8 0c-.176 0-.35.006-.523.017l.064.998a7.117 7.117 0 0 1 .918 0l.064-.998A8.113 8.113 0 0 0 8 0zM6.44.152c-.346.069-.684.16-1.012.27l.321.948c.287-.098.582-.177.884-.237L6.44.153zm4.132.271a7.946 7.946 0 0 0-1.011-.27l-.194.98c.302.06.597.14.884.237l.321-.947zm1.873.925a8 8 0 0 0-.906-.524l-.443.896c.275.136.54.29.793.459l.556-.831zM4.46.824c-.314.155-.616.33-.905.524l.556.83a7.07 7.07 0 0 1 .793-.458L4.46.824zM2.725 1.985c-.262.23-.51.478-.74.74l.752.66c.202-.23.418-.446.648-.648l-.66-.752zm11.29.74a8.058 8.058 0 0 0-.74-.74l-.66.752c.23.202.447.418.648.648l.752-.66zm1.161 1.735a7.98 7.98 0 0 0-.524-.905l-.83.556c.169.253.322.518.458.793l.896-.443zM1.348 3.555c-.194.289-.37.591-.524.906l.896.443c.136-.275.29-.54.459-.793l-.831-.556zM.423 5.428a7.945 7.945 0 0 0-.27 1.011l.98.194c.06-.302.14-.597.237-.884l-.947-.321zM15.848 6.44a7.943 7.943 0 0 0-.27-1.012l-.948.321c.098.287.177.582.237.884l.98-.194zM.017 7.477a8.113 8.113 0 0 0 0 1.046l.998-.064a7.117 7.117 0 0 1 0-.918l-.998-.064zM16 8a8.1 8.1 0 0 0-.017-.523l-.998.064a7.11 7.11 0 0 1 0 .918l.998.064A8.1 8.1 0 0 0 16 8zM.152 9.56c.069.346.16.684.27 1.012l.948-.321a6.944 6.944 0 0 1-.237-.884l-.98.194zm15.425 1.012c.112-.328.202-.666.27-1.011l-.98-.194c-.06.302-.14.597-.237.884l.947.321zM.824 11.54a8 8 0 0 0 .524.905l.83-.556a6.999 6.999 0 0 1-.458-.793l-.896.443zm13.828.905c.194-.289.37-.591.524-.906l-.896-.443c-.136.275-.29.54-.459.793l.831.556zm-12.667.83c.23.262.478.51.74.74l.66-.752a7.047 7.047 0 0 1-.648-.648l-.752.66zm11.29.74c.262-.23.51-.478.74-.74l-.752-.66c-.201.23-.418.447-.648.648l.66.752zm-1.735 1.161c.314-.155.616-.33.905-.524l-.556-.83a7.07 7.07 0 0 1-.793.458l.443.896zm-7.985-.524c.289.194.591.37.906.524l.443-.896a6.998 6.998 0 0 1-.793-.459l-.556.831zm1.873.925c.328.112.666.202 1.011.27l.194-.98a6.953 6.953 0 0 1-.884-.237l-.321.947zm4.132.271a7.944 7.944 0 0 0 1.012-.27l-.321-.948a6.954 6.954 0 0 1-.884.237l.194.98zm-2.083.135a8.1 8.1 0 0 0 1.046 0l-.064-.998a7.11 7.11 0 0 1-.918 0l-.064.998zM8.5 4.5a.5.5 0 0 0-1 0v3h-3a.5.5 0 0 0 0 1h3v3a.5.5 0 0 0 1 0v-3h3a.5.5 0 0 0 0-1h-3v-3z"/>
      </svg>
      <span class="ml-2 font-semibold">New Chore</span>
    <% end %>
  </div>
  <div class="z-0 w-4/5 mx-auto overflow-hidden h-4/5 bg-slate-200 rounded-md transition transform duration-600 ease-in-out hover:bg-slate-400 hover:overflow-visible">
    <div id="chores" class="z-0 px-5 pt-1 pb-3 grid grid-cols-3 gap-2">
      <% @chores.each do |chore| %>
        <%= render "chore", chore:chore %>
      <% end %>
    </div>
  </div>
</div> <!-- remove 'render "form"'
```
com isso, quando você clicar no butão *New Chore*, será incluido
`src="http://localhost:3000/chores/new"` na area reservado com `<%= turbo_frame_tag "modal" %>` que
agora esta no arquivo
[app/views/layouts/application.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/layouts/application.html.erb){:target="_blank"}
e com isso
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/chores/new.html.erb){:target="_blank"}
será renderizado dinamicamente dentro desta tag.

**Por o gif!!!!**

**OBS**: EXPLICAR QUE POR NO app/views/layouts/application.html.erb MAPEAMOS TODA APLICAÇÃO
{: .notice--info}



### Primeiros passados com Stimulus
Primeiro gerei um "novo stimulus" no projeto, com seguinte comando e saída:
```bash
$ rails generate stimulus chore-modal
       create  app/javascript/controllers/chore_modal_controller.js
       rails  stimulus:manifest:update
```


Para explicar separadamente o modo *render* `turbo_stream` eu incluí o código desta subparte na
*branch* [blog-part-2.1](https://github.com/callmarx/LearningHotwire/tree/blog-part-2.1){:target="_blank"}.

No `ChoresController` que geramos com `rails generate scaffold` na
[etapa anterior]({% post_url 2021-12-09-tutorial-rails7-hotwire-parte-1 %}#um-simples-scaffold){:target="_blank"}
deste tutorial, por padrão o Rails incluiu múltiplos formatos de renderização, no caso HTML e JSON.
Como incluímos `gem "turbo-rails"` no Gemfile, temos acesso também à renderização via *Turbo Stream*,
bastando adicionar `format.turbo_stream` dentro do bloco `respond_to do |format|`. Fazendo isso
para os métodos *create* e *destroy*, temos em
[app/controllers/chores_controller.rb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/controllers/chores_controller.rb){:target="_blank"}:
```ruby
# file app/controllers/chores_controller.rb of blog-part-2.1 branch
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
<!-- file app/views/chores/create.turbo_stream.erb of blog-part-2.1 branch -->
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
<!-- file app/views/chores/index.html.erb  of blog-part-2.1 branch -->
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
<!-- file app/views/chores/_form.html.erb  of blog-part-2.1 branch -->
<%= form_with(model: chore, id: "chore_form") do |form| %>
  ...
<% end %>
```


Agora, para excluir um *chore* é ainda mais simples, temos o seguinte
[app/views/chores/destroy.turbo_stream.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/destroy.turbo_stream.erb){:target="_blank"}
```erb
<!-- file app/views/chores/destroy.turbo_stream.erb of blog-part-2.1 branch -->
<%= turbo_stream.remove dom_id(@chore) %>
```

Da mesma forma, devemos incluir o DOM ID, mas no caso um específico para cada *chore*, por isso o
`dom_id(@chore)`. Além disso, também precisamos editar o `<button>` do ícone de exclusão para
apontar para o método *destroy* do *controller*, sendo assim em:
[app/views/chores/_chore.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.1/app/views/chores/_chore.html.erb){:target="_blank"}
```erb
<!-- file app/views/chores/_chore.html.erb of blog-part-2.1 branch -->
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

Agora, ao remover um *chore*, também teremos uma **renderização parcialmente** que remove o HTML do
*chore* excluído sem recarregar toda a página. O resultado final desta subparte, ao criar ou
excluir um *chore* em <http://localhost:3000/chores>{:target="_blank"}, é o seguinte:
{% include video id="1pIKgDLLIK4LFVMVSQmc-p0xUKjYtiqNI" provider="google-drive" %}

**OBS**: Note que não há um carregamento total da página a cada inclusão ou exclusão, a página é
recarregada parcialmente via
[*fetch*](https://developer.mozilla.org/pt-BR/docs/Web/API/Fetch_API/Using_Fetch){:target="_blank"}.
{: .notice--info}


Porém, se você abrir duas janelas de <http://localhost:3000/chores>{:target="_blank"} e incluir ou
excluir *chores* em uma delas verá que as alterações são feitas apenas na janela que está
manipulando isso, **não haverá persistência em todas as sessões**. Para isso precisamos fazer via
*ActionCable* com `broadcast`.

### Aplicando *broadcast*
Aqui corresponde a parte final desta etapa do tutorial. A subparte anterior foi apenas para
explicar o uso isolado do *render* `turbo_stream`, como objetivo é uma aplicação estilo Kanban
pretendo utilizar majoritariamente esse *render* juntamente com `broadcast` daqui para frente. O
código completo desta etapa está na *branch*
[blog-part-2.2](https://github.com/callmarx/LearningHotwire/tree/blog-part-2.2){:target="_blank"}.

Para aplicarmos as alterações dos *chores* em todas as sessões utilizaremos o
`Turbo::StreamsChannel` que vem com a gema `turbo-rails`, podendo ser chamado diretamente no
*model* ou no *controller* dependendo da abordagem que desejar. A ideia aqui é que **estaremos
implementando as renderizações parciais em um padrão
[Publish/Subscribe](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern){:target="_blank"}**.
Por trás dos panos estaremos usando o *Active Jobs* para "publicar" (*publish*) a renderização
parcial do `turbo_stream` de maneira assíncrona e o *Action Cable* para entregar essas atualizações
aos "assinantes" (*subscribers*).

No caso, nossos "assinantes" são todas as sessões abertas de
<http://localhost:3000/chores>{:target="_blank"} e podemos mapear isso usando o helper
`turbo_stream_from`. Sendo assim, em
[app/views/chores/index.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.2/app/views/chores/index.html.erb){:target="_blank"},
temos:
```erb
<!-- file app/views/chores/index.html.erb  of blog-part-2.2 branch -->
<%= turbo_stream_from "chores" %>
<div ...>
  ...
</div>
```

Como disse antes, podemos incluir `Turbo::StreamsChannel` no *model* ou *controller* para cobrir as
modificações de *create*, *update* e *delete*, mais especificamente através dos métodos
`.broadcast_append_to`, `.broadcast_replace_to`, `.broadcast_remove_to` entre outros. Se incluirmos
isso no *model* através de *Active Record Callbacks*, como `after_create_commit`, **toda vez que o
*model* for alterado** iremos disparar "publicações" de renderização parcial. Como por enquanto eu
quero disparar as alterações feitas apenas através de requisições do usuário - não quero que
`rails db:seed` dispare isso, por exemplo - optei por incluir no *controller*. Sendo assim em
[app/controllers/chores_controller.rb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.2/app/controllers/chores_controller.rb){:target="_blank"},
temos:
```ruby
# file app/controllers/chores_controller.rb of blog-part-2.2 branch
class ChoresController < ApplicationController
  before_action :set_chore, only: %i[ show edit update destroy ]
  after_action :broadcast_insert, only: %i[create]
  after_action :broadcast_remove, only: %i[destroy]

  ...

  private
    ...
    def broadcast_insert
      return if @chore.errors.any?
      Turbo::StreamsChannel.broadcast_append_to(
        "chores",
        target: "chores",
        partial: "chores/chore",
        locals: { chore: @chore }
      )
    end

    def broadcast_remove
      return unless @chore.destroyed?
      Turbo::StreamsChannel.broadcast_remove_to(
        "chores",
        target: ActionView::RecordIdentifier.dom_id(@chore)
      )
    end
end
```

Como os métodos privados `broadcast_insert` e `broadcast_remove` acima já fazem a inserção e
exclusão dos *chores* não precisamos mais fazer isso nas *views* `*.turbo_stream.erb` que criamos
na subparte anterior, por isso para essa parte final eu excluí a *view*
`app/views/destroy.turbo_stream.erb` e mantive
[app/views/chores/create.turbo_stream.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-2.2/app/views/chores/create.turbo_stream.erb){:target="_blank"},
com apenas:
```erb
<!-- file app/views/chores/create.turbo_stream.erb of blog-part-2.2 branch -->
<%= turbo_stream.replace "chore_form", partial: "chores/form", locals: { chore: Chore.new } %>
```
**OBS**: Não sei se você notou, mas não estamos "publicando" o *replace* do *form* via *ActionCable*
como as outras renderizações parciais. Mantive aqui o `turbo_stream` para sessão corrente apenas, o
que faz total sentido já que não precisamos limpar o *form* nas outras sessões, inclusive se
fizermos isso poderemos apagar o *form* de um outro usuário que o está preenchendo e não submeteu
ainda.
{: .notice--info}

Pronto! Basta subir o projeto com `bin/dev` e acessar em mais de uma janela
<http://localhost:3000/chores>{:target="_blank"}, você deve obter este resultado final:
{% include video id="1DmtL-9P9SylUJet2MJjMrqiHCySCCng5" provider="google-drive" %}

<div class="tenor-gif-embed" data-postid="14693686" data-share-method="host" data-aspect-ratio="1.78771" data-width="100%">
  <a href="https://tenor.com/view/nice-finger-gone-well-done-happy-woohoo-gif-14693686"></a>
</div>
<script type="text/javascript" async src="https://tenor.com/embed.js"></script>

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

![Hotwire Stimulus Logo](/assets/posts/stimulus-logo.webp){: .align-center}

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
Nesta etapa final, implemento um *modal* (o famoso pop-up que não é exatamente um pop-up) do qual
será controlado por JS através do Hotwire Stimulus. Dividi essa etapa em 3 *branches*:
* [blog-part-3.1](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1){:target="_blank"} -
  Em que uso a tag Turbo Frame e o Stimulus para renderizar um html dinamicamente e depois remove-lo;
* [blog-part-3.2](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2){:target="_blank"} -
  Em que uso um pouco mais de Tailwind para fazer o *modal* e o Stimulus para lidar com outras ações necessárias;
* [blog-part-3.4](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.3){:target="_blank"} -
  Subparte bonus, em que uso a gema [ViewComponent](https://viewcomponent.org/){:target="_blank"}
  para agrupar melhor o código do *modal*.

### Breve introdução sobre Stimulus no Rails

### Foi só falar que eu não ia usar Turbo Frame que...
Na etapar anterior, na parte que faço uma breve explicação sobre a diferença entre
[turbo-frame e turbo-stream]({% post_url 2021-12-19-tutorial-rails7-hotwire-parte-2 %}#turbo-frame-vs-turbo-stream){:target="_blank"},
coloquei uma observação dizendo que não pretendia utilizar o Turbo Frame e eis q surge a
oportunidade: com ele podemos renderizar dinamicamente o formulário do *chore* para usuário quando
ele precisar inserir ou editar.

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
    <%= turbo_frame_tag "modal" %> <!-- include this -->
    <%= yield %>
  </body>
</html>
```

Depois envolvi o conteudo de
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/46e4871993ac592a990d7d0e3a4e7c29d0e69626/app/views/chores/new.html.erb){:target="_blank"},
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
</div> <!-- remove 'render "form"' -->
```
com isso, quando você clicar no butão *New Chore*, será incluido
`src="http://localhost:3000/chores/new"` na area reservado com `<%= turbo_frame_tag "modal" %>` que
agora esta no arquivo
[app/views/layouts/application.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/layouts/application.html.erb){:target="_blank"}
e com isso
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/chores/new.html.erb){:target="_blank"}
será renderizado dinamicamente dentro desta tag.
![Triggering Turbo Frame](/assets/posts/gifs/triggering-turbo-frame.gif){: .align-center}


**OBS**: Eu coloquei `<%= turbo_frame_tag "modal" %>` em "app/views/layouts/application.html.erb"
porque eu espero poder renderizar o *modal* de inserção em qualquer página da minha aplicação. Como
se trata de Kanban, o usuário provavelmente gostaria de inserir um novo card em qualquer página,
mas isso poderia ser feito, por exemplo, apenas quando estamos vendo todos os cards, ou seja, em
"app/views/chores/index.html.erb".
{: .notice--info}

Note que uma vez clicado em "New Chore", não é possivel remover o formulário, seja com um botão de
fechar ou mesmo após a inserção de um novo card. Para isso utilizaremos o Stimulus como mostrarei
nos próximos passos.

### Primeiros passados com Stimulus
Primeiro gerei um "novo stimulus" no projeto, com seguinte comando e saída:
```bash
$ rails generate stimulus chore-modal
       create  app/javascript/controllers/chore_modal_controller.js
       rails  stimulus:manifest:update
```

Como observado antes, não é possivel "remover" o html inserido dinamicamente pelo turbo-frame,
então vamos fazer isso como nosso primeiro método de `ChoreModalController`, em
[app/javascript/controllers/chore_modal_controller.js](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/javascript/controllers/chore_modal_controller.js){:target="_blank"}:
```js
// file app/javascript/controllers/chore_modal_controller.js of blog-part-3.1 branch
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chore-modal"
export default class extends Controller {
  connect() {
    console.log("Hi! we are in ChoreModalController from Stimulus")
  }

  // action: "chore-modal#hideModal"
  hideModal() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
    console.log("You've just called ChoreModalController#hideModal")
  }
}
```
Para fechar o formulário de inserção eu simplesmente removo o atributo `src` do elemento pai, que
no caso precisará ser o da tag `<turbo-frame ...></turbo-frame>`. Note também que incluí alguns
`console.log()` para mostrar quando estamos passando por cada parte de `ChoreModalController`.

Agora precisamos dizer em que parte do nosso html iremos chama-lo, para isso basta envolver sob
alguma `div` com `data-controller="chore-modal"`. Também é necessario dizer onde estará a ação que
invocará `ChoreModalController#hideModal` e isso é feito com `data-action="chore-modal#hideModal"`.
Sendo assim,
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1/app/views/chores/new.html.erb){:target="_blank"}
ficou:
```erb
<!-- file app/views/chores/new.html.erb of blog-part-3.1 branch -->
<%= turbo_frame_tag "modal" do %>
  <%= tag.div data: { controller: "chore-modal" } do %>
    <%= render "form", chore: @chore %>
    <%= button_tag "Close", data: { action: "chore-modal#hideModal" }, type: "button", class: "fixed top-0 right-0 rounded-lg p-3 m-2 bg-red-700 text-white" %>
  <% end %>
<% end %>
```
A ação onde apliquei `data-action="chore-modal#hideModal"` foi em um botão vermelho com "Close".
No caso, o erb `<%= button_tag ... %>` irá resultar no seguinte html:

```html
<button
  name="button"
  type="button"
  data-action="chore-modal#hideModal"
  class="fixed right-0 rounded-lg p-3 m-2 bg-red-700 text-white">Close</button>
```
e como `<%= tag.div data: { controller: "chore-modal" } do %>` está dentro de
`<%= turbo_frame_tag "modal" do %>`, `ChoreModalController#hideModal` irá remover `src` da tag
`<turbo-frame id="modal" ...></turbo-frame>`.

O resultado esperado é o seguinte:
![Removing rendered Turbo Frame with Stimulus](/assets/posts/gifs/removing-turbo-frame.gif){: .align-center}

E na aba "Console" podemos ver os `Console.log()` que coloquei:
![Removing rendered Turbo Frame with Stimulus - Console](/assets/posts/gifs/removing-turbo-frame-console.gif){: .align-center}

Tudo o que foi feito até aqui é o que corresponde a *branch*
[blog-part-3.1](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.1).

### Mas e o modal?

Bem, o formulário de inserção por enquanto é incluido no topo da página movendo todo resto para
baixo. Definitivamente não é um *modal* ~~e nada bonito ou agradavel~~. Para isso basta utilizarmos o
Tailwind.

Em
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/views/chores/new.html.erb){:target="_blank"},
temos:
```erb
<!-- file app/views/chores/new.html.erb of blog-part-3.2 branch -->
<%= turbo_frame_tag "modal" do %>
  <%= tag.div data: {
      controller: "chore-modal",
    },
    # include the following classes
    class: "z-40 fixed flex justify-center inset-0 bg-gray-600 bg-opacity-50 h-screen w-screen" do %>
    <div class="flex flex-col p-4 m-12 rounded-md w-2/3 h-2/3 bg-slate-200 rounded-md hover:bg-slate-400 transition duration-600 ease-linear">
      <div class="flex justify-between">
        <div></div>
        <div></div>
        <!-- replace button to a better one -->
        <%= button_tag data: { action: "chore-modal#hideModal" }, type: "button", class: "flex-none w-8 h-8 text-slate-600 hover:text-black transition-all duration-600 ease-in-out" do %>
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" viewBox="0 0 16 16">
            <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.354 4.646a.5.5 0 1 0-.708.708L7.293 8l-2.647 2.646a.5.5 0 0 0 .708.708L8 8.707l2.646 2.647a.5.5 0 0 0 .708-.708L8.707 8l2.647-2.646a.5.5 0 0 0-.708-.708L8 7.293 5.354 4.646z"/>
          </svg>
        <% end %>
      </div>
      <%= render "form", chore: @chore %>
    </div>
  <% end %>
<% end %>
```

Com as classes `fixed` e `z-40`, o tailwind irá montar um CSS que ira sobrepor o formulário em cima
do resto do conteúdo da página. Somado com `h-screen`, `w-screen`, `bg-gray-600` e `bg-opacity-50`,
siginifica que esse *modal* ocupara a tela toda, mas com a cor cinza e transparente de background.
Também aproveitei para trocar o botão vermelho ~~gritante, que ficou horrivel,~~ de "Close" por um
ícone "x" cinza escuro mais discreto no canto superior direito, ficando assim:
![tailwind modal](/assets/posts/tailwind-modal.webp){: .align-center}

### Mais ações com Stimulus
Por enquanto o *modal* só é fechado ao clicar no ícone "x", precisariamos, no mínimo, fechar também
após a inserção bem sucedida de um *chore*. Felizmente, o pacote Hotwire Turbo emite uma série de
eventos que permitem rastrear o ciclo de navegação. A lista completa desses eventos pode ser
verificada [aqui](https://turbo.hotwired.dev/reference/events){:target="_blank"}.

Para o nosso caso, temos o evento `turbo:submit-end` que é disparado logo depois que uma submissão
de formulário é feita, armazenando as propriedade de `FormSubmissionResult`, ou seja, o resultado
da submissão, em `event.detail`. Assim, em
[app/javascript/controllers/chore_modal_controller.js](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/javascript/controllers/chore_modal_controller.js){:target="_blank"},
temos:
```js
// file app/javascript/controllers/chore_modal_controller.js of blog-part-3.2 branch
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chore-modal"
export default class extends Controller {
  // action: "chore-modal#hideModal"
  hideModal() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }

  // action: "turbo:submit-end->chore-modal#submitEnd"
  submitEnd(e) { // include this method
    if (e.detail.success) {
      this.hideModal()
    }
  }
}
```
Perceba que verificamos se `e.detail` foi bem sucedido para então chamar o método `hideModal()`.
Vale ressaltar que o método nomeado `submitEnd()` **não esta relacionado** ainda ao evento
`turbo:submit-end`. Isso deve ser feito no atributo `data-action` onde `ChoreModalController` é
chamado, ou seja, em
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/views/chores/new.html.erb){:target="_blank"}:
```erb
<!-- file app/views/chores/new.html.erb of blog-part-3.2 branch -->
<%= turbo_frame_tag "modal" do %>
  <%= tag.div data: {
      controller: "chore-modal",
      action: "turbo:submit-end->chore-modal#submitEnd" # include this
    },
    class: "z-40 fixed flex justify-center inset-0 bg-gray-600 bg-opacity-50 h-screen w-screen" do %>
    <div class="flex flex-col p-4 m-12 rounded-md w-2/3 h-2/3 bg-slate-200 rounded-md hover:bg-slate-400 transition duration-600 ease-linear">
      <div class="flex justify-between">
        <div></div>
        <div></div>
        <%= button_tag data: { action: "chore-modal#hideModal" }, type: "button", class: "flex-none w-8 h-8 text-slate-600 hover:text-black transition-all duration-600 ease-in-out" do %>
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" viewBox="0 0 16 16">
            <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.354 4.646a.5.5 0 1 0-.708.708L7.293 8l-2.647 2.646a.5.5 0 0 0 .708.708L8 8.707l2.646 2.647a.5.5 0 0 0 .708-.708L8.707 8l2.647-2.646a.5.5 0 0 0-.708-.708L8 7.293 5.354 4.646z"/>
          </svg>
        <% end %>
      </div>
      <%= render "form", chore: @chore %>
    </div>
  <% end %>
<% end %>
```

Quando incluo `<div ... data-action="turbo:submit-end->chore-modal#submitEnd" ...>`, agora sim,
estou dizendo para chamar `ChoreModalController#submitEnd()` quando o evento `turbo:submit-end` for
disparado. Para testar que inserção mal sucedida de um *chore* não feche o *modal*, inclui o seguinte
validador em
[app/models/chore.rb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/models/chore.rb){:target="_blank"}:
```ruby
# file app/models/chore.rb of blog-part-3.2 branch

class Chore < ApplicationRecord
  validates :title, presence: true # include this
end
```

O resultado ficou o seguinte:
![Turbo submit-end event](/assets/posts/gifs/turbo--submit-end--event.gif){: .align-center}


Aproveitei outros eventos para implementar mais situações em que o usuário gostaria que o *modal*
feche, no caso ao pressionar a tecla ESC e ao clicar "fora" do *modal*, ou seja, no background cinza
transparente. Em
[app/javascript/controllers/chore_modal_controller.js](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/javascript/controllers/chore_modal_controller.js){:target="_blank"}:
```js
// file app/javascript/controllers/chore_modal_controller.js of blog-part-3.2 branch
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chore-modal"
export default class extends Controller {
  static targets = ["form"]

  // hide modal
  // action: "chore-modal#hideModal"
  hideModal() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }

  // hide modal on successful form submission
  // action: "turbo:submit-end->chore-modal#submitEnd"
  submitEnd(e) {
    if (e.detail.success) {
      this.hideModal()
    }
  }

  // hide modal when clicking ESC
  // action: "keyup@window->chore-modal#closeWithKeyboard"
  closeWithKeyboard(e) {
    if (e.code == "Escape") {
      this.hideModal()
    }
  }

  // hide modal when clicking outside of modal
  // action: "click@window->chore-modal#closeBackground"
  closeBackground(e) {
    if (e && this.formTarget.contains(e.target)) { // check with user are clicking inside the form
      return
    }
    this.hideModal()
  }
}
```

E em
[app/views/chores/new.html.erb](https://github.com/callmarx/LearningHotwire/blob/blog-part-3.2/app/views/chores/new.html.erb){:target="_blank"}:
```erb
<!-- file app/views/chores/new.html.erb of blog-part-3.2 branch -->
<%= turbo_frame_tag "modal" do %>
  <%= tag.div data: {
      controller: "chore-modal",
      # include all other actions separated with espace
      action: "turbo:submit-end->chore-modal#submitEnd keyup@window->chore-modal#closeWithKeyboard click@window->chore-modal#closeBackground"
    },
    class: "z-40 fixed flex justify-center inset-0 bg-gray-600 bg-opacity-50 h-screen w-screen" do %>
    <%= tag.div data: { chore_modal_target: "form" }, # include this data
      class: "flex flex-col p-4 m-12 rounded-md w-2/3 h-2/3 bg-slate-200 rounded-md hover:bg-slate-400 transition duration-600 ease-linear" do %>
      <div class="flex justify-between">
        <div></div>
        <div></div>
        <%= button_tag data: { action: "chore-modal#hideModal" }, type: "button", class: "flex-none w-8 h-8 text-slate-600 hover:text-black transition-all duration-600 ease-in-out" do %>
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" viewBox="0 0 16 16">
            <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.354 4.646a.5.5 0 1 0-.708.708L7.293 8l-2.647 2.646a.5.5 0 0 0 .708.708L8 8.707l2.646 2.647a.5.5 0 0 0 .708-.708L8.707 8l2.647-2.646a.5.5 0 0 0-.708-.708L8 7.293 5.354 4.646z"/>
          </svg>
        <% end %>
      </div>
      <%= render "form", chore: @chore %>
    <% end %>
  <% end %>
<% end %>
```



---
layout: single
title:  "Tutorial: Rails7, Tailwind e Hotwire"
date:   2021-12-07 17:48:12 -0300
tags: Tutorial Rails Ruby Tailwind Hotwire
description: >-
  Tutorial sobre Rails 7 com esbuild, tailwind e Hotwire(Turbo e Stimulus). Como desenvolver um
  aplicação estilo Kanban, com cards/tarefas, com persistência simultânea via websockets.
categories: blog
header:
  og_image: assets/posts/rails7-tailwind-hotwire.webp
---

![Rails 7 + Tailwind + Hotwire](/assets/posts/rails7-tailwind-hotwire.webp){: .align-center}

<br/>
Depois de meses desenvolvendo em Typescript com [NestJS](https://docs.nestjs.com/){:target="_blank"}
por demanda do meu atual trabalho, consegui um tempinho para meu tão amado Ruby on Rails. Melhor
ainda agora, como não trabalho oficialmente com Rails, posso me dar o luxo de me aventurar na
versão 7, recém lançada em modo alfa, em meus projetos pessoais.

**OBS:** Pretendo escrever alguns artigos sobre minhas cabeçadas com NestJS e Typescript. Alguns
temas que pretendo abordar é *TypeOrm* com *migrations* e aplicação Multitenant usando PostgreSQL
RLS.
{: .notice--info}

Neste tutorial eu utilizo Rails 7, esbuild, Tailwind e Hotwire (Turbo e Stimulus), mas meu foco aqui
será mais sobre o pacote Hotwire e como ele pode nos ajudar. Esta dividido nas seguintes partes:
* [Parte 0: Rails 7](#etapa-zero) → página atual
* ~~Parte 1: Tailwind~~ → em breve
* ~~Parte 2: Hotwire Turbo~~ → em breve
* ~~Parte 3: Hotwire Stimulus~~ → em breve
<!-- [Link para parte II]({% post_url 2021-04-08-busca-texto-otimizada-com-pg-search-p2 %}){:target="_blank"} -->

O pano de fundo é uma aplicação estilo Kanban, com um quadro em que podemos incluir, ver, editar e
excluir os cards/tarefas e isso ser persistido simultaneamente via *websockets* para todas as
sessões abertas da aplicação. Todo código esta disponível neste
[repositório](https://github.com/callmarx/LearningHotwire){:target="_blank"}. Note que incluí
algumas [*branches*](https://github.com/callmarx/LearningHotwire/branches){:target="_blank"} que
representam as partes abordas aqui.

## Etapa Zero
Nesta parte inicial, explico como configurar o Rails 7, com suas as novas opções, e "dockerizo" os
baco do dados PostgreSQL e Redis. O resultado final desta etapa é o disponível na *branch*
[blog-part-0](https://github.com/callmarx/LearningHotwire/tree/blog-part-0){:target="_blank"}.

### Criando um novo projeto com Rails 7
Utilizei as seguintes versões para este projeto:
```bash
$ ruby -v
# ruby 3.0.3p157 (2021-11-24 revision 3fb7d2cadc) [x86_64-linux]

$ rails -v
# Rails 7.0.0.rc1

$ yarn -v
# 1.22.17
```

Criei um novo projeto com o seguinte comando:
```bash
$ rails new LearningHotwire \
              -d=postgresql \
              --skip-test \
              -j esbuild \
              --css tailwind
```

Nada de novo nas duas primeiras *flags*: será uma aplicação com bando de dados PostgreSQL
(`-d=postgresql`) e não utilizarei testes (`--skip-test`).

Nas duas últimas temos algumas novidades: escolho o [*esbuild*](https://esbuild.github.io/){:target="_blank"}
como *JavaScript bundler* (`-j esbuild`) e o [*tailwind*](https://tailwindcss.com){:target="_blank"}
como *CSS processor/framework* (`--css tailwind`). Estas novas flags correspondem as gemas
[*jsbundling-rails*](https://github.com/rails/jsbundling-rails){:target="_blank"} e
[*cssbundling-rails*](https://github.com/rails/cssbundling-rails){:target="_blank"}, incluídas
automaticamente no Gemfile.

### Algumas inclusões
No [Gemfile](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/Gemfile){:target="_blank"}
eu removi os comentários e inclui algumas gemas ficando assim:

```ruby
# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"
gem "rails", "~> 7.0.0.rc1"

gem "cssbundling-rails", ">= 0.1.0"
gem "jbuilder", "~> 2.7"
gem "jsbundling-rails", "~> 0.1.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "redis", "~> 4.0"
gem "sprockets-rails", ">= 3.4.1"
gem "stimulus-rails", ">= 0.7.3"
gem "turbo-rails", ">= 0.9.0"

gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  gem "byebug"
  gem "rspec-rails", "~> 4.0.0"
end

group :development do
  gem "web-console", ">= 4.1.0"

  gem "foreman", require: false
  gem "rubocop", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubycritic", require: false
end
```

O Redis vem comentado automaticamente, mas vamos utiliza-lo mais a frente para o *ActionCable* com
o [turbo-rails](https://github.com/hotwired/turbo-rails){:target="_blank"}.

Nos blocos de `:development` e `:test` inclui algumas gemas para teste e lint. Não sei ainda se vou
ou não desenvolver testes, mas na duvida instalei o RSpec com o comando padrão
`rails generate rspec:install` e inclui arquivos de configuração como
[.reek.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/.reek.yml){:target="_blank"},
[.rubocop.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/.rubocop.yml){:target="_blank"},
[.rubycritic.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/.rubycritic.yml){:target="_blank"},
entre outros.

### Docker
Para facilitar o desenvolvimento eu "dockerizei" o PostgreSQL e Redis com o seguinte
[docker-compose.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/docker-compose.yml){:target="_blank"}:

```yml
# docker-compose.yml
version: '3.4'

services:
  db:
    image: postgres:14-alpine
    container_name: learhot-db-ctr
    mem_limit: 256m
    command: -c fsync=off --client-min-messages=warning
    volumes:
      - db:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_INITDB_ARGS: '--encoding=UTF-8 --lc-collate=C --lc-ctype=C'
    restart: on-failure
    logging:
      driver: none

  redis:
    image: redis:6-alpine
    container_name: learhot-redis-ctr
    mem_limit: 256m
    volumes:
      - redis-data:/var/lib/redis/data
    ports:
      - "127.0.0.1:6379:6379"
    restart: on-failure
    logging:
      driver: none

volumes:
  db:
  redis-data:
```

Para se comunicar com esses bancos alterei o
[config/database.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/config/database.yml){:target="_blank"}
e o
[config/cable.yml](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/config/cable.yml){:target="_blank"}:

```yml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: UTF8
  host: localhost
  user: postgres
  password: postgres
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: LearningHotwire_development
  port: 5432

test:
  <<: *default
  database: LearningHotwire_development
  port: 5432

# config/cable.yml
development:
  adapter: redis
  url: <%= "#{ENV.fetch("REDIS_URL") { "redis://localhost:6379" }}/1" %>
  channel_prefix: LearningHotwire_development

test:
  adapter: async

production:
  adapter: redis
  url: <%= "#{ENV.fetch("REDIS_URL") { "redis://localhost:6379" }}/1" %>
  channel_prefix: LearningHotwire_production
```

### Procfile
Com as novas inclusões de *JavaScript bundler* e *CSS processor/framework*, o Rails 7 utiliza para
subir todo o ambiente de desenvolvimento a gema
[*foreman*](https://github.com/ddollar/foreman){:target="_blank"} que chama os processos listados
no arquivo
[Procfile.dev](https://github.com/callmarx/LearningHotwire/blob/blog-part-0/Procfile.dev){:target="_blank"}.
Isso tudo porque não mais apenas o servidor do Rails precisa ser executado em modo *watch*, ou
seja, em modo de reload automático (em inglês chamamos de *watch process*), mas agora também essas
duas novas inclusões.

Como incluímos o PostgreSQL e Redis no docker, podemos incluir também a chamada `docker-compose up`
no Procfile, ficando assim:

```text
docker: docker-compose up
web: bin/rails server -p 3000
js: yarn build --watch
css: yarn build:css --watch
```

### Yay! You’re on Rails!
É isso. Basta agora executar o script disponível `bin/dev` que chama o *foreman* para o Procfile
que atualizamos.

```bash
# esse script já vem com permissão de execução
$ bin/dev
```
![bin/dev](/assets/posts/bin-dev.webp){: .align-center}

Não esqueça de criar o banco de dados, em um outro terminal execute:
```bash
$ rails db:create
```

E acesse <http://localhost:3000/> e veja a clássica telinha do Rails.


Por agora, é isso.
<div class="tenor-gif-embed" data-postid="17519616" data-share-method="host" data-aspect-ratio="1" data-width="100%">
  <a href="https://tenor.com/view/cat-leaving-leave-oops-bye-gif-17519616"/>
</div>
<script type="text/javascript" async src="https://tenor.com/embed.js"/>

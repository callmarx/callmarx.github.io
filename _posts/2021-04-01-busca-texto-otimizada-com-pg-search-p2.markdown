---
layout: post
title:  "Busca em texto otimizada com a Gem pg_search - Parte II"
date:   2021-04-01 18:58:53 -0300
description: >-
  Destrinchando a funcionalidade “Full Text Searching" do PostgreSQL com a Gem pg_search
  em uma aplicação Ruby on Rails - Parte II
categories: blog
image:
  path: assets/posts/text-search.jpeg
  width: 500
  height: 500
---

<!-- excerpt-start -->
Na [parte I]({% post_url 2021-01-17-busca-texto-otimizada-com-pg-search-p1 %}){:target="_blank"} deste
post eu expliquei um pouco sobre o conceito e as funcionalidades de
[Full Text Searching do PostgreSQL](https://www.postgresql.org/docs/current/textsearch-intro.html){:target="_blank"}
e me comprometi a explicar com um projetinho Ruby on Rails através da
[Gem PgSearch](https://github.com/Casecommons/pg_search){:target="_blank"}, vamos lá então.
<!-- excerpt-end -->

# Bora codar!

![Cat coding](/assets/posts/cat-coding.gif)

Primeiro eu montei um Rails API-Only, ou seja, uma aplicação
[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer){:target="_blank"} que
responde apenas em JSON já que o objetivo aqui é testar a performance de buscas em textos ~~e não
porque eu não tenho saco em ficar enfeitando HTML e CSS~~. Com um único model e controller -
Article - sob os campos ```:title``` e ```:content```, podemos preenchê-los com algum texto e assim
utilizar a gema. Para popular esses artigos utilizei o RSS do site da
[câmara dos deputados](https://www.camara.leg.br/noticias/rss){:target="_blank"} como demonstrado
no script a seguir.

```ruby
# script disponível em db/seeds.rb

require 'rss'
require 'open-uri'

dynamics = %w[
  ADMINISTRACAO-PUBLICA
  AGROPECUARIA
  ASSISTENCIA-SOCIAL
  CIDADES
  CIENCIA-E-TECNOLOGIA
  COMUNICACAO
  CONSUMIDOR
  DIREITO-E-JUSTICA
  DIREITOS-HUMANOS
  ECONOMIA
  EDUCACAO-E-CULTURA
  INDUSTRIA-E-COMERCIO
  MEIO-AMBIENTE
  POLITICA
  RELACOES-EXTERIORES
  SAUDE
  SEGURANCA
  TRABALHO-E-PREVIDENCIA
  TRANSPORTE-E-TRANSITO
  TURISMO
]

dynamics.each do |dynamic|
  url = URI.open("https://www.camara.leg.br/noticias/rss/dinamico/#{dynamic}")
  feed = RSS::Parser.parse(url)
  feed.items.each do |item|
    Article.create(
      title: item.title,
      content: item.content_encoded,
      created_at: item.pubDate
    )
  end
end
```

<br>
O projeto completo está disponível em <https://github.com/callmarx/fts_example>{:target="_blank"}.
Para executar basta ter o Docker instalado e configurado em seu linux e executar o seguintes
comandos:

```bash
# em um terminal
$ make up

# em outro terminal
$ make refresh-db
```

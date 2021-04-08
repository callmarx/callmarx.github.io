---
layout: post
title:  "Busca em texto otimizada com a Gem pg_search - Parte II"
date:   2021-04-07 16:58:53 -0300
description: >-
  Destrinchando a funcionalidade “Full Text Searching" do PostgreSQL com a Gem pg_search
  em uma aplicação Ruby on Rails - Parte II
categories: blog
image:
  path: assets/posts/text-search.webp
  width: 500
  height: 500
---

<!-- excerpt-start -->
Na [parte I]({% post_url 2021-01-17-busca-texto-otimizada-com-pg-search-p1 %}){:target="_blank"}
deste post eu expliquei um pouco sobre o conceito e as funcionalidades de
[Full Text Searching do PostgreSQL](https://www.postgresql.org/docs/current/textsearch-intro.html){:target="_blank"}
e me comprometi a explicar com um projetinho Ruby on Rails através da Gema
[PgSearch](https://github.com/Casecommons/pg_search){:target="_blank"}, vamos lá então.
<!-- excerpt-end -->


![Cat coding](/assets/posts/cat-coding.gif)

## Git clone e diverta-se!

O projeto completo está disponível em <https://github.com/callmarx/fts_example>{:target="_blank"}.
Para executar basta ter o Docker instalado e configurado em seu linux e executar os seguintes
comandos em distintos terminais:

```bash
# em um terminal, dentro da pasta do projeto
$ make up

# em outro terminal, também dentro da pasta do projeto
$ make prepare-db
```
OBS: O comando ```make up``` ocupa o terminal em questão pois exibe, em tempo real, o log do Rails. 
Para sair, basta dar CTRL+C (interrompe o ```rails server```, mas o container continua rodando).

Você pode testar a diferença de performance das buscas tanto em requisições completas com
[cURL](https://curl.se){:target="_blank"}, [Postman](https://www.postman.com){:target="_blank"} ou
qualquer outra ferramenta para consulta de API de sua preferência, quanto pelo console da aplicação
invocando diretamente os métodos. No final deste post vou compartilhar os resultados que obtive.

## Como eu fiz

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
# É executado em "make prepare-db"

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

Para utilizar [PgSearch](https://github.com/Casecommons/pg_search){:target="_blank"} no Rails não é
necessario nenhum arquivo de configuração ou inicialização, basta incluir no Gemfile e seguir as
instruições de inclusão e escopo como a documentação da Gema explica em
<https://github.com/Casecommons/pg_search#pg_search_scope>{:target="_blank"}. Porém, precisamos
configurar nosso banco para o ```tsvector``` do PostgreSQL, no caso especificamente para a tabela
*articles* que contém o texto à ser buscado. Para isso incluí a seguinte *migrate*, disponível
em ```db/migrate/20210402195116_add_tsvector_to_article.rb```:

```ruby
# Código disponível em db/migrate/20210402195116_add_tsvector_to_article.rb
class AddTsvectorToArticle < ActiveRecord::Migration[6.1]
  def up
    add_column :articles, :tsv, :tsvector
    add_index :articles, :tsv, using: :gin

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION custom_pt (COPY = pg_catalog.portuguese);
      ALTER TEXT SEARCH CONFIGURATION custom_pt
      ALTER MAPPING
      FOR hword, hword_part, word
      WITH unaccent, portuguese_stem;
    SQL

    execute <<-SQL
      CREATE TRIGGER articles_tsvector_update BEFORE INSERT OR UPDATE
      ON articles FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'public.custom_pt', title, content
      );

      UPDATE articles SET tsv = (to_tsvector(
        'public.custom_pt', title || content
      ));
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER articles_tsvector_update
      ON articles;

      DROP TEXT SEARCH CONFIGURATION custom_pt;
    SQL

    remove_index :articles, :tsv
    remove_column :articles, :tsv
  end
end
```

Traduzindo em passos o *migrate* acima, temos o seguinte:
- Cria uma nova coluna em *articles*, chamada *tsv* do tipo ```:tsvector```
- Cria uma indexação sob essa nova coluna do tipo ```:gin```
- Cria uma configuração de busca textual copiada da padrão ```pg_catalog.portuguese``` com nome
*custom_pt*
- Edita essa busca textual para mapiar as palavras com a extensão ```unaccent```
- Cria um *trigger* que será invocado na inserção e edição para atualizar a coluna ```:tsv``` com
tsvector sob os campos ```:title, :content``` do artigo em questão com a nova configuração de busca
textual.
- Atualiza todos os artigos para preencher a coluna *tsv* da mesma forma que o *trigger* acima faz.

Note que com isto utlizei uma estratégia dupla de otimização: ***tsvector*** + ***GIN index***.

<br>
Os métodos de busca estão no model, sendo ```.bad_search``` implementado com o simples *ilike* e
```.good_search``` com a gema. O código, disponível em ```app/models/article.rb```, é o que segue:
```ruby
# Código disponível em app/models/article.rb
class Article < ApplicationRecord
  include PgSearch::Model

  scope :ordered, -> { order(created_at: :desc) }

  validates :title, presence: true
  validates :content, presence: true

  pg_search_scope :pg_search,
                  against: %i[title content],
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'custom_pt',
                      tsvector_column: 'tsv'
                    }
                  }

  class << self
    def bad_search(term)
      if term.present?
        self.where(
          %(
            unaccent(title) ilike unaccent(:term)
            OR unaccent(content) ilike unaccent(:term)
          ),
          term: "%#{term}%"
        )
      else
        self.all
      end
    end

    def good_search(term)
      if term.present?
        self.pg_search(term)
      else
        self.all
      end
    end
  end
end
```

Atente aqui que foi incluido ```PgSearch::Model``` e definido o escopo com ```pg_search_scope```
para que possamos dizer a gema quais configurações de busca estamos utilizando e sob quais campos
do modelo. Defini em ambas os métodos de busca para quando o argumento for nulo retornar ```.all```
de maneira a simplifcar a lógica no controller.

## Resultados

<div class="tenor-gif-embed" data-postid="8171427" data-share-method="host" data-width="100%"
data-aspect-ratio="1.78494623655914">
  <a href="https://tenor.com/view/mysterious-mysteriousa-mysteriousb-gif-8171427">
    Mysterious GIF
  </a>
  from <a href="https://tenor.com/search/mysterious-gifs">Mysterious GIFs</a>
</div>
<script type="text/javascript" async src="https://tenor.com/embed.js"></script>

<br/>
<br/>
Antes de pontuarmos a performance, vale lembrar que inflexões de palavras como conjugação verbal,
gênero, plural etc, não deveria interferir na integridade da busca, ou seja, no nosso contexto com
essa API, na quantidade de artigos selecionados. Se um usuário busca, por exemplo por *amendoins*,
é intuitivo incluir também artigos que contenham a inflexão singular *amendoim*. Porém, como será
mostrado, esse é não o comportamento quando utilizamos *ilike* da linguagem SQL.

Fazendo uma consulta simples na API (lembrando que é preciso ter um terminal com ```make up```
rodando), sem o parâmetro de url ```:good_search == 'ok'```, o controller utiliza o método de busca
```.bad_search``` e fazendo isso para o termo *proibir* resulta em 4 artigos:

![bad proibir](/assets/posts/bad_proibir.webp)

<br/>
<br/>
Fazendo agora uma consulta com o parâmetro de url, ou seja, com o método de busca ```.good_search```,
com o mesmo termo *proibir*, já obtemos 13 artigos:

![good proibir](/assets/posts/good_proibir.webp)

<br/>
<br/>
Se repitirmos as buscas acima com alguma conjugação do verbo como *proibido*, a consulta
```.bad_search``` irá selecionar outros artigos, já com a ```.good_search``` mantemos os mesmos 13
artigos já que o ```tsvector``` trabalha com
[lexemas](https://radames.manosso.nom.br/linguagem/gramatica/morfologia/lexema/){:target="_blank"}
o que garante abranger na busca as inflexões. Essas consultas pelo Postman podem ser importadas
pelo arquivo [fts_example.postman_collection.json](){:target="_blank"}, também disponível no
projeto.


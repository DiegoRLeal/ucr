# Usar imagem oficial do Ruby
FROM ruby:3.2.2-slim AS base

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  build-essential \
  libpq-dev \
  libicu-dev \
  git \
  curl \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /rails

# Copiar o Gemfile e o Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instalar gems
RUN gem install bundler:2.5.18 && bundle install

# Copiar o restante da aplicação
COPY . .

# Precompilar gems para bootsnap (opcional)
RUN bundle exec bootsnap precompile --gemfile

# Expor a porta 3000
EXPOSE 3000

# Comando para rodar o servidor
# CMD ["rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

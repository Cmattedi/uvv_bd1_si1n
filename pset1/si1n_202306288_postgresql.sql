--Começo do primerio bloco 

DROP DATABASE IF EXISTS uvv; --Comando para apagar o banco de dados caso ele ja exista

DROP USER IF EXISTS cosme; --Comando para apagar usuario caso ja exista  

--Comando para criação do usúario e funções que ele esta permitido a executar

CREATE USER cosme WITH
CREATEDB
CREATEROLE
INHERIT
ENCRYPTED PASSWORD '123456';

\c 'postgresql://cosme:123456@localhost/postgres';

--Comando para criação do banco de dados uvv com os seguinta parametros

CREATE DATABASE uvv WITH
OWNER =      'cosme'
TEMPLATE =   'template0'
ENCODING =   'UTF8'
LC_COLLATE = 'pt_BR.utf-8'
LC_CTYPE =   'pt_BR.utf-8'
ALLOW_CONNECTIONS = 'true';
\c uvv;

--Comando para criação do schema

CREATE SCHEMA IF NOT EXISTS lojas AUTHORIZATION cosme;
SET SEARCH_PATH TO lojas, "&USER", public;
ALTER USER cosme
SET SEARCH_PATH TO lojas, "&USER", public;

--Final da criação do primeiro bloco 
--Inicio da criação de tabelas
--Comando para criação da tabela de produtos 
--Segundo bloco 

CREATE TABLE produtos (
                produto_id                NUMERIC(38)  NOT NULL,
                nome                      VARCHAR(255) NOT NULL,
                preco_unitario            NUMERIC(10,2),
                detalhes BYTEA,
                imagem BYTEA,
                imagem_mime_type          VARCHAR(512),
                imagem_arquivo            VARCHAR(512),
                imagem_charset            VARCHAR(512),
                imagem_ultima_atualizacao DATE NOT NULL,
                CONSTRAINT pk_produtos    PRIMARY KEY (produto_id)
);
--Restrição para preco_unitario

ALTER TABLE produtos ADD CONSTRAINT cc_produtos_preco_unitario
CHECK (preco_unitario >= 0);

--Comentários sobre a tabela produtos

COMMENT ON COLUMN produtos.produto_id     IS 'pk da tabela produtos';
COMMENT ON COLUMN produtos.nome           IS 'nome dos produtos';
COMMENT ON COLUMN produtos.preco_unitario IS 'preco da unidade do produto';

--Final do segundo bloco 

--Inicio do terceiro bloco 

--Comando para criação da tabela de lojas

CREATE TABLE lojas (
                loja_id                    NUMERIC(38)  NOT NULL,
                nome                       VARCHAR(255) NOT NULL,
                endereco_web               VARCHAR(100),
                endereco_fisico            VARCHAR(512),
                latitude                   NUMERIC,
                longitude                  NUMERIC,
                logo BYTEA,
                logo_mime_type             VARCHAR(512),
                logo_arquivo               VARCHAR(512),
                logo_charset               VARCHAR(512),
                logo_ultima_atulizacao     DATE NOT NULL,
                CONSTRAINT pk_loja         PRIMARY KEY (loja_id) --Comando para criação da PK da tabela
);

--Restrição para pessoa nao deixa nula um dos campos.

ALTER TABLE lojas ADD CONSTRAINT cc_lojas_endereco
CHECK (
  COALESCE(endereco_web, '') <> '' OR
  COALESCE(endereco_fisico, '') <> ''
);

--Comentários sobre a tabela lojas

COMMENT ON COLUMN lojas.loja_id         IS 'pk da tabela lojas';
COMMENT ON COLUMN lojas.nome            IS 'nome das lojas';
COMMENT ON COLUMN lojas.endereco_web    IS 'endereco onlina das lojas';
COMMENT ON COLUMN lojas.endereco_fisico IS 'endereco resindencial da loja';
COMMENT ON COLUMN lojas.logo            IS 'logotipo das lojas';

--Final do terceiro bloco 

--Inicio do quarto bloco

--Comando para criação da tabela de estoques 

CREATE TABLE estoques (
                estoque_id             NUMERIC(38) NOT NULL,
                loja_id                NUMERIC(38) NOT NULL,
                produto_id             NUMERIC(38) NOT NULL,
                quantidade             NUMERIC(38) NOT NULL,
                CONSTRAINT pk_estoque  PRIMARY KEY (estoque_id) --Comando para criação da PK da tabela
);
COMMENT ON COLUMN estoques.estoque_id   IS 'pk da tabela estoques';
COMMENT ON COLUMN estoques.loja_id      IS 'fk da tabela lojas';
 
--Restrição para quantidade não ser negativa

ALTER TABLE estoques ADD CONSTRAINT cc_estoques_quantidade 
CHECK (quantidade >=0);

-- Criando um fk entre estoques e produtos 

ALTER TABLE estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Criando um fk entre estoques e lojas  

ALTER TABLE estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Final do quarto bloco


--Inicio do quinto bloco 

--Comando para criação da tabela de clientes

CREATE TABLE clientes (
                cliente_id            NUMERIC(38)  NOT NULL,
                email                 VARCHAR(255) NOT NULL,
                nome                  VARCHAR(255) NOT NULL,
                telefone1             VARCHAR(20),
                telefone2             VARCHAR(20),
                telefone3             VARCHAR(20),
                CONSTRAINT pk_cliente PRIMARY KEY (cliente_id) --Comando para criação da PK da tabela
);
--Comentários sobre a tabela clientes

COMMENT ON COLUMN clientes.cliente_id IS 'chave primaria da tabela cliente';
COMMENT ON COLUMN clientes.email      IS 'email do cliente';
COMMENT ON COLUMN clientes.nome       IS 'nome do cliente';
COMMENT ON COLUMN clientes.telefone1  IS 'contato 1 com cliente';
COMMENT ON COLUMN clientes.telefone2  IS 'contato 2 do cliente';
COMMENT ON COLUMN clientes.telefone3  IS 'contato 3 cliente';

--final do quinto bloco 

--Inicio do sexto bloco

--Comando para criação da tabela de envios

CREATE TABLE envios (
                envio_id            NUMERIC(38)  NOT NULL,
                loja_id             NUMERIC(38)  NOT NULL,
                cliente_id          NUMERIC(38)  NOT NULL,
                endereco_entrega    VARCHAR(512) NOT NULL,
                status              VARCHAR(15)  NOT NULL,
                CONSTRAINT pk_envio PRIMARY KEY (envio_id) --Comando para criação da PK da tabela
);

-- Criando um fk entre envios e lojas  

ALTER TABLE envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Criando um fk entre envios e clientes
  
ALTER TABLE envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Restrição para status 

ALTER TABLE envios ADD CONSTRAINT cc_envios_status
CHECK( status IN('CANCELADO','ENVIADO','TRANSITO','ENTREGUE'));

--Comentários sobre a tabela envios
 
COMMENT ON COLUMN envios.envio_id   IS 'pk da tabela envios';
COMMENT ON COLUMN envios.loja_id    IS 'fk da tabela loja';
COMMENT ON COLUMN envios.cliente_id IS 'fk da tabela clientes';

--Final do sexto bloco 

--Inicio do setimo bloco

--Comando para criação da tabela de envios

CREATE TABLE pedidos (
                pedido_id            NUMERIC(38) NOT NULL,
                data_hora            TIMESTAMP   NOT NULL,
                cliente_id           NUMERIC(38) NOT NULL,
                status               VARCHAR(15) NOT NULL,
                loja_id              NUMERIC(38) NOT NULL,
                CONSTRAINT pk_pedido PRIMARY KEY (pedido_id) --Comando para criação da PK da tabela
);

-- Criando um fk entre pedidos e lojas  

ALTER TABLE pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Criando um fk entre pedidos e clientes 
  
ALTER TABLE pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Restrição de verificação de status
  
ALTER TABLE pedidos ADD CONSTRAINT cc_pedidos_status
CHECK( status IN('CANCELADO','COMPLETO','ABERTO','PAGO','REEMBOLSADO','ENVIADO'));

--Comentários sobre a tabela pedidos

COMMENT ON COLUMN pedidos.pedido_id  IS 'numero de indentificção do pedido';
COMMENT ON COLUMN pedidos.data_hora  IS 'data e hora eu o pedido foi relizado';
COMMENT ON COLUMN pedidos.cliente_id IS 'fk da tabela clientes';
COMMENT ON COLUMN pedidos.loja_id    IS 'fk da tabela lojas';


--Final do sétimo bloco

--Inicio do oitavo bloco

--Comando para criação da tabela de pedido itens


CREATE TABLE pedidos_itens (
                pedido_id                  NUMERIC(38)   NOT NULL,
                produto_id                 NUMERIC(38)   NOT NULL,
                numero_da_linha            NUMERIC(38)   NOT NULL,
                preco_unitario             NUMERIC(10,2) NOT NULL,
                quantidade                 NUMERIC(38)   NOT NULL,
                envio_id                   NUMERIC(38),
                CONSTRAINT pk_pedido_itens PRIMARY KEY (pedido_id, produto_id) --Comando para criação da PK da tabela 
);

--Restrição do preço_unitário 

ALTER TABLE pedidos_itens ADD CONSTRAINT cc_pedidos_unitario_pedidos_itens
CHECK (preco_unitario >= 0);

--Restrição quantidade  

ALTER TABLE pedidos_itens ADD CONSTRAINT cc_quantidade_pedidos_itens
CHECK (quantidade >= 0);

-- Criando um fk entre pedidos_itens e produtos
  
ALTER TABLE pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Criando um fk entre pedidos_itens e envios

ALTER TABLE pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
DEFERRABLE INITIALLY DEFERRED;

-- Criando um fk entre pedidos_itens e pedidos

ALTER TABLE pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--Final da tabela pedidos_itens

--Final do oitavo bloco

-- fim da criação do banco de dados

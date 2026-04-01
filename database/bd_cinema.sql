create database bd_cinema;

use bd_cinema;

create table tb_cliente
(cd_cliente int not null primary key,
nome varchar(100) not null,
email char (50) not null,
cpf char(11) not null unique,
telefone char(20),
endereco char (100),

CONSTRAINT chk_email_valido
	check (email like '%_@__%.__%'));
    
create table tb_usuario 
(cd_usuario INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
senha VARCHAR(100) NOT NULL,
tipo VARCHAR(20) -- admin, atendente, etc
);
    
CREATE TABLE tb_produto (
    cd_produto INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL,
    estoque_minimo INT NOT NULL DEFAULT 5,

    CONSTRAINT chk_preco_positivo 
        CHECK (preco >= 0),

    CONSTRAINT chk_estoque_positivo 
        CHECK (estoque >= 0)
);

create table tb_sala
(cd_sala int not null primary key,
sala int,
capacidade int,
tp_sala char(5),
dublagem char(20));

create table tb_filme
(cd_filme int not null primary key,
filme char(50),
duracao time,
classe_etaria char(5),
tp_filme char(20));

create table tb_sessao
(cd_sessao int not null primary key,
sessao char(50),
data_hora datetime,
cd_filme int not null,
cd_sala int not null);

create table tb_assento 
(cd_assento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
numero_assento CHAR(3),
ocupado BOOLEAN DEFAULT FALSE,
cd_sessao INT NOT NULL);

create table tb_venda
(nr_recibo int not null primary key,
dt_hr_venda datetime,
valor_total decimal(10,2),
cd_cliente int not null,
tp_pagamento varchar(20));

CREATE TABLE rl_venda_produto (
    nr_recibo INT,
    cd_produto INT,
    quantidade INT NOT NULL,
    valor_parcial DECIMAL(10,2),

    PRIMARY KEY (nr_recibo, cd_produto),

    FOREIGN KEY (nr_recibo) REFERENCES tb_venda(nr_recibo),
    FOREIGN KEY (cd_produto) REFERENCES tb_produto(cd_produto));

create table tb_ingresso
(cd_ingresso int not null primary key,
valor_ingresso decimal(10,2),
tp_ingresso char(10),
cd_sessao int not null,
cd_assento int not null,
nr_recibo int not null);


ALTER TABLE tb_cliente 
MODIFY cd_cliente INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_venda 
MODIFY nr_recibo INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_ingresso 
MODIFY cd_ingresso INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_sala
MODIFY cd_sala INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_filme
MODIFY cd_filme INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_sessao
MODIFY cd_sessao INT NOT NULL AUTO_INCREMENT;

ALTER TABLE tb_assento
MODIFY cd_assento INT NOT NULL AUTO_INCREMENT;


alter table tb_sessao
add constraint fk_filme foreign key (cd_filme)
references tb_filme (cd_filme);

alter table tb_sessao
add constraint fk_sala foreign key (cd_sala)
references tb_sala (cd_sala);

alter table tb_assento
add constraint fk_assento_sessao foreign key (cd_sessao)
references tb_sessao (cd_sessao);

alter table tb_ingresso
add constraint fk_sessao foreign key (cd_sessao)
references tb_sessao (cd_sessao);

alter table tb_ingresso
add constraint fk_venda_ingresso foreign key (nr_recibo)
references tb_venda (nr_recibo);

alter table tb_ingresso
add constraint fk_ingresso_assento foreign key (cd_assento)
references tb_assento (cd_assento);

alter table tb_venda
add constraint fk_cliente foreign key (cd_cliente)
references tb_cliente (cd_cliente);

ALTER TABLE tb_venda 
DROP FOREIGN KEY fk_cliente;

ALTER TABLE tb_venda 
ADD CONSTRAINT fk_cliente 
FOREIGN KEY (cd_cliente)
REFERENCES tb_cliente(cd_cliente)
ON DELETE RESTRICT;

ALTER TABLE tb_venda ADD cd_usuario INT;

ALTER TABLE tb_venda
ADD CONSTRAINT fk_usuario_venda
FOREIGN KEY (cd_usuario)
REFERENCES tb_usuario(cd_usuario);

ALTER TABLE tb_ingresso 
MODIFY cd_sessao INT NOT NULL;

ALTER TABLE tb_produto
ADD COLUMN tipo_produto VARCHAR(20) NOT NULL DEFAULT 'EXTRA';

ALTER TABLE tb_ingresso
ADD CONSTRAINT unique_assento_sessao
UNIQUE (cd_sessao, cd_assento);

DELIMITER $$

CREATE TRIGGER trg_valida_produto_extra
BEFORE INSERT ON rl_venda_produto
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);

    SELECT tipo_produto
    INTO tipo
    FROM tb_produto
    WHERE cd_produto = NEW.cd_produto;

    IF tipo <> 'EXTRA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas produtos extras podem ser inseridos em rl_venda_produto';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_valida_produto_extra_update
BEFORE UPDATE ON rl_venda_produto
FOR EACH ROW
BEGIN
    DECLARE tipo VARCHAR(20);

    SELECT tipo_produto
    INTO tipo
    FROM tb_produto
    WHERE cd_produto = NEW.cd_produto;

    IF tipo <> 'EXTRA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas produtos extras podem ser utilizados';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_nao_permitir_estoque_negativo
BEFORE UPDATE ON tb_produto
FOR EACH ROW
BEGIN
    IF NEW.estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque não pode ser negativo';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_verificar_estoque
BEFORE INSERT ON rl_venda_produto
FOR EACH ROW
BEGIN
    DECLARE estoque_atual INT;

    SELECT estoque INTO estoque_atual
    FROM tb_produto
    WHERE cd_produto = NEW.cd_produto;

	IF estoque_atual IS NULL OR estoque_atual < NEW.quantidade THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Estoque insuficiente para venda';
	END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_baixar_estoque
AFTER INSERT ON rl_venda_produto
FOR EACH ROW
BEGIN
    UPDATE tb_produto
    SET estoque = estoque - NEW.quantidade
    WHERE cd_produto = NEW.cd_produto;
END$$

DELIMITER ;



-- Fazer atualização do insert

INSERT INTO tb_filme (cd_filme, filme, duracao, classe_etaria, tp_filme)
VALUES (1, 'Vingadores: Ultimato', '03:02:00', '12', 'Ação'),
       (2, 'The Batman', '02:56:00', '14', 'Ação'),
       (3, 'Oppenheimer', '03:00:00', '16', 'Suspense'),
       (4, 'Avatar: O Caminho da Água', '03:12:00', '14', 'Ficção'),
       (5, 'Coringa', '02:02:00', '16','Drama'),
       (6, 'Homem-Aranha: Sem Volta Para casa', '02:28:00', '12', 'Ação'),
       (7, 'Frozen 2', '01:44:00', 'Livre', 'Animação'),
       (8, 'Barbie', '01:54:00', '12', 'Comédia');

INSERT INTO tb_sala (sala, capacidade, tp_sala, dublagem)
VALUES
(1, 35, '2D', 'Dublado'),
(2, 35, '2D', 'Legendado'),
(3, 35, '3D', 'Dublado'),
(4, 35, '3D', 'Legendado'),
(5, 35, 'IMAX', 'Dublado'),
(6, 35, 'IMAX', 'Legendado');

INSERT INTO tb_sessao (sessao, data_hora, cd_filme, cd_sala)
VALUES ('Sessão 14h', '2025-01-20 14:00:00', 1, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 1, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 1, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 1, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 1, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 1, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 1, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 1, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 1, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 2, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 2, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 2, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 2, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 3, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 3, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 3, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 3, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 4, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 4, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 4, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 4, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 5, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 5, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 5, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 5, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 6, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 6, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 6, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 6, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 7, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 7, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 7, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 7, 6),
       
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 1),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 1),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 1),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 1),
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 2),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 2),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 2),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 2),
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 3),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 3),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 3),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 3),
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 4),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 4),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 4),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 4),
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 5),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 5),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 5),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 5),
       ('Sessão 14h', '2025-01-20 14:00:00', 8, 6),
       ('Sessão 16h30', '2025-01-20 16:30:00', 8, 6),
       ('Sessão 19h', '2025-01-20 19:00:00', 8, 6),
       ('Sessão 21h30', '2025-01-20 21:30:00', 8, 6);
       
INSERT INTO tb_lanche (lanche, valor_lanche)
VALUES
('Combo pipoca + refri 500ml', 25.00),
('Pipoca pequena', 15.00),
('Pipoca média', 20.00),
('Pipoca grande', 25.00),
('Refrigerante 300ml', 5.00),
('Refrigerante 500ml', 10.00),
('Refrigerante 700ml', 15.00),
('Barra de chocolate 90g', 7.00),
('M&M 80g', 4.50),
('Fini 80g (Tubes, Beijo, Dentadura)', 7.50);

CREATE TEMPORARY TABLE temp_assentos (numero_assento CHAR(3));
INSERT INTO temp_assentos (numero_assento)
SELECT LPAD(n, 2, '0')
FROM (
    SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION
    SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION
    SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION
    SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION
    SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION
    SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
) AS x;
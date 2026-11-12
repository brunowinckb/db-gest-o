create table funcionarios(
	id serial primary key,
	nome varchar(100) not null,
	email varchar(150) unique not null,
	senha varchar(100) not null,
	ativo boolean default TRUE
)



create table clientes(
	id serial primary key,
	nome varchar(200) not null,
	cpf varchar(11) unique not null
)


create table projetos(
	id serial primary key,
	nome varchar(100) unique not null,
	data_entrega date not null,
	id_cliente int references clientes(id),
	status varchar(20) check (status in('Finalizado', 'Em andamento', 'Pendente'))
)


create table tarefas(
	id serial primary key,
	descricao varchar(500) not null,
	data_entrega date not null,
	id_funcionario int references funcionarios(id),
	id_projeto int references projetos(id),
	status varchar(20) check (status in('Pendente', 'Em andamento', 'Finalizada'))
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)


CREATE TABLE historico_tarefas (
    id SERIAL PRIMARY KEY,
    id_tarefa INT REFERENCES tarefas(id),
    acao VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
------------------------------------------------------------------------------------------


-- FUNCIONARIOS
INSERT INTO funcionarios (nome, email, senha, ativo) VALUES
('Carlos Henrique', 'carlos@gmail.com', '123456', TRUE),
('Mariana Silva', 'mariana@gmail.com', '123456', TRUE),
('João Pedro', 'joao@gmail.com', '123456', TRUE),
('Ana Beatriz', 'ana@gmail.com', '123456', FALSE),
('Lucas Martins', 'lucas@gmail.com', '123456', TRUE);


-- CLIENTES
INSERT INTO clientes (nome, cpf) VALUES
('Roberto Almeida', '12345678901'),
('Fernanda Costa', '23456789012'),
('Gabriel Oliveira', '34567890123'),
('Patricia Santos', '45678901234'),
('Ricardo Mendes', '56789012345');


-- PROJETOS
INSERT INTO projetos (nome, data_entrega, id_cliente, status) VALUES
('Sistema de Vendas', '2026-12-10', 1, 'Em andamento'),
('Site Institucional', '2026-11-30', 2, 'Finalizado'),
('Aplicativo Financeiro', '2027-01-15', 3, 'Pendente'),
('Sistema de Estoque', '2026-12-20', 4, 'Em andamento'),
('Portal do Cliente', '2027-02-10', 5, 'Pendente');


-- TAREFAS
INSERT INTO tarefas (descricao, data_entrega, id_funcionario, id_projeto, status) VALUES
('Criar tela de login', '2026-11-20', 1, 1, 'Finalizada'),
('Desenvolver banco de dados', '2026-11-25', 2, 1, 'Em andamento'),
('Criar página inicial', '2026-11-15', 3, 2, 'Finalizada'),
('Desenvolver sistema de cadastro', '2026-12-05', 1, 3, 'Pendente'),
('Realizar testes do sistema', '2026-12-12', 4, 4, 'Em andamento'),
('Criar interface do usuário', '2027-01-10', 5, 5, 'Pendente'),
('Documentar funcionalidades', '2026-12-01', 2, 2, 'Finalizada');


------------------------------------------------------------------------------------------

create view vw_painel_principal as
	select
		f.nome as nome_funcionario,
		t.descricao as título_tarefa,
		t.data_entrega,
		t.status
	from
		tarefas t
	join funcionarios f on t.id_funcionario = f.id




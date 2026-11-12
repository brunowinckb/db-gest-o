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
    categoria varchar(50) not null,
    data_entrega date not null,
    id_funcionario int references funcionarios(id),
    id_projeto int references projetos(id),
    status varchar(20) check (status in('Pendente', 'Em andamento', 'Finalizada')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)



create table historico_tarefas(
    id SERIAL PRIMARY KEY,
    id_tarefa INT REFERENCES tarefas(id),
    acao VARCHAR(100) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
------------------------------------------------------------------------------------------


create function fn_validar_tarefa()
returns trigger
language plpgsql
as $$
declare
    v_ativo boolean;
begin
    select ativo into v_ativo
    from funcionarios
    where id = new.id_funcionario;

    if v_ativo is null or v_ativo = false then
        raise exception 'A tarefa deve ser vinculada a um colaborador ativo';
    end if;

    new.data_criacao := current_timestamp;
    return new;
end;
$$



create trigger trg_validar_tarefa
before insert on tarefas
for each row
execute function fn_validar_tarefa()



create function fn_registrar_historico()
returns trigger
language plpgsql
as $$
begin
    insert into historico_tarefas (id_tarefa, acao, data_hora)
    values (new.id, 'Tarefa criada: ' || new.status, current_timestamp);

    return new;
end;
$$



create trigger trg_registrar_historico
after insert on tarefas
for each row
execute function fn_registrar_historico()
------------------------------------------------------------------------------------------


-- FUNCIONARIOS
INSERT INTO funcionarios (nome, email, senha, ativo) VALUES
('Carlos Henrique', 'carlos@gmail.com', '123456', TRUE),
('Mariana Silva', 'mariana@gmail.com', '123456', TRUE),
('João Pedro', 'joao@gmail.com', '123456', TRUE),
('Ana Beatriz', 'ana@gmail.com', '123456', FALSE),
('Lucas Martins', 'lucas@gmail.com', '123456', TRUE)



-- CLIENTES
INSERT INTO clientes (nome, cpf) VALUES
('Roberto Almeida', '12345678901'),
('Fernanda Costa', '23456789012'),
('Gabriel Oliveira', '34567890123'),
('Patricia Santos', '45678901234'),
('Ricardo Mendes', '56789012345')



-- PROJETOS
INSERT INTO projetos (nome, data_entrega, id_cliente, status) VALUES
('Sistema de Vendas', '2026-12-10', 1, 'Em andamento'),
('Site Institucional', '2026-11-30', 2, 'Finalizado'),
('Aplicativo Financeiro', '2027-01-15', 3, 'Pendente'),
('Sistema de Estoque', '2026-12-20', 4, 'Em andamento'),
('Portal do Cliente', '2027-02-10', 5, 'Pendente')



-- TAREFAS
INSERT INTO tarefas (descricao, categoria, data_entrega, id_funcionario, id_projeto, status) VALUES
('Criar tela de login', 'Front-end', '2026-11-20', 1, 1, 'Finalizada'),
('Desenvolver banco de dados', 'Banco de Dados', '2026-11-25', 2, 1, 'Em andamento'),
('Criar página inicial', 'Front-end', '2026-11-15', 3, 2, 'Finalizada'),
('Desenvolver sistema de cadastro', 'Back-end', '2026-12-05', 1, 3, 'Pendente'),
('Realizar testes do sistema', 'Testes', '2026-12-12', 3, 4, 'Em andamento'),
('Criar interface do usuário', 'Design', '2027-01-10', 5, 5, 'Pendente'),
('Documentar funcionalidades', 'Documentação', '2026-12-01', 2, 2, 'Finalizada')
------------------------------------------------------------------------------------------


create view vw_painel_principal as
    select
        f.nome as nome_colaborador,
        t.descricao as titulo_tarefa,
        t.categoria,
        t.data_entrega as prazo_entrega,
        t.status
    from
        tarefas t
    join funcionarios f on t.id_funcionario = f.id



create view vw_cronograma_prazos as
    select
        t.descricao as titulo_tarefa,
        t.status,
        (t.data_entrega - current_date) as dias_restantes,
        f.nome as nome_responsavel,
        t.data_entrega
    from
        tarefas t
    join funcionarios f on t.id_funcionario = f.id
    order by t.data_entrega asc



create function fn_buscar_colaboradores(termo varchar)
returns table(
    id int,
    nome varchar,
    email varchar,
    ativo boolean
)
language plpgsql
as $$
begin
    return query
    select
        f.id,
        f.nome,
        f.email,
        f.ativo
    from
        funcionarios f
    where
        f.nome ilike '%' || termo || '%'
        or f.email ilike '%' || termo || '%';
end;
$$